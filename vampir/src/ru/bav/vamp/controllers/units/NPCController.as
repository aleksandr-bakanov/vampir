package ru.bav.vamp.controllers.units {
    import com.greensock.*;
    import com.greensock.easing.*;
    import com.greensock.plugins.*;
    import flash.display.*;
    import flash.events.*;
    import flash.utils.*;
    import ru.bav.vamp.controllers.*;
    import ru.bav.vamp.controllers.items.*;
    import ru.bav.vamp.events.*;
    import ru.bav.vamp.models.*;
    import ru.bav.vamp.models.consts.*;
    import ru.bav.vamp.views.*;
    import ru.bav.vamp.views.items.*;
    import ru.bav.vamp.views.units.*;
	
	/**
     * NPC controller.
     * @author bav
     */
    public class NPCController extends UnitController {
        public static const ROTATION_DELAY_IN_SEC:Number = 0.25;
        public static const LOOKING_DELAY:Number = 200;
        public static const SHOOT_DELAY:int = 1000;
        public static const SET_OWN_COORDINATES_DELAY:int = 100;
        
        protected var _lookingTimer:Timer;
        protected var _ceilsToMove:int;
        
        protected var _coordinatesTimer:Timer;
        protected var _waitingTimer:Timer;
        
        public function NPCController(model:MainModel, unitInfo:UnitModel, view:UnitViewBase) {
            super(model, unitInfo, view);
            addViewListeners();
            initView();
            initCoordinatesTimer();
            initWaitingTimer();
            if (unitInfo.type != UnitType.VAMPIR && unitInfo.type != UnitType.CIVIL)
                initLookingTimer();
            nextMove();
        }
        
        protected function initCoordinatesTimer():void {
            _coordinatesTimer = new Timer(SET_OWN_COORDINATES_DELAY);
            _coordinatesTimer.addEventListener(TimerEvent.TIMER, setOwnCoordinates);
            _coordinatesTimer.start();
        }
        
        protected function initWaitingTimer():void {
            _waitingTimer = new Timer(500, 1);
            _waitingTimer.addEventListener(TimerEvent.TIMER_COMPLETE, nextMove);
        }
        
        /**
         * Function refresh unit coordinates in model every SET_OWN_COORDINATES_DELAY milliseconds.
         * Coordinates means ceil's coordinates.
         * @param	event
         */
        private function setOwnCoordinates(event:TimerEvent):void {
			var newX:int = int(_unit.x / MapCeilView.CELL_SIZE);
			if (newX < 0) newX = 0;
			else if (newX >= _model.mapWidth) newX = _model.mapWidth - 1;
			var newY:int = int(_unit.y / MapCeilView.CELL_SIZE);
			if (newY < 0) newY = 0;
			else if (newY >= _model.mapHeight) newY = _model.mapHeight - 1;
            _unitInfo.coordinates.x = newX;
            _unitInfo.coordinates.y = newY;
        }
        
        protected function addViewListeners():void {
            if (_unitInfo.type != UnitType.GHOUL)
                _unit.addEventListener(UserEvent.UNIT_BITTEN, unitBittenHandler);
            _unit.addEventListener(UserEvent.STOP_MOVING, stopMovingHandler);
            _unit.addEventListener(UserEvent.START_MOVING, startMovingHandler);
        }
        
        private function startMovingHandler(event:UserEvent):void {
            nextMove();
        }
        
        private function stopMovingHandler(event:UserEvent):void {
            TweenLite.killTweensOf(_unit);
        }
        
        /**
         * Ouch! UnitModel was bitten by vampire! Need convert him into gho-o-oul...
         * @param	event
         */
        protected function unitBittenHandler(event:UserEvent):void {
            if (_tweelLite)
                _tweelLite.pause();
            _unit.becameGhoul();
            _unitInfo.type = UnitType.GHOUL;
            
            if (_lookingTimer) {
                _lookingTimer.reset();
                _lookingTimer.removeEventListener(TimerEvent.TIMER, lookForVampire);
            }
            var timer:Timer = new Timer(BECAME_GHOUL_DELAY_IN_SEC * 1000, 1);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, startGhouling);
            timer.start();
        }
        
        /**
         * Function continue unit moving after his convertion into ghoul.
         * @param	event
         */
        protected function startGhouling(event:Event = null):void {
            if (event)
                (event.target as Timer).removeEventListener(TimerEvent.TIMER_COMPLETE, startGhouling);
            _model.ghoulsCount++;
            _model.civilsCount--;
            if (_unitInfo.hitPoints > 0) {
                if (!_lookingTimer) _lookingTimer = new Timer(LOOKING_DELAY);
                _lookingTimer.addEventListener(TimerEvent.TIMER, lookForVictim);
                _lookingTimer.start();
                if (_tweelLite)
                    _tweelLite.play();
            }
        }
        
        protected function initLookingTimer():void {
            _lookingTimer = new Timer(LOOKING_DELAY);
            if (_unitInfo.type != UnitType.WEREWOLF && _unitInfo.type != UnitType.GHOUL)
                _lookingTimer.addEventListener(TimerEvent.TIMER, lookForVampire);
            else
                _lookingTimer.addEventListener(TimerEvent.TIMER, lookForVictim);
        }
        
        /**
         * Stops lookingTimer (stop looking for enemyes till rotation ends).
         * Choise next random direction and init rotation to it.
         */
        protected function nextMove(event:TimerEvent = null):void {
            //if (event) event.target.removeEventListener(TimerEvent.TIMER_COMPLETE, nextMove);
            if (_waitingTimer && _waitingTimer.running) _waitingTimer.reset();
            
            // Stop looking for vampire or victim until rotate
            if (_lookingTimer)
                _lookingTimer.stop();
            
            // Используем _coordinatesTimer как флаг (ему присваивается значение null
            // в функции destroy()
            if (!_coordinatesTimer) return;
            
            _frontDirection = choiseRandomDirection();
            if (_frontDirection < 0) {
                _waitingTimer.reset();
                _waitingTimer.start();
                return;
            }
            rotateByDirection(_frontDirection);
        }
        
        /**
         * Begin rotate (if need) to next direction on crossroad.
         * Then start moving by choisen direction.
         * @param direction     Randomly choisen direction.
         */
        protected function rotateByDirection(direction:int):void {
            _unit.turn(direction);
            goForward();
        }
        
        /**
         * Initialize next move to neares crossroad or wall.
         * Calculate way length, save it in private field for makeNextStep() function.
         */
        protected function goForward():void {
            _unit.frontDirection = _frontDirection;
            _ceilsToMove = calculateWayLength(_frontDirection);
            makeNextStep();
        }
        
        /**
         * Start moving to next ceil. This function repeats while _ceilsToMove isn't zero.
         * Else, after last moving, calls nextMovie function().
         */
        protected function makeNextStep():void {
            var onCompleteFunction:Function = (--_ceilsToMove) ? makeNextStep : nextMove;
            var time:Number = 1 / _unitInfo.speed;
            
            TweenLite.killTweensOf(_unit);
            
            if (_frontDirection == 0) {
                _tweelLite = TweenLite.to(_unit, time, { y:_unit.y - MapCeilView.CELL_SIZE, ease:Linear.easeNone, onComplete:onCompleteFunction } );
            }
            else if (_frontDirection == 1) {
                _tweelLite = TweenLite.to(_unit, time, { x:_unit.x + MapCeilView.CELL_SIZE, ease:Linear.easeNone, onComplete:onCompleteFunction } );
            }
            else if (_frontDirection == 2) {
                _tweelLite = TweenLite.to(_unit, time, { y:_unit.y + MapCeilView.CELL_SIZE, ease:Linear.easeNone, onComplete:onCompleteFunction } );
            }
            else if (_frontDirection == 3) {
                _tweelLite = TweenLite.to(_unit, time, { x:_unit.x - MapCeilView.CELL_SIZE, ease:Linear.easeNone, onComplete:onCompleteFunction } );
            }
            
            // Start looking for vampire or victim
            if (_lookingTimer && !_lookingTimer.running)
                _lookingTimer.start();
        }
        
        /**
         * Looks for vampire or ghoul by front direction to nearest wall.
         * @param	event
         */
        protected function lookForVampire(event:TimerEvent = null):void {
            if (_lookingTimer.delay == SHOOT_DELAY) _lookingTimer.delay = LOOKING_DELAY;
            
            var indexOfDirection:int = _frontDirection;
            var ceilsCount:int = UnitController.calculateCeilsCountToNearestWall(_model, _frontDirection, int(_unitInfo.coordinates.x), int(_unitInfo.coordinates.y));
            var xCoord:int = _unitInfo.coordinates.x;
            var yCoord:int = _unitInfo.coordinates.y;
            var ceil:MapCellModel = _model.map[yCoord][xCoord] as MapCellModel;
            
            while (ceilsCount--) {
                for (var i:int = 0; i < _model.units.length; i++) {
                    var unit:UnitModel = _model.units[i] as UnitModel;
                    if ((unit.type == UnitType.VAMPIR || unit.type == UnitType.GHOUL || unit.type == UnitType.WEREWOLF) && !unit.invisible && unit.hitPoints > 0 && xCoord == unit.coordinates.x && yCoord == unit.coordinates.y && _tweelLite)
                        if (!(_unitInfo.coordinates.x == unit.coordinates.x && _unitInfo.coordinates.y == unit.coordinates.y)) {
                            _tweelLite.pause();
                            shoot();
                            return;
                        }
                }
                if (_frontDirection == WallType.NORTH && --yCoord >= 0)
                    ceil = _model.map[yCoord][xCoord] as MapCellModel;
                else if (_frontDirection == WallType.SOUTH && ++yCoord < _model.map.length)
                    ceil = _model.map[yCoord][xCoord] as MapCellModel;
                else if (_frontDirection == WallType.EAST && ++xCoord < (_model.map[yCoord] as Array).length)
                    ceil = _model.map[yCoord][xCoord] as MapCellModel;
                else if (_frontDirection == WallType.WEST && --xCoord >= 0)
                    ceil = _model.map[yCoord][xCoord] as MapCellModel;
            }
            if (_tweelLite)
                _tweelLite.play();
        }
        
        /**
         * Function looking for victim when NPC is ghoul.
         * @param	event
         */
        protected function lookForVictim(event:TimerEvent):void {
            if (_lookingTimer.delay == SHOOT_DELAY) _lookingTimer.delay = LOOKING_DELAY;
            
            var unitsCount:int = _unit.allUnits.length;
            for (var i:int = 0; i < unitsCount; i++) {
                var unit:UnitViewBase = _unit.allUnits[i] as UnitViewBase;
                var unitInfo:UnitModel = _model.unitsDict[unit] as UnitModel;
                
                // Реагируем только на живых
                if (unitInfo && unitInfo.hitPoints > 0) {
                    var timer:Timer;
                    if (_unitInfo.type == UnitType.GHOUL) {
                        if (unitInfo.type != UnitType.VAMPIR && unitInfo.type != UnitType.GHOUL && unitInfo.type != UnitType.WEREWOLF &&
                        PlayerController.getDistance(_unit.x, _unit.y, unit.x, unit.y) <= UnitController.BIT_DISTANSE) {
                            unit.dispatchEvent(new UserEvent(UserEvent.UNIT_BITTEN));
                            // Если это был толстый полицейский временно снижаем скорость
                            if (unitInfo.type == UnitType.FAT_POLICEMAN)
                                slowDown();
                            if (_tweelLite)
                                _tweelLite.pause();
                            _lookingTimer.stop();
                            timer = new Timer(BECAME_GHOUL_DELAY_IN_SEC * 1e3, 1);
                            timer.addEventListener(TimerEvent.TIMER_COMPLETE, continueGhouling);
                            timer.start();
                        }
                    }
                    else if (_unitInfo.type == UnitType.WEREWOLF) {
                        if (unitInfo.type != UnitType.WEREWOLF && 
                        PlayerController.getDistance(_unit.x, _unit.y, unit.x, unit.y) <= UnitController.BIT_DISTANSE){
                            unit.dispatchEvent(new UserEvent(UserEvent.UNIT_KILLED));
                            if (_tweelLite)
                                _tweelLite.pause();
                            _lookingTimer.stop();
                            timer = new Timer(BECAME_GHOUL_DELAY_IN_SEC * 1e3, 1);
                            timer.addEventListener(TimerEvent.TIMER_COMPLETE, continueGhouling);
                            timer.start();
                        }
                    }
                }
            }
        }
        
        /**
         * Function continue ghouling after eating one victim.
         * @param	event
         */
        protected function continueGhouling(event:Event = null):void {
            (event.target as EventDispatcher).removeEventListener(TimerEvent.TIMER_COMPLETE, continueGhouling);
            if (_unitInfo.hitPoints > 0) {
                if (_tweelLite)
                    _tweelLite.play();
                _lookingTimer.start();
            }
        }
        
        /**
         * Shoot to front direction.
         * Change _lookingTimer.delay for pause before continue moving.
         */
        protected function shoot():void {
            _lookingTimer.delay = SHOOT_DELAY;
            _unit.shoot(_frontDirection);
            
            var bulletType:int;
            if (_unitInfo.type == UnitType.POLICEMAN) bulletType = BulletType.BULLET;
            else if (_unitInfo.type == UnitType.HUNTER) bulletType = BulletType.STAKE;
            else if (_unitInfo.type == UnitType.FAT_POLICEMAN) bulletType = BulletType.DOUGHNUT;
            
            var bullet:Bullet = new Bullet(bulletType);
            if (_frontDirection == WallType.NORTH) bullet.setCoordinates(_unit.x, _unit.y - MapCeilView.CELL_SIZE / 2);
            else if (_frontDirection == WallType.EAST) bullet.setCoordinates(_unit.x + MapCeilView.CELL_SIZE / 2, _unit.y);
            else if (_frontDirection == WallType.WEST) bullet.setCoordinates(_unit.x - MapCeilView.CELL_SIZE / 2, _unit.y);
            else if (_frontDirection == WallType.SOUTH) bullet.setCoordinates(_unit.x, _unit.y + MapCeilView.CELL_SIZE / 2);
            (_unit.parent as DisplayObjectContainer).addChild(bullet);
            
            new BulletController(_model, bullet, _frontDirection, bulletType, _unit.allUnits);
        }
        
        override protected function kill():void {
            super.kill();
            if (_lookingTimer) {
                _lookingTimer.reset();
                _lookingTimer.removeEventListener(TimerEvent.TIMER, lookForVampire);
                _lookingTimer.removeEventListener(TimerEvent.TIMER, lookForVictim);
            }
            TweenLite.killTweensOf(_unit);
            //if (_tweelLite)
                //_tweelLite.pause();
                
            _unit.removeEventListener(UserEvent.UNIT_SHOOTED, shootedHandler);
            _unit.removeEventListener(UserEvent.UNIT_BITTEN, unitBittenHandler);
            _unit.drawDeath();
        }
        
        override protected function destroy(event:UserEvent = null):void {
            super.destroy();
            if (_lookingTimer) {
                _lookingTimer.reset();
                _lookingTimer.removeEventListener(TimerEvent.TIMER, lookForVampire);
                _lookingTimer.removeEventListener(TimerEvent.TIMER, lookForVictim);
            }
            if (_coordinatesTimer) {
                _coordinatesTimer.removeEventListener(TimerEvent.TIMER, setOwnCoordinates);
                _coordinatesTimer.reset();
                _coordinatesTimer = null;
            }
            if (_waitingTimer) {
                _waitingTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, nextMove);
                _waitingTimer = null;
            }
            _unit.removeEventListener(UserEvent.UNIT_SHOOTED, shootedHandler);
            _unit.removeEventListener(UserEvent.UNIT_BITTEN, unitBittenHandler);
        }
    }
}
