package ru.bav.vamp.views.items {
    import flash.display.*;
    import flash.events.*;
    import flash.utils.*;
    import ru.bav.vamp.events.UserEvent;
    import ru.bav.vamp.controllers.UnitController;
    import ru.bav.vamp.controllers.units.PlayerController;
    import ru.bav.vamp.interfaces.IDestroyable;
	
	/**
     * Ключики
     * @author bav
     */
    public class Key extends Sprite implements IDestroyable {
		
        public static const CHECK_DELAY:int = 100;
        public static var keyTimer:Timer;
        public static var player:DisplayObject;
        
        private var _view:Key_asset;
        private var _color:String;
        
        public function Key(color:String, player:DisplayObject) {
            _color = color;
            Key.player = player;
            
            _view = new Key_asset();
            _view.gotoAndStop(color);
            addChild(_view);
            
            if (!keyTimer) {
                keyTimer = new Timer(CHECK_DELAY);
                keyTimer.start();
            }
            
            keyTimer.addEventListener(TimerEvent.TIMER, checkPlayerCollision);
        }
        
        private function checkPlayerCollision(event:TimerEvent):void{
            if (PlayerController.getDistance(this.x, this.y, player.x, player.y) <= UnitController.BIT_DISTANSE) {
                player.dispatchEvent(new UserEvent(UserEvent.KEY_COLLECTED, _color));
                destroy();
            }
        }
        
        public function destroy():void {
            keyTimer.removeEventListener(TimerEvent.TIMER, checkPlayerCollision);
            if (_view && contains(_view)) removeChild(_view);
            _view = null;
        }
        
    }

}