package ru.bav.vamp.views.units {
    
    import ru.bav.vamp.views.*;
    
	/**
     * Player view.
     * @author bav
     */
    public class Player extends UnitViewBase {
        public function Player() {
            drawUnit();
        }
        
        private function drawUnit():void {
            _asset = new Vampir_asset();
            _asset.gotoAndStop("down");
            addChild(_asset);
        }
        
    }

}