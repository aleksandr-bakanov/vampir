package ru.bav.vamp.views.units {
    import ru.bav.vamp.views.units.*;
    import ru.bav.vamp.views.*;
	
	/**
     * View of hunter.
     * @author bav
     */
    public class Hunter extends UnitViewBase {
        
        public function Hunter() {
            drawUnit();
        }
        
        private function drawUnit():void{
            _asset = new Hunter_asset();
            _asset.gotoAndStop("down");
            addChild(_asset);
        }
        
    }

}