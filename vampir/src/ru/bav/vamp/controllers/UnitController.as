package ru.bav.vamp.controllers {
	import com.greensock.TimelineLite;
    import com.greensock.TweenLite;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import ru.bav.vamp.models.MainModel;
    import ru.bav.vamp.models.MapCellModel;
    import ru.bav.vamp.models.UnitModel;
    import ru.bav.vamp.views.units.UnitViewBase;
    import ru.bav.vamp.models.consts.WallType;
    import ru.bav.vamp.views.MapCeilView;
    import ru.bav.vamp.events.UserEvent;
    import ru.bav.vamp.models.consts.UnitType;
    import ru.bav.vamp.models.consts.BulletType;
	/**
     * Basic controller for units.
     * @author bav
     */
    public class UnitController {
        public static const BECAME_GHOUL_DELAY_IN_SEC:Number = 1.5;
        public static const FAT_SLOWING_DELAY:Number = 5000;
        public static var BIT_DISTANSE:int = 0;
        
        // Model object.
        protected var _model:MainModel;
        // View object.
        protected var _unit:UnitViewBase;
        // UnitModel info.
        protected var _unitInfo:UnitModel;
        // Last direction which unit came from. Back direction.
        protected var _backDirection:int = -1;
        // Front direction.
        protected var _frontDirection:int = 2;
        // Current TweenLite motion
        protected var _tweelLite:TweenLite;
		// Таймер замедления
		protected var _slowDownTimer:Timer;
        
        public function UnitController(model:MainModel, unitInfo:UnitModel, view:UnitViewBase) {
			if (!BIT_DISTANSE)
				BIT_DISTANSE = MapCeilView.CELL_SIZE / 2;
            _model = model;
            _unit = view;
            _unitInfo = unitInfo;
			// Устанавливаем начальное значение скорости юнита.
			_unitInfo.speed = getNormalUnitSpeed(_unitInfo.type);
			_slowDownTimer = new Timer(FAT_SLOWING_DELAY, 1);
			_slowDownTimer.addEventListener(TimerEvent.TIMER_COMPLETE, restoreSpeed);
        }
        
        protected function initView():void {
            _unit.x = _unitInfo.coordinates.x * MapCeilView.CELL_SIZE + MapCeilView.CELL_SIZE / 2;
            _unit.y = _unitInfo.coordinates.y * MapCeilView.CELL_SIZE + MapCeilView.CELL_SIZE / 2;
            _unit.addEventListener(UserEvent.UNIT_SHOOTED, shootedHandler);
            _unit.addEventListener(UserEvent.UNIT_KILLED, killUnit);
            _unit.addEventListener(UserEvent.DESTROY_UNIT, destroy);
        }
        
        /**
         * Choise direction on the assumption of the walls in current ceil.
         * @return
         */
        protected function choiseRandomDirection():int {
            var ceilInfo:MapCellModel = _model.map[_unitInfo.coordinates.y][_unitInfo.coordinates.x] as MapCellModel;
            if (!ceilInfo) return -1;
            var holesIds:Array = [];
			var length:int = ceilInfo.walls.length;
            for (var i:int = 0; i < length; i++)
                if (!ceilInfo.walls[i] && i != _backDirection)
                    holesIds.push(i);
            
			var holesCount:int = holesIds.length;
            var nextDirectionId:int = holesCount ? holesIds[int(Math.random() * holesCount)] : _backDirection;
            if (!holesCount && ceilInfo.walls[_backDirection]) return -1;
            if (nextDirectionId < 0) return -1;
            if (nextDirectionId + 2 < 4)
                _backDirection = nextDirectionId + 2;
            else
                _backDirection = nextDirectionId - 2;
            return nextDirectionId;
        }
        
        /**
         * Calculate count of ceils to nearest wall or crossroads.
         * @return              Ceils count.
         */
        protected function calculateWayLength(direction:int):int {
            var directionId:int = direction;
            var leftDirection:int = (directionId - 1 < 0) ? 3 : directionId - 1;
            var rightDirection:int = (directionId + 1 == 4) ? 0 : directionId + 1;
            
            var iterator:int = (directionId == 1 || directionId == 2) ? 1 : -1;
            var startCeilCoordinate:int;
            var endCeilCoordinate:int;
            var nextCeil:MapCellModel;
            var ceilsCount:int = 1;
            if (directionId == 0 || directionId == 2) {
                startCeilCoordinate = _unitInfo.coordinates.y;
                endCeilCoordinate = (iterator > 0) ? _model.map.length : 0;
                for (var i:int = startCeilCoordinate + iterator; (iterator > 0) ? i < endCeilCoordinate : i >= endCeilCoordinate; i += iterator) {
                    nextCeil = _model.map[i][_unitInfo.coordinates.x] as MapCellModel;
                    if (!nextCeil.walls[directionId] && nextCeil.walls[leftDirection] && nextCeil.walls[rightDirection])
                        ceilsCount++;
                    else break;
                }
            }
            else {
                startCeilCoordinate = _unitInfo.coordinates.x;
                endCeilCoordinate = (iterator > 0) ? (_model.map[_unitInfo.coordinates.y] as Array).length : 0;
                for (var j:int = startCeilCoordinate + iterator; (iterator > 0) ? j < endCeilCoordinate : j >= endCeilCoordinate; j += iterator) {
                    nextCeil = _model.map[_unitInfo.coordinates.y][j] as MapCellModel;
                    if (!nextCeil.walls[directionId] && nextCeil.walls[leftDirection] && nextCeil.walls[rightDirection])
                        ceilsCount++;
                    else break;
                }
            }
            return ceilsCount;
        }
        
        
        public static function calculateCeilsCountToNearestWall(_model:MainModel, direction:int, fromX:int = -1, fromY:int = -1):int {
            var directionId:int = direction;
			var _x:int = fromX;
			var _y:int = fromY;
            
            var iterator:int = (directionId == 1 || directionId == 2) ? 1 : -1;
            var startCeilCoordinate:int;
            var endCeilCoordinate:int;
            var nextCeil:MapCellModel;
            var ceilsCount:int = 1;
            if (directionId == 0 || directionId == 2) {
                startCeilCoordinate = _y;
                endCeilCoordinate = (iterator > 0) ? _model.map.length : 0;
                for (var i:int = startCeilCoordinate; (iterator > 0) ? i < endCeilCoordinate : i >= endCeilCoordinate; i += iterator) {
                    nextCeil = _model.map[i][_x] as MapCellModel;
                    if (!nextCeil) break;
                    if (!nextCeil.walls[directionId])
                        ceilsCount++;
                    else break;
                }
            }
            else {
                startCeilCoordinate = _x;
                endCeilCoordinate = (iterator > 0) ? (_model.map[_y] as Array).length : 0;
                for (var j:int = startCeilCoordinate; (iterator > 0) ? j < endCeilCoordinate : j >= endCeilCoordinate; j += iterator) {
                    nextCeil = _model.map[_y][j] as MapCellModel;
                    if (!nextCeil) break;
                    if (!nextCeil.walls[directionId])
                        ceilsCount++;
                    else break;
                }
            }
            return ceilsCount;
        }
        
        
        protected function slowDown():void {
            _slowDownTimer.reset();
			_unitInfo.speed /= 2;
            _slowDownTimer.start();
        }
        
        protected function restoreSpeed(event:TimerEvent):void {
            if (_unitInfo) _unitInfo.speed = getNormalUnitSpeed(_unitInfo.type);
        }
		
        protected function shootedHandler(event:UserEvent):void {
            var damage:int;
            if (event.data == BulletType.BULLET) damage = 1;
            else if (event.data == BulletType.STAKE) damage = 3;
            else if (event.data == BulletType.DOUGHNUT) {
                slowDown();
                damage = 0;
			}
            if (_unitInfo.type != UnitType.WEREWOLF) {
                _unitInfo.hitPoints -= damage;
                _unitInfo.dispatchEvent(new Event(Event.CHANGE));
            }
            else if (event.data == BulletType.STAKE) {
                _unitInfo.hitPoints -= damage;
                _unitInfo.dispatchEvent(new Event(Event.CHANGE));
            }
            if (_unitInfo.hitPoints <= 0)
                killUnit();
        }
        
        private function killUnit(event:UserEvent = null):void {
            var type:int = (_model.unitsDict[_unit as UnitViewBase] as UnitModel).type;
            if (type == UnitType.CIVIL || type == UnitType.HUNTER || type == UnitType.POLICEMAN)
                _model.civilsCount--;
            else if (type == UnitType.GHOUL)
                _model.ghoulsCount--;
            kill();
            _unitInfo.hitPoints = 0;
            _model.dispatchEvent(new Event(Event.CHANGE));
        }
        
        /**
         * Останавливаем персонажа если его убили.
         */
        protected function kill():void {
            _unit.removeEventListener(UserEvent.UNIT_SHOOTED, shootedHandler);
        }
        
        /**
         * Уничтожаем вьюшку и персонажа целиком и полностью.
         * @param	event
         */
        protected function destroy(event:UserEvent = null):void {
            delete _model.unitsDict[_unit];
            TweenLite.killTweensOf(_unit);
            if (_unit.parent)
                _unit.parent.removeChild(_unit);
        }
		
		public static function getNormalUnitSpeed(unitType:int):Number
		{
			// Скорость персонажей будет зависить от размера ячейки,
			// пока мы хотим иметь возможность варьировать размер ячейки.
			var speed:Number = 0;
			if (unitType == UnitType.VAMPIR) speed = 8;
			else if (unitType == UnitType.CIVIL ||
					 unitType == UnitType.GHOUL ||
					 unitType == UnitType.POLICEMAN ||
					 unitType == UnitType.HUNTER ||
					 unitType == UnitType.WEREWOLF) speed = 1;
			else if (unitType == UnitType.FAT_POLICEMAN) speed = 0.5;
			return speed;
		}
    }
}
