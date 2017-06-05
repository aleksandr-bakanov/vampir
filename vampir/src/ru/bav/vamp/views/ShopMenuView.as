package ru.bav.vamp.views {
	import flash.display.*;
    import flash.events.*;
    import ru.bav.vamp.events.*;
    import ru.bav.vamp.models.MainModel;
	
	/**
     * Level complete menu
     * @author bav
     */
    public class ShopMenuView extends Sprite {
        private var _model:MainModel;
        public var module:Shop_menu_asset;
        
        public function ShopMenuView(model:MainModel) {
            _model = model;
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(event:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            module = new Shop_menu_asset();
			// Временное решение
			module.width = MainView.STAGE_WIDTH;
			module.height = MainView.STAGE_HEIGHT;
            addChild(module);
            // Add buttons listeners.
            module.okButton.addEventListener(MouseEvent.CLICK, okButtonHandler);
            module.mistButton.addEventListener(MouseEvent.CLICK, buyMist);
            module.soulButton.addEventListener(MouseEvent.CLICK, buySoul);
            module.wallButton.addEventListener(MouseEvent.CLICK, buyWall);
            // Add model listener
            _model.addEventListener(Event.CHANGE, modelChangeHandler);
        }
        
        private function modelChangeHandler(event:Event):void {
            module.mistField.text = _model.mistCount.toString();
            module.scoreField.text = _model.score.toString();
            module.wallField.text = _model.throughWallCount.toString();
            module.soulField.text = _model.soulChangeCount.toString();
        }
        
        private function buyMist(event:MouseEvent):void {
            if (_model.score >= MainModel.MIST_COST) {
                _model.mistCount++;
                _model.score -= MainModel.MIST_COST;
            }
        }
        
        private function buyWall(event:MouseEvent):void {
            if (_model.score >= MainModel.WALK_THROUGH_COST) {
                _model.throughWallCount++;
                _model.score -= MainModel.WALK_THROUGH_COST;
            }
        }
        
        private function buySoul(event:MouseEvent):void {
            if (_model.score >= MainModel.SOUL_CHANGE_COST) {
                _model.soulChangeCount++;
                _model.score -= MainModel.SOUL_CHANGE_COST;
            }
        }
        
        private function okButtonHandler(event:MouseEvent):void {
            dispatchEvent(new UserEvent(UserEvent.OPEN_LEVELS_MENU));
            if (parent) parent.removeChild(this);
        }
        
    }

}