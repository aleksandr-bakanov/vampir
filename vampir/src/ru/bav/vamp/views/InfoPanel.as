package ru.bav.vamp.views {
    import flash.display.DisplayObject;
    import flash.display.Graphics;
	import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
	import flash.events.TimerEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	import ru.bav.vamp.controllers.Dispatcher;
    import ru.bav.vamp.events.UserEvent;
	import ru.bav.vamp.models.consts.KeyColor;
    import ru.bav.vamp.models.MainModel;
    import ru.bav.vamp.models.UnitModel;
	
	/**
     * Info panel, contains player hitPoints, count of ghouls/civils and probably time.
     * @author bav
     */
    public class InfoPanel extends Sprite {
        public static const WIDTH:Number = 500;
        public static const HEIGHT:Number = 30;
        public static const KEY_OFFSET_RED:int = 120;
        public static const KEY_OFFSET_YELLOW:int = 140;
        public static const KEY_OFFSET_GREEN:int = 160;
        public static const KEY_OFFSET_BLUE:int = 180;
        public static const KEY_OFFSET_IN_GROUP:int = 2;
        
        private var _hitPoints:Array /* of Sprite */ = [];
        private var _keys:Array /* of Key_asset */ = [];
        private var _playerInfo:UnitModel;
        private var _mainModel:MainModel;
		private var _timer:Timer = new Timer(1000);
        
        public var module:Info_panel_asset;
        
        public function InfoPanel(model:MainModel) {
            module = new Info_panel_asset();
            addChild(module);
            
            _mainModel = model;
            _mainModel.addEventListener(Event.CHANGE, modelChangeHandler);
            _mainModel.addEventListener(UserEvent.LEVEL_COMPLETE, clearPanel);
			Dispatcher.instance.addEventListener(UserEvent.PLAYER_IS_DEAD, clearPanel);
            
            module.restart_level_button.addEventListener(MouseEvent.CLICK, restartLevelButtonHandler);
            module.restart_level_button.buttonMode = true;
			module.back_to_menu_button.addEventListener(MouseEvent.CLICK, backToMenuButtonHandler);
            module.back_to_menu_button.buttonMode = true;
			
			_timer.addEventListener(TimerEvent.TIMER, timerHandler);
        }
		
		private function timerHandler(e:TimerEvent):void {
			module.timeField.text = secondsToString(_timer.currentCount);
		}
		
		private function secondsToString(seconds:int):String {
			var minutes:int = seconds / 60;
			seconds %= 60;
			return (minutes < 10 ? "0" : "") + minutes.toString() + ":" +
				(seconds < 10 ? "0" : "") + seconds.toString();
		}
		
		
		public function startTimer():void {
			_timer.reset();
			module.timeField.text = secondsToString(0);
			_timer.start();
		}
		
		private function backToMenuButtonHandler(e:MouseEvent):void 
		{
			clearPanel();
			dispatchEvent(new UserEvent(UserEvent.RETURN_TO_MAIN_MENU));
		}
        
        private function restartLevelButtonHandler(event:MouseEvent):void 
        {
            clearPanel();
            Dispatcher.instance.dispatchEvent(new UserEvent(UserEvent.START_LEVEL, _mainModel.currentLevel));
        }
        
        private function clearPanel(event:UserEvent = null):void {
			_timer.reset();
            while (_hitPoints.length)
                removeChild(_hitPoints.pop() as DisplayObject);
            while (_keys.length)
                removeChild(_keys.pop() as DisplayObject);
        }
        
        private function modelChangeHandler(event:Event):void {
            module.ghoulCountField.text = _mainModel.ghoulsCount + "/" + _mainModel.civilsCount;
            module.mistCountField.text = _mainModel.mistCount.toString();
            module.walkCountField.text = _mainModel.throughWallCount.toString();
            module.soulCountField.text = _mainModel.soulChangeCount.toString();
        }
        
        private function refreshHitPoints(event:Event):void {
            while (_hitPoints.length > 0 && _hitPoints.length > _playerInfo.hitPoints)
                removeChild(_hitPoints.pop() as DisplayObject);
        }
        
        public function set playerInfo(value:UnitModel):void {
            _playerInfo = value;
            _playerInfo.addEventListener(Event.CHANGE, refreshHitPoints);
            _playerInfo.addEventListener(UserEvent.KEY_COLLECTED, keyCollectedHandler);
            _playerInfo.addEventListener(UserEvent.KEY_SPEND, keySpendHandler);
            for (var i:int = 0; i < _playerInfo.hitPoints; i++) {
                var hp:Hit_point_asset = new Hit_point_asset();
                _hitPoints.push(hp);
                hp.y = HEIGHT / 2;
                hp.x = HEIGHT * (i + 1);
                addChild(hp);
            }
        }
        
        private function keyCollectedHandler(event:UserEvent):void {
            var key:Key_asset = new Key_asset();
            key.gotoAndStop(event.data as String);
            _keys.push(key);
            addChild(key);
            sortKeys();
        }
        
        private function sortKeys():void {
			var redCount:int = 0;
			var yellowCount:int = 0;
			var greenCount:int = 0;
			var blueCount:int = 0;
            for (var i:int = 0; i < _keys.length; i++) {
                var key:Key_asset = _keys[i] as Key_asset;
				if (key.currentLabel == KeyColor.RED) {
					key.x = KEY_OFFSET_RED - redCount * KEY_OFFSET_IN_GROUP;
					key.y = HEIGHT / 2 - redCount * KEY_OFFSET_IN_GROUP;
					++redCount;
				}
				else if (key.currentLabel == KeyColor.YELLOW) {
					key.x = KEY_OFFSET_YELLOW - yellowCount * KEY_OFFSET_IN_GROUP;
					key.y = HEIGHT / 2 - yellowCount * KEY_OFFSET_IN_GROUP;
					++yellowCount;
				}
				else if (key.currentLabel == KeyColor.GREEN) {
					key.x = KEY_OFFSET_GREEN - greenCount * KEY_OFFSET_IN_GROUP;
					key.y = HEIGHT / 2 - greenCount * KEY_OFFSET_IN_GROUP;
					++greenCount;
				}
				else if (key.currentLabel == KeyColor.BLUE) {
					key.x = KEY_OFFSET_BLUE - blueCount * KEY_OFFSET_IN_GROUP;
					key.y = HEIGHT / 2 - blueCount * KEY_OFFSET_IN_GROUP;
					++blueCount;
				}
            }
        }
        
        private function keySpendHandler(event:UserEvent):void{
            for (var i:int = 0; i < _keys.length; i++) {
                var key:Key_asset = _keys[i] as Key_asset;
                if (key.currentLabel == (event.data as String)) {
                    if (key.parent) key.parent.removeChild(key);
                    _keys.splice(i, 1);
                    break;
                }
            }
            sortKeys();
        }
		
		public function removeAllKeys():void
		{
			while (_keys.length)
			{
				var key:DisplayObject = _keys.pop() as DisplayObject;
				if (key.parent) key.parent.removeChild(key);
			}
		}
        
    }

}