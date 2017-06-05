package ru.bav.vamp.views {
    import flash.display.MovieClip;
	import flash.display.Sprite;
    import flash.events.Event;
    import ru.bav.vamp.events.UserEvent;
    import ru.bav.vamp.models.MainModel;
    
    import com.gskinner.geom.ColorMatrix;
    import flash.filters.ColorMatrixFilter;
	
	/**
     * Levels menu view.
     * @author bav
     */
    public class LevelsMenuView extends Sprite {
        public var module:Levels_menu_asset;
        private var _mainModel:MainModel;
        
        public function LevelsMenuView(model:MainModel) {
            _mainModel = model;
            _mainModel.addEventListener(UserEvent.ALLOW_LEVEL, refreshLevelsButtons);
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(event:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            module = new Levels_menu_asset();
			// Временное решение
			module.width = MainView.STAGE_WIDTH;
			module.height = MainView.STAGE_HEIGHT;
            addChild(module);
            // Настраиваем доступность кнопок в соответствии с данными в модели.
            var allow:Boolean;
            for (var i:int = 1; i <= 20; i++) {
                allow = Boolean(_mainModel.allowedLevels["level_" + i]);
                var level:MovieClip = module.getChildByName("level_" + i) as MovieClip;
                if (level) setButtonAllow(i, /*allow*/true);
            }
        }
        
        private function refreshLevelsButtons(event:UserEvent):void {
            if (_mainModel.allowedLevels["level_" + int(event.data)]) setButtonAllow(event.data as int, true);
        }
        
        public function setButtonAllow(levelNumber:int, allowed:Boolean):void {
            var cm:ColorMatrix = new ColorMatrix();
            cm.adjustColor(0, 0, allowed ? 0 : -100, 0);
            var level:MovieClip = module.getChildByName("level_" + levelNumber) as MovieClip;
            if (level) level.filters = [new ColorMatrixFilter(cm)];
        }
    }

}