package ru.bav.vamp.editor.controllers 
{
    import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
    import ru.bav.vamp.editor.models.MainModel;
    import ru.bav.vamp.editor.views.MainView;
    import ru.bav.vamp.editor.events.UserEvent;
	
	/**
     * Главный контроллер.
     * @author bav
     */
    public class MainController extends EventDispatcher 
    {
        private var _host:DisplayObjectContainer;
        private var _mainView:MainView;
        private var _mainModel:MainModel;
        
        public function MainController(host:DisplayObjectContainer) 
        {
            super();
            _host = host;
            _mainModel = new MainModel();
            _mainView = new MainView(_mainModel);
            _host.addChild(_mainView);
            initHandlers();
        }
        
        private function initHandlers():void
        {
            _mainView.addEventListener(UserEvent.MAP_DIMENTIONS_CHANGED, mapDimentionChangedHandler);
        }
        
        private function mapDimentionChangedHandler(event:UserEvent):void
        {
            _mainModel.setMapDimentions(event.data.width, event.data.height);
        }
        
    }

}