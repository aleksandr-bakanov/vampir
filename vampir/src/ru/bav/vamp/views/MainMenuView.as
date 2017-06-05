package ru.bav.vamp.views {
    import flash.display.MovieClip;
	import flash.display.Sprite;
    import flash.events.Event;
	
	/**
     * Main menu view.
     * @author bav
     */
    public class MainMenuView extends Sprite {
        public var module:Main_menu_asset;
        
        public function MainMenuView() {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(event:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            module = new Main_menu_asset();
			// Временное решение
			module.width = MainView.STAGE_WIDTH;
			module.height = MainView.STAGE_HEIGHT;
            addChild(module);
        }
        
        public function get gameStartButton():MovieClip {
            return module.gameStart;
        }
        
    }

}