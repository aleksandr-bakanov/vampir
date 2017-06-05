package ru.bav.vamp.controllers {
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import ru.bav.vamp.events.*;
    import ru.bav.vamp.models.*;
    import ru.bav.vamp.views.*;
	/**
     * Main game controller.
     * @author bav
     */
    public class MainController {
        private var _mainView:MainView;
        private var _mainModel:MainModel;
        
        public function MainController(host:DisplayObjectContainer) {
            _mainModel = new MainModel();
            _mainView = new MainView(host, _mainModel);
            configureStage(host);
            Dispatcher.instance.addEventListener(UserEvent.START_LEVEL, startLevelHandler);
        }
        
        private function configureStage(host:DisplayObjectContainer):void {
            host.stage.scaleMode = StageScaleMode.NO_SCALE;
            host.stage.align = StageAlign.TOP_LEFT;
        }
        
        private function startLevelHandler(event:UserEvent):void {
            var num:int = event.data as int;
            if (LevelsXML.getLevelConfig(num)) {
				_mainModel.soulChangeCount = 15;
				_mainModel.currentLevel = num;
				
				_mainModel.initMap(LevelsXML.getLevelConfig(num));
				_mainModel.initUnits(LevelsXML.getLevelConfig(num));
				_mainView.initItems(LevelsXML.getLevelConfig(num));
			}
        }
    }
}
