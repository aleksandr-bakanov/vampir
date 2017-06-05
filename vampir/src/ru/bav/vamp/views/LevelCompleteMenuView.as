package ru.bav.vamp.views {
	import flash.display.*;
    import flash.events.*;
    import ru.bav.vamp.events.*;
    import ru.bav.vamp.models.MainModel;
	
	/**
     * Level complete menu
     * @author bav
     */
    public class LevelCompleteMenuView extends Sprite {
        private var _model:MainModel;
        public var module:Level_complete_menu_asset;
        
        public function LevelCompleteMenuView(model:MainModel) {
            _model = model;
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(event:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            module = new Level_complete_menu_asset();
			// Временное решение
			module.width = MainView.STAGE_WIDTH;
			module.height = MainView.STAGE_HEIGHT;
            addChild(module);
            // Add buttons listeners.
            module.okButton.addEventListener(MouseEvent.CLICK, okButtonHandler);
            module.shop_button.addEventListener(MouseEvent.CLICK, shopButtonHandler);
        }
		
		private function shopButtonHandler(event:MouseEvent):void {
			dispatchEvent(new UserEvent(UserEvent.SHOW_SHOP_MENU));
			if (parent) parent.removeChild(this);
		}
        
        private function okButtonHandler(event:MouseEvent):void {
            dispatchEvent(new UserEvent(UserEvent.OPEN_LEVELS_MENU));
            if (parent) parent.removeChild(this);
        }
        
    }

}