package ru.bav.vamp.views.units {
    import ru.bav.vamp.views.units.*;
    import ru.bav.vamp.views.*;
	
	/**
     * View of policeman.
     * @author bav
     */
    public class Policeman extends UnitViewBase {
        
        public function Policeman() {
            drawUnit();
        }
        
        private function drawUnit():void {
            _asset = new Policeman_asset();
            _asset.gotoAndStop("down");
            addChild(_asset);
        }
        
    }

}