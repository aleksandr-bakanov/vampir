package ru.bav.vamp.controllers.items {
	import com.greensock.easing.Linear;
    import com.greensock.loading.core.DisplayObjectLoader;
	import com.greensock.TweenLite;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
	import ru.bav.vamp.controllers.Dispatcher;
    import ru.bav.vamp.events.UserEvent;
    import ru.bav.vamp.models.consts.WallType;
    import ru.bav.vamp.models.MainModel;
    import ru.bav.vamp.models.MapCellModel;
    import ru.bav.vamp.models.UnitModel;
    import ru.bav.vamp.views.MainView;
    import ru.bav.vamp.views.units.UnitViewBase;
    import ru.bav.vamp.models.consts.UnitType;
    import ru.bav.vamp.views.MapCeilView;
    import ru.bav.vamp.views.WallView;
    import ru.bav.vamp.models.consts.BulletType;
    import ru.bav.vamp.controllers.UnitController;
    import ru.bav.vamp.controllers.units.PlayerController;
	/**
     * Controller of all bullet types.
     * @author bav
     */
    public class BulletController {
        public static const WALL_COLLISION:int = 1;
        public static const VAMPIR_COLLISION:int = 2;
        public static const FRIEND_COLLISION:int = 3;
        public static const NONE_COLLISION:int = 4;
        
        public static const SPEED:int = 10;
        public static const TIMER_DELAY:int = 200;
        
        protected var _allUnits:/*UnitViewBase*/Array;
        protected var _model:MainModel;
        protected var _view:DisplayObject;
        protected var _direction:int;
        
        public var type:int;
        
        protected var _movingTimer:Timer;
		protected var _tweenlite:TweenLite;
        
        /**
         * Create bullet controller instance.
         * @param	model       Main model
         * @param	view        Bullet view
         * @param	direction   Direction string
         * @param	allUnits    Array of UnitViewBase (_units in MainView instance).
         */
        public function BulletController(model:MainModel, view:DisplayObject, direction:int, type:int, allUnits:Array) {
            this.type = type;
            _model = model;
            _allUnits = allUnits;
            _view = view;
			if (direction == WallType.NORTH) _view.rotation = -90;
			else if (direction == WallType.SOUTH) _view.rotation = 90;
			else if (direction == WallType.WEST) _view.rotation = 180;
            _direction = direction;
			Dispatcher.instance.addEventListener(UserEvent.DOOR_OPENED, doorOpened);
            initMoving();
        }
		
		private function doorOpened(e:UserEvent):void {
			TweenLite.killTweensOf(_view);
			startMoving();
		}
        
        protected function initMoving():void {
            _movingTimer = new Timer(TIMER_DELAY);
            _movingTimer.addEventListener(TimerEvent.TIMER, move);
            _movingTimer.start();
			startMoving();
        }
		
		protected function startMoving():void {
			var modelX:int = int(_view.x / MapCeilView.CELL_SIZE);
			var modelY:int = int(_view.y / MapCeilView.CELL_SIZE);
			var ceilsCount:int = UnitController.calculateCeilsCountToNearestWall(_model, _direction, modelX, modelY);
			// В ceilsCount включена в том числе та ячейка, на которой в данный момент
			// находится пуля. Уберем ее.
			ceilsCount--;
			var dx:Number = 0;
			var dy:Number = 0;
			if (_direction == WallType.EAST) {
				dx = ceilsCount * MapCeilView.CELL_SIZE;
				dx += (int(_view.x / MapCeilView.CELL_SIZE) + 1) * MapCeilView.CELL_SIZE - _view.x;
			}
			else if (_direction == WallType.WEST) {
				dx = -ceilsCount * MapCeilView.CELL_SIZE;
				dx -= _view.x - int(_view.x / MapCeilView.CELL_SIZE) * MapCeilView.CELL_SIZE;
			}
			if (_direction == WallType.SOUTH) {
				dy = ceilsCount * MapCeilView.CELL_SIZE;
				dy += (int(_view.y / MapCeilView.CELL_SIZE) + 1) * MapCeilView.CELL_SIZE - _view.y;
			}
			else if (_direction == WallType.NORTH) {
				dy = -ceilsCount * MapCeilView.CELL_SIZE;
				dy -= _view.y - int(_view.y / MapCeilView.CELL_SIZE) * MapCeilView.CELL_SIZE;
			}
			_tweenlite = TweenLite.to(_view, Number(ceilsCount) / 1.5, { x:_view.x + dx,
				y:_view.y + dy, onComplete:destroy, ease:Linear.easeNone } );
		}
        
        protected function move(event:TimerEvent = null):void {
            if (checkCollision() != NONE_COLLISION) {
                destroy();
                return;
            }
            /*if (_direction == 0) _view.y -= SPEED;
            else if (_direction == 1) _view.x += SPEED;
            else if (_direction == 2) _view.y += SPEED;
            else if (_direction == 3) _view.x -= SPEED;*/
        }
        
        protected function checkCollision():int {
			var unitsCount:int = _allUnits.length;
            for (var i:int = 0; i < unitsCount; i++) {
                var u:UnitViewBase = _allUnits[i] as UnitViewBase;
				var unitInfo:UnitModel = _model.unitsDict[u] as UnitModel;
                if (unitInfo.hitPoints > 0 && PlayerController.getDistance(_view.x, _view.y, u.x, u.y) <= UnitController.BIT_DISTANSE) {
					var unitType:int = unitInfo.type;
                    if ((unitType == UnitType.VAMPIR || unitType == UnitType.GHOUL || unitType == UnitType.WEREWOLF) && !unitInfo.invisible) {
                        u.dispatchEvent(new UserEvent(UserEvent.UNIT_SHOOTED, type));
                        return VAMPIR_COLLISION;
                    }
                    //else if (unitInfo.type == UnitType.POLICEMAN) return NONE_COLLISION;
                }
            }
            /*var ceilX:int = int(_view.x / MapCeilView.CELL_SIZE);
            var ceilY:int = int(_view.y / MapCeilView.CELL_SIZE);
            if (ceilY >= _model.map.length) return WALL_COLLISION;
            if (ceilX >= (_model.map[ceilY] as Array).length) return WALL_COLLISION;
            
            var ceil:MapCellModel = _model.map[ceilY][ceilX] as MapCellModel;
			if (!ceil) return WALL_COLLISION;
            if (_direction == WallType.NORTH && ceil.walls[WallType.NORTH] && (_view.y - ceilY * MapCeilView.CELL_SIZE <= WallView.WALL_THICKNESS)) return WALL_COLLISION;
            else if (_direction == WallType.EAST && ceil.walls[WallType.EAST] && (++ceilX * MapCeilView.CELL_SIZE - _view.x <= WallView.WALL_THICKNESS)) return WALL_COLLISION;
            else if (_direction == WallType.SOUTH && ceil.walls[WallType.SOUTH] && (++ceilY * MapCeilView.CELL_SIZE - _view.y <= WallView.WALL_THICKNESS)) return WALL_COLLISION;
            else if (_direction == WallType.WEST && ceil.walls[WallType.WEST] && (_view.x - ceilX * MapCeilView.CELL_SIZE <= WallView.WALL_THICKNESS)) return WALL_COLLISION;
            */
			return NONE_COLLISION;
        }
        
        protected function destroy():void {
            _movingTimer.stop();
            _movingTimer.removeEventListener(TimerEvent.TIMER, move);
			TweenLite.killTweensOf(_view);
            _model = null;
            _allUnits = null;
            if (_view.parent) _view.parent.removeChild(_view);
            _view = null;
        }
    }
}
