package ru.bav.vamp.editor.models 
{
	/**
     * Модель стены.
     * @author bav
     */
    public class WallModel 
    {
        // ====================================================================
        //    Константы
        // ====================================================================
        public static const NORMAL:String = "normal";
        public static const DOOR:String = "door";
        
        public static const OPEN:String = "open";
        public static const CLOSED:String = "closed";
        
        // Тип стены
        private var _type:String;
        // Цвет стены, в случае если это дверь
        private var _color:String;
        
        public function WallModel(type:String = "normal") 
        {
            if (type.indexOf("door") >= 0) {
                _type = type.split("_")[0];
                _color = type.split("_")[1];
            }
            else _type = type;
        }
        
        public function get type():String 
        {
            return _type;
        }
        
        public function set type(value:String):void 
        {
            if (value.indexOf("door") >= 0) {
                _type = value.split("_")[0];
                _color = value.split("_")[1];
            }
            else _type = value;
        }
        
        public function get color():String 
        {
            return _color;
        }
        
        public function set color(value:String):void 
        {
            _color = value;
        }
        
    }

}