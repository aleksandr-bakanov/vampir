package ru.bav.vamp.models.consts {
	/**
     * Class describe wall type.
     * @author bav
     */
    public class WallType {
        public static const NORMAL:String = "normal";
        public static const DOOR:String = "door";
        
        public static const DIRECTIONS:Array = ["north", "east", "south", "west"];
        public static const NORTH:int = 0;
        public static const EAST:int = 1;
        public static const SOUTH:int = 2;
        public static const WEST:int = 3;
        
        public static const OPEN:String = "open";
        public static const CLOSED:String = "closed";
        
        public static const HORIZONTAL:String = "horizontal";
        public static const VERTICAL:String = "vertical";
        
        public function WallType() {
            
        }
    }
}
