package ru.bav.vamp.views.units 
{
    
    import flash.display.Graphics;
    import ru.bav.vamp.views.MapCeilView;
    import ru.bav.vamp.views.units.UnitViewBase;
    
	/**
     * ...
     * @author bav
     */
    public class Ghoul extends UnitViewBase 
    {
        
        public function Ghoul() 
        {
            drawUnit();
        }
        
        private function drawUnit():void{
            _asset = new Ghoul_asset();
            _asset.gotoAndStop("down");
            addChild(_asset);
        }
        
    }

}