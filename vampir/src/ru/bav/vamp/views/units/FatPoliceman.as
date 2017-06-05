package ru.bav.vamp.views.units {
    import flash.display.*;
    import ru.bav.vamp.views.*;
    import ru.bav.vamp.views.units.*;
	
	/**
     * View of fat policeman.
     * @author bav
     */
    public class FatPoliceman extends UnitViewBase {
        
        public function FatPoliceman() {
            drawUnit();
        }
        
        private function drawUnit():void {
            _asset = new Fat_policeman_asset();
            _asset.gotoAndStop("down");
            addChild(_asset);
        }
        
    }

}