package ru.bav.vamp.models {
	/**
     * Class describe wall object.
     * @author bav
     */
    public class Wall {
        // Wall type, described in ru.bav.vamp.models.consts.WallType class.
        private var _type:String;
        // Color of key which open this wall object (door type). Described in ru.bav.vamp.models.consts.KeyColor class.
        private var _keyColor:String;
        
        public function Wall(type:String = "") {
            _type = type;
        }
        
        public function get type():String {
            return _type;
        }
        
        public function set type(value:String):void {
            _type = value;
        }
        
        public function get keyColor():String {
            return _keyColor;
        }
        
        public function set keyColor(value:String):void {
            _keyColor = value;
        }
    }
}
