package ru.bav.vamp.events {
    import flash.events.Event;
    
    /**
     * Different user events.
     * @author bav
     */
    public class UserEvent extends Event {
        public static const INIT_LEVEL_MAP:String = "init_level_map";
        public static const INIT_UNITS:String = "init_units";
        public static const UNIT_SHOOTED:String = "unit_shooted";
        public static const UNIT_KILLED:String = "unit_killed";
        public static const PLAYER_IS_DEAD:String = "player_is_dead";
        public static const UNIT_BITTEN:String = "unit_bitten";
        public static const GHOUL_CREATED:String = "ghoul_created";
        public static const OPEN_LEVELS_MENU:String = "open_levels_menu";
        public static const OPEN_LEVEL_COMPLETE_MENU:String = "open_level_complete_menu";
        public static const DESTROY_UNIT:String = "destroy_unit";
        public static const LEVEL_COMPLETE:String = "level_complete";
        public static const START_LEVEL:String = "start_level";
        public static const OPEN_DOOR:String = "open_door";
        public static const KEY_COLLECTED:String = "key_collected";
        public static const KEY_SPEND:String = "key_spend";
        public static const STOP_MOVING:String = "stop_moving";
        public static const START_MOVING:String = "start_moving";
        public static const SHOW_SHOP_MENU:String = "show_shop_menu";
        public static const ALLOW_LEVEL:String = "allow_level";
		public static const RETURN_TO_MAIN_MENU:String = "return_to_main_menu";
		public static const DOOR_OPENED:String = "door_opened";
        
        public var data:Object;
        
        public function UserEvent(type:String, _data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
            super(type, bubbles, cancelable);
            data = _data;
        } 
        
        public override function clone():Event {
            return new UserEvent(type, null, bubbles, cancelable);
        } 
        
        public override function toString():String {
            return formatToString("UserEvent", "type", "bubbles", "cancelable", "eventPhase"); 
        }
    }
}
