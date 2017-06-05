package ru.bav.vamp.models {
    import flash.events.EventDispatcher;
    import ru.bav.vamp.models.consts.WallType;
	/**
     * Map ceil model. Class describe ceil type, contain array of Wall objects.
     * @author bav
     */
    public class MapCellModel extends EventDispatcher{
        // Type of ceil instance, described in ru.bav.vamp.models.consts.MapCeilType class.
        private var _type:String;
        // [0] mean north wall, and so on by CW. ([1] - east, [2] - south, [3] - west)
        private var _walls:/*Wall*/Array;
        
        public function MapCellModel() {
            _walls = [];
        }
        
        public function initWalls(xml:XMLList):void {
            for (var i:int = 0; i < 4; i++) {
                _walls[i] = (xml.wall.(@id == WallType.DIRECTIONS[i]).toXMLString()) ? new Wall(xml.wall.(@id == WallType.DIRECTIONS[i]).@type) : null;
                if (_walls[i] && _walls[i].type == WallType.DOOR) 
                    _walls[i].keyColor = xml.wall.(@id == WallType.DIRECTIONS[i]).@color;
            }
        }
        
        public function get type():String {
            return _type;
        }
        
        public function set type(value:String):void {
            _type = value;
        }
        
        public function get walls():Array {
            return _walls;
        }
    }
}
