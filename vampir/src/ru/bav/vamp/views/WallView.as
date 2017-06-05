package ru.bav.vamp.views {
    import flash.display.Graphics;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import ru.bav.vamp.views.MapCeilView;
    import ru.bav.vamp.models.consts.WallType;
    import ru.bav.vamp.models.consts.KeyColor;
    
    /**
     * Wall view
     * @author bav
     */
    public class WallView extends Sprite {
        // Wall thickness
        public static const WALL_THICKNESS:Number = 4;
        // Wall type
        private var _type:String;
        // Wall direction
        private var _direction:String;
        private var _asset:Wall_asset;
        
        public function WallView(direction:String, type:String = "normal", color:String = "") {
            _direction = direction;
            _type = type;
            _asset = new Wall_asset();
			_asset.width = MapCeilView.CELL_SIZE + WALL_THICKNESS;
			_asset.x = -(WALL_THICKNESS / 2);
            if (type == WallType.NORMAL)
                _asset.gotoAndStop("normal");
            else
                _asset.gotoAndStop("door_" + color);
            if (_direction == "east" || _direction == "west")
                _asset.rotation = 90;
            addChild(_asset);
        }
        
    }

}