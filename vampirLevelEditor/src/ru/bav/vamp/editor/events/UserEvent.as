package ru.bav.vamp.editor.events 
{
    import flash.events.Event;
    
    /**
     * Пользовательское событие.
     * @author bav
     */
    public class UserEvent extends Event 
    {
        public static const MAP_DIMENTIONS_CHANGED:String = "map_dimentions_changed";
        public static const UPDATE_SELECTED_CELL:String = "update_selected_cell";
        
        public var data:Object;
        
        public function UserEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) 
        { 
            super(type, bubbles, cancelable);
            this.data = data;
        } 
        
        public override function clone():Event 
        { 
            return new UserEvent(type, data, bubbles, cancelable);
        } 
        
        public override function toString():String 
        { 
            return formatToString("UserEvent", "type", "bubbles", "cancelable", "eventPhase"); 
        }
        
    }
    
}