package ru.bav.vamp.views.units {
    
    import flash.display.*;
    import flash.events.TimerEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Timer;
    import ru.bav.vamp.views.*;
	
	/**
     * Base class for unit views.
     * @author bav
     */
    public class UnitViewBase extends Sprite {
        
        /*public static const ANIMATION_TIMER:Timer = new Timer(100);
        public static const SPRITE_WIDTH:int = 50;
        public static const SPRITE_HEIGHT:int = 50;
        
        protected var _bitmapData:BitmapData;
        protected var _bitmap:Bitmap;
        protected var _copyRectangle:Rectangle;
        protected var _currentFrame:int;
        protected var _bitmapWidth:int;
        // Фактически номер строки считываемой из bitmapData. Порядок заведем такой:
        // 0 - идет вверх
        // 1 - идет вправо
        // 2 - идет вниз
        // 3 - атакует вверх
        // 4 - атакует вправо
        // 5 - атакует вниз
        // 6 - умирает
        protected var _action:int = 0;*/
        
        public var allUnits:Array /* of UnitViewBase */;
        public var frontDirection:int;
        
        protected var _asset:MovieClip;
        
        public function UnitViewBase(/*bitmapData:BitmapData*/) {
            /*if (!ANIMATION_TIMER.running) ANIMATION_TIMER.start();
            _bitmapData = bitmapData;
            _bitmapWidth = bitmapData.width;
            _copyRectangle = new Rectangle(0, 0, SPRITE_WIDTH, SPRITE_HEIGHT);
            _currentFrame = 0;
            _bitmap = new Bitmap(new BitmapData(SPRITE_WIDTH, SPRITE_HEIGHT, true, 0));
            _bitmap.x = _bitmap.y = -SPRITE_HEIGHT / 2;
            addChild(_bitmap);
            play();*/
        }
        
        /*public function play():void {
            ANIMATION_TIMER.addEventListener(TimerEvent.TIMER, animate);
        }
        
        public function stop():void {
            ANIMATION_TIMER.removeEventListener(TimerEvent.TIMER, animate);
        }
        
        public function animate(event:TimerEvent):void {
            _copyRectangle.y = _action * SPRITE_HEIGHT;
            _copyRectangle.x = _currentFrame * SPRITE_WIDTH;
            _bitmap.bitmapData.copyPixels(_bitmapData, _copyRectangle, ZERO_POINT);
            _currentFrame++;
            if (_currentFrame * SPRITE_WIDTH >= _bitmapWidth) _currentFrame = 0;
        }*/
        
        public function becameGhoul():void{
            var ghoul:Ghoul_asset = new Ghoul_asset();
            ghoul.gotoAndStop(_asset.currentFrame);
            removeChild(_asset);
            _asset = ghoul;
            addChild(_asset);
        }
        
        public function drawDeath():void{
            if (_asset)
                _asset.gotoAndPlay("death");
            else {
                var g:Graphics = this.graphics;
                g.clear();
                g.beginFill(0xFF0000);
                g.drawCircle(0, 0, MapCeilView.CELL_SIZE / 4);
            }
            if (parent) parent.setChildIndex(this, 0);
        }
        
        public function turn(to:int):void {
            //_action = to;
            if (_asset) {
                if (to == 0) _asset.gotoAndStop("up");
                else if (to == 1) _asset.gotoAndStop("right");
                else if (to == 2) _asset.gotoAndStop("down");
                else if (to == 3) _asset.gotoAndStop("left");
            }
        }
        
        public function shoot(to:int):void {
            
        }
        
    }

}