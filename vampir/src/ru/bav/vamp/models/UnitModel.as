package ru.bav.vamp.models {
    import flash.events.EventDispatcher;
    import flash.geom.Point;
    import ru.bav.vamp.models.consts.UnitType;
	/**
     * Base class for all units in game (including player).
     * @author bav
     */
    public class UnitModel extends EventDispatcher {
        // Type of unit, described in ru.bav.vamp.models.consts.UnitType class.
        protected var _type:int;
        // Unit coordinates on map.
        protected var _coordinates:Point;
        // Unit speed.
        protected var _speed:Number;
        // Lives
        protected var _hitPoints:int;
        
        // Only vampire properties
        protected var _invisible:Boolean = false;
        
        public function UnitModel() {
            
        }
        
        public function get type():int {
            return _type;
        }
        
        public function set type(value:int):void {
            _type = value;
            if (_type == UnitType.VAMPIR) _hitPoints = 3;
            else _hitPoints = 2;
        }
        
        public function get coordinates():Point {
            return _coordinates;
        }
        
        public function get speed():Number {
            return _speed;
        }
        
        public function set speed(value:Number):void {
            _speed = value;
        }
        
        public function set coordinates(value:Point):void {
            _coordinates = value;
        }
        
        public function get hitPoints():int {
            return _hitPoints;
        }
        
        public function set hitPoints(value:int):void {
            _hitPoints = value;
        }
        
        public function get invisible():Boolean {
            return _invisible;
        }
        
        public function set invisible(value:Boolean):void {
            _invisible = value;
        }
    }
}
