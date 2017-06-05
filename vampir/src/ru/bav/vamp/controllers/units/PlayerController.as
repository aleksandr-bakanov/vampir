package ru.bav.vamp.controllers.units {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.ui.*;
    import flash.utils.*;
    import ru.bav.vamp.controllers.*;
    import ru.bav.vamp.events.*;
    import ru.bav.vamp.models.*;
    import ru.bav.vamp.models.consts.*;
    import ru.bav.vamp.views.*;
    import ru.bav.vamp.views.units.*;
    import com.greensock.*;
	
	/**
     * Player controller.
     * @author bav
     */
    public class PlayerController extends UnitController {
        private static var WAY_THICKNESS:int = 0;
        private static const MOVING_TIMER_DELAY:int = 25;
        
        private var _upPressed:Boolean = false;
        private var _downPressed:Boolean = false;
        private var _leftPressed:Boolean = false;
        private var _rightPressed:Boolean = false;
        
        private var _movingTimer:Timer;
        private var _stage:Stage;
        private var _mainView:MainView;
        
        private var _needSlowDown:Boolean = false;
        
        public function PlayerController(model:MainModel, unitInfo:UnitModel, view:UnitViewBase, stage:Stage, mainView:MainView) {
            super(model, unitInfo, view);
			if (!WAY_THICKNESS) WAY_THICKNESS = MapCeilView.CELL_SIZE / 6;
            _stage = stage;
            _mainView = mainView;
            initView();
            addKeyListeners();
            addOtherListeners();
            initMovingTimer();
        }
        
        private function addOtherListeners():void {
            _model.keys = [];
            _unit.addEventListener(UserEvent.KEY_COLLECTED, keyCollectedHandler);
        }
        
        private function keyCollectedHandler(event:UserEvent):void {
            _unitInfo.dispatchEvent(new UserEvent(UserEvent.KEY_COLLECTED, event.data));
            _model.keys.push(event.data as String);
        }
        
        private function addKeyListeners():void{
            _stage.addEventListener(KeyboardEvent.KEY_DOWN, keyUpDownHandler);
            _stage.addEventListener(KeyboardEvent.KEY_UP, keyUpDownHandler);
        }
        
        private function removeKeyListeners():void{
            _stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyUpDownHandler);
            _stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpDownHandler);
        }
        
        private function keyUpDownHandler(event:KeyboardEvent):void{
            var value:Boolean = (event.type == KeyboardEvent.KEY_DOWN);
            if (event.keyCode == Keyboard.UP) {
                _upPressed = value;
                if (value)
                    _frontDirection = WallType.NORTH;
            }
            else if (event.keyCode == Keyboard.DOWN) {
                _downPressed = value;
                if (value)
                    _frontDirection = WallType.SOUTH;
            }
            else if (event.keyCode == Keyboard.LEFT) {
                _leftPressed = value;
                if (value)
                    _frontDirection = WallType.WEST;
            }
            else if (event.keyCode == Keyboard.RIGHT) {
                _rightPressed = value;
                if (value)
                    _frontDirection = WallType.EAST;
            }
            
            if (event.keyCode == Keyboard.SPACE && value)
                turnToMist();
            if (event.keyCode == Keyboard.SHIFT && value)
                soulChange();
            if (event.keyCode == Keyboard.CONTROL && value)
                walkThroughWall();
                
            // Если игрок куда-то пошел выключаем невидимость, если она была.
            if (_unitInfo.invisible && value && event.keyCode != Keyboard.SPACE) {
                _unitInfo.invisible = false;
                _unit.alpha = 1;
            }
        }
        
        private function turnToMist():void {
            if (_model.mistCount) {
                stopPlayerMoving();
                _unitInfo.invisible = true;
                _unit.alpha = .3;
                _model.mistCount--;
            }
        }
        
        private function soulChange():void {
            if (_model.soulChangeCount) {
                var len:int = _unit.allUnits.length;
                var distance:Number = 0;
                var ghoulId:int = -1;
                var unit:UnitViewBase;
                var unitInfo:UnitModel;
                for (var i:int = 0; i < len; i++) {
                    unit = _unit.allUnits[i] as UnitViewBase;
                    unitInfo = _model.unitsDict[unit] as UnitModel;
                    // Если нашли гуля и он живой, меряем до него расстояние.
                    if (unitInfo.type == UnitType.GHOUL && unitInfo.hitPoints > 0) {
                        var tempDistance:Number = getDistance(_unit.x, _unit.y, unit.x, unit.y);
                        if (ghoulId < 0) {
                            distance = tempDistance;
                            ghoulId = i;
                        }
                        else {
                            if (tempDistance < distance) {
                                distance = tempDistance;
                                ghoulId = i;
                            }
                        }
                    }
                }
                if (ghoulId >= 0) {
                    unit = _unit.allUnits[ghoulId] as UnitViewBase;
                    unitInfo = _model.unitsDict[unit] as UnitModel;
                    // Юнит шлет STOP_MOVING, что заставляет его контроллер остановить его.
                    TweenLite.killTweensOf(unit);
                    unit.dispatchEvent(new UserEvent(UserEvent.STOP_MOVING));
                    
                    // Далее меняем местами вампира с гулем.
                    // Визуальные координаты
                    var viewX:Number = unit.x;
                    var viewY:Number = unit.y;
                    
                    unit.x = _unitInfo.coordinates.x * MapCeilView.CELL_SIZE + MapCeilView.CELL_SIZE / 2;
                    unit.y = _unitInfo.coordinates.y * MapCeilView.CELL_SIZE + MapCeilView.CELL_SIZE / 2;
                    _unit.x = viewX;
                    _unit.y = viewY;
                    
                    // Координаты в модели
                    var modelX:int = unitInfo.coordinates.x;
                    var modelY:int = unitInfo.coordinates.y;
                    unitInfo.coordinates.x = _unitInfo.coordinates.x;
                    unitInfo.coordinates.y = _unitInfo.coordinates.y;
                    _unitInfo.coordinates.x = modelX;
                    _unitInfo.coordinates.y = modelY;
                    
                    // Запускаем гуля гулять
                    unit.dispatchEvent(new UserEvent(UserEvent.START_MOVING));
                    // Отнимаем у игрока одну способность
                    _model.soulChangeCount--;
                    // Центрируем изображение
                    if (_unit.parent)
                        _mainView.centerViewByPlayer();
                }
            }
        }
        
        private function walkThroughWall():void {
            if (_model.throughWallCount) {
                // Проверим не идет ли игрок сквозь стену за которой
                // находится пустая клетка.
                if (checkCellExist(_frontDirection)) {
                    _model.throughWallDistance = MapCeilView.CELL_SIZE / 3;
                    _model.throughWallCount--;
                }
            }
        }
        
        /**
         * Если следующая ячейка в указанном направлении окажется пустой, будет возвращено false.
         * Используется при проверке возможности прохода сквозь стену.
         * @param	direction
         * @return
         */
        private function checkCellExist(direction:int):Boolean {
            var cell:MapCellModel;
            if (direction == WallType.NORTH && _unitInfo.coordinates.y > 0) 
                cell = _model.map[_unitInfo.coordinates.y - 1][_unitInfo.coordinates.x] as MapCellModel;
            else if (direction == WallType.EAST && _unitInfo.coordinates.x < (_model.map[0] as Array).length - 1) 
                cell = _model.map[_unitInfo.coordinates.y][_unitInfo.coordinates.x + 1] as MapCellModel;
            else if (direction == WallType.SOUTH && _unitInfo.coordinates.y < _model.map.length - 1) 
                cell = _model.map[_unitInfo.coordinates.y + 1][_unitInfo.coordinates.x] as MapCellModel;
            else if (direction == WallType.WEST && _unitInfo.coordinates.x > 0) 
                cell = _model.map[_unitInfo.coordinates.y][_unitInfo.coordinates.x - 1] as MapCellModel;
            
            return Boolean(cell);
        }
        
        public static function getDistance(x1:Number, y1:Number, x2:Number, y2:Number):Number {
            var a:Number = x1 - x2;
            var b:Number = y1 - y2;
            return Math.sqrt(a*a + b*b);
        }
        
        private function initMovingTimer():void {
            _movingTimer = new Timer(MOVING_TIMER_DELAY);
            _movingTimer.addEventListener(TimerEvent.TIMER, movingTimerHandler);
            _movingTimer.start();
        }
        
        private function movingTimerHandler(event:TimerEvent):void {
            if (_upPressed) goUp();
            if (_downPressed) goDown();
            if (_leftPressed) goLeft();
            if (_rightPressed) goRight();
        }
        
        private function tryToBitEnemy(hitedUnit:DisplayObject):void {
            var utype:int = (_model.unitsDict[hitedUnit as UnitViewBase] as UnitModel).type;
            if (utype == UnitType.FAT_POLICEMAN) _needSlowDown = true;
            
            // Если укусили охотника, это дает нам возможность обмена душами
            if (utype == UnitType.HUNTER) _model.soulChangeCount++;
            
            _unit.turn((hitedUnit as UnitViewBase).frontDirection);
            (hitedUnit as EventDispatcher).dispatchEvent(new UserEvent(UserEvent.UNIT_BITTEN));
            _movingTimer.stop();
            var timer:Timer = new Timer(BECAME_GHOUL_DELAY_IN_SEC * 1e3, 1);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, continueMovingAfterFeed);
            timer.start();
        }
        
        private function continueMovingAfterFeed(event:Event):void {
            if (event) (event.currentTarget as IEventDispatcher).removeEventListener(event.type, arguments.callee);
            if (_needSlowDown) {
                _needSlowDown = false;
                slowDown();
            }
            _movingTimer.start();
        }
        
        private function goUp():void {
            var hitedUnit:DisplayObject = checkUnitsHitTest();
            if (!hitedUnit) {
                var newY:Number = _unit.y - _unitInfo.speed;
                var ceilCenterY:Number = _unitInfo.coordinates.y * MapCeilView.CELL_SIZE + MapCeilView.CELL_SIZE / 2;
                var ceilCenterX:Number = _unitInfo.coordinates.x * MapCeilView.CELL_SIZE + MapCeilView.CELL_SIZE / 2;
                
                if (ceilCenterY - newY <= WAY_THICKNESS)
                    setUnitY(newY);
                else if (checkDirection(WallType.NORTH)) {
                    if (ceilCenterX - _unit.x > WAY_THICKNESS)
                        if (checkWallExist(new Point(_unitInfo.coordinates.x, _unitInfo.coordinates.y - 1), WallType.WEST) ||
                            checkWallExist(new Point(_unitInfo.coordinates.x - 1, _unitInfo.coordinates.y - 1), WallType.SOUTH)) {
                                setUnitX(_unit.x + _unitInfo.speed);
                                return;
                            }
                        else setUnitY(newY);
                    else if (_unit.x - ceilCenterX > WAY_THICKNESS)
                        if (checkWallExist(new Point(_unitInfo.coordinates.x, _unitInfo.coordinates.y - 1), WallType.EAST) ||
                            checkWallExist(new Point(_unitInfo.coordinates.x + 1, _unitInfo.coordinates.y - 1), WallType.SOUTH)) {
                                setUnitX(_unit.x - _unitInfo.speed);
                                return;
                            }
                        else setUnitY(newY);
                    else
                        setUnitY(newY);
                }
                // Если стена существует, проверим, не можем ли мы сквозь нее пройти
                // Проход сквозь стены, ограничивающие уровень, ограничивается вторым услонием (проверкой координат игрока).
                else {
                    if (_model.throughWallDistance > 0 && _unitInfo.coordinates.y != 0)
                        setUnitY(newY);
                }
                if (ceilCenterY - _unit.y > MapCeilView.CELL_SIZE / 2)
                    --_unitInfo.coordinates.y;
            }
            else
                tryToBitEnemy(hitedUnit);
        }
        
        private function goDown():void {
            var hitedUnit:DisplayObject = checkUnitsHitTest();
            if (!hitedUnit) {
                var newY:Number = _unit.y + _unitInfo.speed;
                var ceilCenterY:Number = _unitInfo.coordinates.y * MapCeilView.CELL_SIZE + MapCeilView.CELL_SIZE / 2;
                var ceilCenterX:Number = _unitInfo.coordinates.x * MapCeilView.CELL_SIZE + MapCeilView.CELL_SIZE / 2;
                
                if (newY - ceilCenterY <= WAY_THICKNESS)
                    setUnitY(newY);
                else if (checkDirection(WallType.SOUTH)) {
                    if (ceilCenterX - _unit.x > WAY_THICKNESS)
                        if (checkWallExist(new Point(_unitInfo.coordinates.x, _unitInfo.coordinates.y + 1), WallType.WEST) ||
                            checkWallExist(new Point(_unitInfo.coordinates.x - 1, _unitInfo.coordinates.y + 1), WallType.NORTH)) {
                                setUnitX(_unit.x + _unitInfo.speed);
                                return;
                            }
                        else setUnitY(newY);
                    else if (_unit.x - ceilCenterX > WAY_THICKNESS)
                        if (checkWallExist(new Point(_unitInfo.coordinates.x, _unitInfo.coordinates.y + 1), WallType.EAST) ||
                            checkWallExist(new Point(_unitInfo.coordinates.x + 1, _unitInfo.coordinates.y + 1), WallType.NORTH))  {
                                setUnitX(_unit.x - _unitInfo.speed);
                                return;
                            }
                        else setUnitY(newY);
                    else
                        setUnitY(newY);
                }
                // Если стена существует, проверим, не можем ли мы сквозь нее пройти
                else {
                    if (_model.throughWallDistance > 0 && _unitInfo.coordinates.y != (_model.map.length - 1))
                        setUnitY(newY);
                }
                if (_unit.y - ceilCenterY > MapCeilView.CELL_SIZE / 2)
                    ++_unitInfo.coordinates.y;
            }
            else
                tryToBitEnemy(hitedUnit);
        }
        
        private function goLeft():void {
            var hitedUnit:DisplayObject = checkUnitsHitTest();
            if (!hitedUnit) {
                var newX:Number = _unit.x - _unitInfo.speed;
                var ceilCenterX:Number = _unitInfo.coordinates.x * MapCeilView.CELL_SIZE + MapCeilView.CELL_SIZE / 2;
                var ceilCenterY:Number = _unitInfo.coordinates.y * MapCeilView.CELL_SIZE + MapCeilView.CELL_SIZE / 2;
                
                if (ceilCenterX - newX <= WAY_THICKNESS)
                    setUnitX(newX);
                else if (checkDirection(WallType.WEST)) {
                    if (ceilCenterY - _unit.y > WAY_THICKNESS)
                        if (checkWallExist(new Point(_unitInfo.coordinates.x - 1, _unitInfo.coordinates.y), WallType.NORTH) ||
                            checkWallExist(new Point(_unitInfo.coordinates.x - 1, _unitInfo.coordinates.y - 1), WallType.EAST)) {
                                setUnitY(_unit.y + _unitInfo.speed);
                                return;
                            }
                        else setUnitX(newX);
                    else if (_unit.y - ceilCenterY > WAY_THICKNESS)
                        if (checkWallExist(new Point(_unitInfo.coordinates.x - 1, _unitInfo.coordinates.y), WallType.SOUTH) ||
                            checkWallExist(new Point(_unitInfo.coordinates.x - 1, _unitInfo.coordinates.y + 1), WallType.EAST)) {
                                setUnitY(_unit.y - _unitInfo.speed);
                                return;
                            }
                        else setUnitX(newX);
                    else
                        setUnitX(newX);
                }
                // Если стена существует, проверим, не можем ли мы сквозь нее пройти
                else {
                    if (_model.throughWallDistance > 0 && _unitInfo.coordinates.x != 0)
                        setUnitX(newX);
                }
                if (ceilCenterX - _unit.x > MapCeilView.CELL_SIZE / 2)
                    --_unitInfo.coordinates.x;
            }
            else
                tryToBitEnemy(hitedUnit);
        }
        
        private function goRight():void {
            var hitedUnit:DisplayObject = checkUnitsHitTest();
            if (!hitedUnit) {
                var newX:Number = _unit.x + _unitInfo.speed;
                var ceilCenterX:Number = _unitInfo.coordinates.x * MapCeilView.CELL_SIZE + MapCeilView.CELL_SIZE / 2;
                var ceilCenterY:Number = _unitInfo.coordinates.y * MapCeilView.CELL_SIZE + MapCeilView.CELL_SIZE / 2;
                
                if (newX - ceilCenterX <= WAY_THICKNESS)
                    setUnitX(newX);
                else if (checkDirection(WallType.EAST)) {
                    if (ceilCenterY - _unit.y > WAY_THICKNESS)
                        if (checkWallExist(new Point(_unitInfo.coordinates.x + 1, _unitInfo.coordinates.y), WallType.NORTH) ||
                            checkWallExist(new Point(_unitInfo.coordinates.x + 1, _unitInfo.coordinates.y - 1), WallType.WEST)) {
                                setUnitY(_unit.y + _unitInfo.speed);
                                return;
                            }
                        else setUnitX(newX);
                    else if (_unit.y - ceilCenterY > WAY_THICKNESS)
                        if (checkWallExist(new Point(_unitInfo.coordinates.x + 1, _unitInfo.coordinates.y), WallType.SOUTH) ||
                            checkWallExist(new Point(_unitInfo.coordinates.x + 1, _unitInfo.coordinates.y + 1), WallType.WEST)) {
                                setUnitY(_unit.y - _unitInfo.speed);
                                return;
                            }
                        else setUnitX(newX);
                    else
                        setUnitX(newX);
                }
                // Если стена существует, проверим, не можем ли мы сквозь нее пройти
                else {
                    if (_model.throughWallDistance > 0 && _unitInfo.coordinates.x != ((_model.map[0] as Array).length - 1)) {
                        setUnitX(newX);
                    }
                }
                if (_unit.x - ceilCenterX > MapCeilView.CELL_SIZE / 2)
                    ++_unitInfo.coordinates.x;
            }
            else
                tryToBitEnemy(hitedUnit);
        }
        
        private function setUnitX(value:Number):void {
            if (_unit.parent)
                _mainView.centerViewByPlayer();
            if (_unit.x > value) _unit.turn(3);
            else _unit.turn(1);
            _unit.x = value;
            if (_model.throughWallDistance > 0)
                _model.throughWallDistance -= _unitInfo.speed;
        }
        
        private function setUnitY(value:Number):void {
            if (_unit.parent)
                _mainView.centerViewByPlayer();
            if (_unit.y < value) _unit.turn(2);
            else _unit.turn(0);
            _unit.y = value;
            if (_model.throughWallDistance > 0)
                _model.throughWallDistance -= _unitInfo.speed;
        }
        
        /**
         * Checking direction for existing wall or not. According unit coordinates.
         * @return              True if way is free. There isn't wall.
         */
        private function checkDirection(direction:int):Boolean {
            var ceil:MapCellModel = _model.map[_unitInfo.coordinates.y][_unitInfo.coordinates.x] as MapCellModel;
            if (ceil) {
                var isExist:Boolean = Boolean(ceil.walls[direction]);
                if (isExist) {
                    if ((ceil.walls[direction] as Wall).type == WallType.NORMAL) return false;
                    else if (_model.keys.indexOf((ceil.walls[direction] as Wall).keyColor) >= 0) {
                        // Запомним цвет ключа
                        var keyColor:String = (ceil.walls[direction] as Wall).keyColor;
                        ceil.dispatchEvent(new UserEvent(UserEvent.OPEN_DOOR, direction));
                        ceil.walls[direction] = null;
                        // Убираем соседствующую стену
                        if (direction == 0) ceil = _model.map[_unitInfo.coordinates.y - 1][_unitInfo.coordinates.x] as MapCellModel;
                        else if (direction == 1) ceil = _model.map[_unitInfo.coordinates.y][_unitInfo.coordinates.x + 1] as MapCellModel;
                        else if (direction == 2) ceil = _model.map[_unitInfo.coordinates.y + 1][_unitInfo.coordinates.x] as MapCellModel;
                        else if (direction == 3) ceil = _model.map[_unitInfo.coordinates.y][_unitInfo.coordinates.x - 1] as MapCellModel;
                        
                        ((direction + 2) > 3) ? direction -= 2 : direction += 2;
                        ceil.dispatchEvent(new UserEvent(UserEvent.OPEN_DOOR, direction));
                        ceil.walls[direction] = null;
                        
                        // Кроме убирания стены в этой и соседней клетке, убираем и ключ у игрока
                        _model.keys.splice(_model.keys.indexOf(keyColor), 1);
                        _unitInfo.dispatchEvent(new UserEvent(UserEvent.KEY_SPEND, keyColor));
                        
                        return true;
                    }
                    else return false;
                }
                else return true;
            }
            else return true;
        }
        
        /**
         * Checking existing wall in stated ceil and direction.
         * @param	ceil        Point contained ceil coordinates.
         * @return              True if wall exist. False if wall or ceil doesn't exist.
         */
        private function checkWallExist(ceil:Point, direction:int):Boolean {
            var ceilInfo:MapCellModel = _model.map[ceil.y][ceil.x] as MapCellModel;
            if (!ceilInfo) return false;
            var isExist:Boolean = Boolean(ceilInfo.walls[direction]);
            return isExist;
        }
        
        override protected function kill():void {
            super.kill();
            _stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyUpDownHandler);
            _stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpDownHandler);
            stopPlayerMoving();
            _unit.drawDeath();
            Dispatcher.instance.dispatchEvent(new UserEvent(UserEvent.PLAYER_IS_DEAD));
        }
        
        private function stopPlayerMoving():void {
            _upPressed = _downPressed = _rightPressed = _leftPressed = false;
        }
        
        /**
         * Check hit test with all other units.
         * @return  Hited unit.
         */
        private function checkUnitsHitTest():DisplayObject {
            var units:Array = _unit.allUnits;
            for (var i:int = 0; i < units.length; i++) {
                var unit:UnitViewBase = units[i] as UnitViewBase;
                var unitInfo:UnitModel =  _model.unitsDict[unit] as UnitModel;
                var type:int = unitInfo.type;
                var distance:Number = getDistance(_unit.x, _unit.y, unit.x, unit.y);
                if (type != UnitType.VAMPIR && type != UnitType.GHOUL && unitInfo.hitPoints > 0 && 
                    unit.frontDirection == this._frontDirection && 
                    distance <= UnitController.BIT_DISTANSE) {
                        return units[i] as DisplayObject;
                    }
            }
            return null;
        }
        
        override protected function destroy(event:UserEvent = null):void {
            super.destroy();
            _movingTimer.removeEventListener(TimerEvent.TIMER, movingTimerHandler);
            _movingTimer.stop();
            _stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyUpDownHandler);
            _stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpDownHandler);
        }
    }
}
