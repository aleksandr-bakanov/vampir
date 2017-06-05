package ru.bav.utils
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.filters.GlowFilter;
    import flash.filters.BitmapFilterQuality;
    
    public class Button extends Sprite
    {
        private var _glowColor:uint = 0xFF0000;
        private var _image:DisplayObject;
        private var _rollOverHandler:Function;
        private var _rollOutHandler:Function;
        
        public function Button(image:DisplayObject)
        {
            _image = image;
            addChild(_image);
            
            _rollOverHandler = rollOverHandler;
            _rollOutHandler = rollOutHandler;
            
            addEventListener(MouseEvent.ROLL_OVER, _rollOverHandler);
            addEventListener(MouseEvent.ROLL_OUT, _rollOutHandler);
        }
        
        private function rollOverHandler(event:MouseEvent):void
        {
            _image.filters = [new GlowFilter(_glowColor, 1, 6, 6, 3, BitmapFilterQuality.HIGH)];
        }
        
        private function rollOutHandler(event:MouseEvent):void
        {
            _image.filters = [];
        }
        
        public function set glowColor(value:uint):void 
        {
            _glowColor = value;
        }
        
    }
}