package ru.bav.vamp.views.units {
    
    import flash.display.Graphics;
    import ru.bav.vamp.views.MapCeilView;
    import ru.bav.vamp.views.units.UnitViewBase;
	
	/**
     * View of civil.
     * @author bav
     */
    public class Civil extends UnitViewBase {
        
        public function Civil() {
            drawUnit();
        }
        
        private function drawUnit():void{
            _asset = new Civil_asset();
            _asset.gotoAndStop("down");
            addChild(_asset);
        }
        
    }

}