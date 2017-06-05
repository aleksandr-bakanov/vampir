package ru.bav.vamp.views {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import ru.bav.vamp.controllers.Dispatcher;
	import ru.bav.vamp.events.UserEvent;
	import ru.bav.vamp.models.MainModel;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author bav
	 */
	public class GameOverMenuView extends Sprite {
		
		private var _model:MainModel;
        public var module:Game_over_menu_asset;
		
		public function GameOverMenuView(model:MainModel) {
			_model = model;
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            module = new Game_over_menu_asset();
			// Временное решение
			module.width = MainView.STAGE_WIDTH;
			module.height = MainView.STAGE_HEIGHT;
            addChild(module);
            // Add buttons listeners.
            module.restart_button.addEventListener(MouseEvent.CLICK, restartButtonHandler);
            module.shop_button.addEventListener(MouseEvent.CLICK, shopButtonHandler);
        }
		
		private function shopButtonHandler(event:MouseEvent):void {
			dispatchEvent(new UserEvent(UserEvent.SHOW_SHOP_MENU));
			if (parent) parent.removeChild(this);
		}
		
		private function restartButtonHandler(event:MouseEvent):void {
			Dispatcher.instance.dispatchEvent(new UserEvent(UserEvent.START_LEVEL, _model.currentLevel));
			if (parent) parent.removeChild(this);
		}
		
	}

}