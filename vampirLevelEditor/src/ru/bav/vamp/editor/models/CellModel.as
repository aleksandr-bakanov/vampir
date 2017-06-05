package ru.bav.vamp.editor.models 
{
	/**
     * Модель ячейки карты.
     * @author bav
     */
    public class CellModel 
    {
        // ====================================================================
        //    Константы
        // ====================================================================
        public static const NORMAL:String = "normal";
        public static const WATER:String = "water";
        
        public static const VAMPIR:String = "vampir";
        public static const CIVIL:String = "civil";
        public static const POLICEMAN:String = "policeman";
        public static const FAT_POLICEMAN:String = "fat_policeman";
        public static const HUNTER:String = "hunter";
        public static const WEREWOLF:String = "werewolf";
        
        // А есть ли ячейка
        private var _enable:Boolean = true;
        // Тип ячейки
        private var _type:String;
        // Стены
        private var _north:WallModel = null;
        private var _east:WallModel = null;
        private var _south:WallModel = null;
        private var _west:WallModel = null;
        // Юнит
        private var _unit:String = null;
        // Вещь
        private var _item:String = null;
        
        public function CellModel(type:String = "normal") 
        {
            _type = type;
        }
        
        public function get type():String 
        {
            return _type;
        }
        
        public function set type(value:String):void 
        {
            _type = value;
        }
        
        public function get north():WallModel 
        {
            return _north;
        }
        
        public function set north(value:WallModel):void 
        {
            _north = value;
        }
        
        public function get east():WallModel 
        {
            return _east;
        }
        
        public function set east(value:WallModel):void 
        {
            _east = value;
        }
        
        public function get south():WallModel 
        {
            return _south;
        }
        
        public function set south(value:WallModel):void 
        {
            _south = value;
        }
        
        public function get west():WallModel 
        {
            return _west;
        }
        
        public function set west(value:WallModel):void 
        {
            _west = value;
        }
        
        public function get unit():String 
        {
            return _unit;
        }
        
        public function set unit(value:String):void 
        {
            _unit = value;
        }
        
        public function get item():String 
        {
            return _item;
        }
        
        public function set item(value:String):void 
        {
            if (value == "none") _item = "";
            else _item = value;
        }
        
        public function get enable():Boolean 
        {
            return _enable;
        }
        
        public function set enable(value:Boolean):void 
        {
            _enable = value;
        }
        
        public function getXML():String
        {
            var xml:XML = <ceil></ceil>;
            xml.@["type"] = type;
            var ch:XML;
            if (_north) {
                ch = <wall/>;
                ch.@["id"] = "north";
                if (_north.type == WallModel.DOOR) {
                    ch.@["type"] = _north.type;
                    ch.@["color"] = _north.color;
                }
                else ch.@["type"] = _north.type;
                xml.appendChild(ch);
            }
            if (_east) {
                ch = <wall/>;
                ch.@["id"] = "east";
                if (_east.type == WallModel.DOOR) {
                    ch.@["type"] = _east.type;
                    ch.@["color"] = _east.color;
                }
                else ch.@["type"] = _east.type;
                xml.appendChild(ch);
            }
            if (_south) {
                ch = <wall/>;
                ch.@["id"] = "south";
                if (_south.type == WallModel.DOOR) {
                    ch.@["type"] = _south.type;
                    ch.@["color"] = _south.color;
                }
                else ch.@["type"] = _south.type;
                xml.appendChild(ch);
            }
            if (_west) {
                ch = <wall/>;
                ch.@["id"] = "west";
                if (_west.type == WallModel.DOOR) {
                    ch.@["type"] = _west.type;
                    ch.@["color"] = _west.color;
                }
                else ch.@["type"] = _west.type;
                xml.appendChild(ch);
            }
            return xml.toXMLString();
        }
        
    }

}