package ru.bav.vamp.models {
    import flash.events.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.utils.*;
    import ru.bav.vamp.events.*;
    import ru.bav.vamp.models.consts.*;
	/**
     * Game main model class.
     * @author bav
     */
    public class MainModel extends EventDispatcher {
        public static const MIST_COST:int = 2;
        public static const WALK_THROUGH_COST:int = 3;
        public static const SOUL_CHANGE_COST:int = 4;
        
        private var _map:/*MapCellModel*/Array;
		private var _mapHeight:int;
		private var _mapWidth:int;
        // Array of NPC on level.
        private var _units:/*UnitModel*/Array;
        // Current count of units of differents types.
        private var _civilsCount:int = 0;
        private var _ghoulsCount:int = 0;
        // Сколько очков заработано за игру.
        private var _score:int = 0;
        // Завершенные уровни
        private var _completeLevels:Object = { };
        // Разрешенные уровни
        private var _allowedLevels:Object = { };
        public var currentLevel:int;
        // Количества способностей персонажа
        private var _mistCount:int = 0;
        private var _soulChangeCount:int = 0;
        private var _throughWallCount:int = 0;
        private var _throughWallDistance:Number = 0;
        
        public var shared:SharedObject;
        public var sharedAllowed:Boolean = true;
        
        // Наличие у игрока ключей
        private var _keys:Array = [];
        
        private var _unitsDict:Dictionary;
        
        public function MainModel() {
            _unitsDict = new Dictionary();
            initSharedObject();
        }
        
        private function initSharedObject():void {
            shared = SharedObject.getLocal("ruBavVamp");
            shared.addEventListener(NetStatusEvent.NET_STATUS, sharedNetStatusHandler);
            shared.data.test = "test";
            shared.flush();
            // Первый уровень всегда разрешен
            _allowedLevels["level_1"] = true;
            for (var i:int = 2; i < 5; i++) {
                _allowedLevels["level_" + i] = getSharedInfo("level_" + i);
            }
        }
        
        private function sharedNetStatusHandler(event:NetStatusEvent):void {
            if (event.info.code != "SharedObject.Flush.Success")
                sharedAllowed = false;
        }
        
        public function setSharedInfo(param:String, value:Object):void {
            if (sharedAllowed)
                shared.data[param] = value;
        }
        
        public function getSharedInfo(param:String):Object {
            if (sharedAllowed)
                return shared.data[param];
            else return null;
        }
        
        public function initMap(xml:XML):void {
            _map = [];
            _mapHeight = parseInt(xml.mapSize.@height);
            _mapWidth = parseInt(xml.mapSize.@width);
            for (var i:int = 0; i < _mapHeight; i++) {
                _map[i] = [];
                for (var j:int = 0; j < _mapWidth; j++) {
                    if (xml.mapCeils.ceil.(@x == j && @y == i).toXMLString() != "") {
                        var ceil:XMLList = xml.mapCeils.ceil.(@x == j && @y == i) as XMLList;
                        _map[i][j] = makeMapCeil(ceil);
                    }
                    else _map[i][j] = null;
                }
            }
            dispatchEvent(new UserEvent(UserEvent.INIT_LEVEL_MAP));
        }
        
        private function makeMapCeil(xml:XMLList):MapCellModel {
            var ceil:MapCellModel = new MapCellModel();
            ceil.type = xml.@type;
            ceil.initWalls(xml);
            return ceil;
        }
        
        public function initUnits(xml:XML):void {
            _civilsCount = 0;
            _ghoulsCount = 0;
            _units = [];
            var i:int = 0;
            for each (var unitInfo:XML in xml.units.unit)
                _units[i++] = makeUnit(unitInfo);
            dispatchEvent(new Event(Event.CHANGE));
            dispatchEvent(new UserEvent(UserEvent.INIT_UNITS));
        }
        
        private function makeUnit(xml:XML):UnitModel {
            var unit:UnitModel = new UnitModel();
            unit.type = convertUnitTypeToNumber(xml.@type);
            if (unit.type == UnitType.CIVIL || unit.type == UnitType.HUNTER || unit.type == UnitType.POLICEMAN || unit.type == UnitType.FAT_POLICEMAN)
                civilsCount++;
            unit.coordinates = new Point(parseInt(xml.@x), parseInt(xml.@y));
            unit.speed = 1;
            return unit;
        }
        
        private function convertUnitTypeToNumber(type:String):int {
            var ret:int;
            if (type == "vampir") ret = UnitType.VAMPIR;
            else if (type == "civil") ret = UnitType.CIVIL;
            else if (type == "ghoul") ret = UnitType.GHOUL;
            else if (type == "policeman") ret = UnitType.POLICEMAN;
            else if (type == "fat_policeman") ret = UnitType.FAT_POLICEMAN;
            else if (type == "hunter") ret = UnitType.HUNTER;
            else if (type == "werewolf") ret = UnitType.WEREWOLF;
            return ret;
        }
        
        public function get map():Array {
            return _map;
        }
        
        public function get units():Array {
            return _units;
        }
        
        public function get unitsDict():Dictionary {
            return _unitsDict;
        }
        
        public function get ghoulsCount():int {
            return _ghoulsCount;
        }
        
        public function set ghoulsCount(value:int):void {
            _ghoulsCount = value;
            dispatchEvent(new Event(Event.CHANGE));
        }
        
        public function get civilsCount():int {
            return _civilsCount;
        }
        
        public function set civilsCount(value:int):void {
            _civilsCount = value;
            dispatchEvent(new Event(Event.CHANGE));
            if (!_civilsCount){
                _completeLevels[currentLevel] = true;
                setSharedInfo("level_" + (currentLevel + 1), true);
                _allowedLevels["level_" + (currentLevel + 1)] = true;
                if (_completeLevels[currentLevel]) _score += _ghoulsCount;
                dispatchEvent(new Event(Event.CHANGE));
                dispatchEvent(new UserEvent(UserEvent.LEVEL_COMPLETE));
                dispatchEvent(new UserEvent(UserEvent.ALLOW_LEVEL, currentLevel + 1));
            }
        }
        
        public function get keys():Array {
            return _keys;
        }
        
        public function set keys(value:Array):void {
            _keys = value;
        }
        
        public function get completeLevels():Object {
            return _completeLevels;
        }
        
        public function get score():int {
            return _score;
        }
        
        public function set score(value:int):void {
            _score = value;
            dispatchEvent(new Event(Event.CHANGE));
        }
        
        public function get mistCount():int {
            return _mistCount;
        }
        
        public function set mistCount(value:int):void {
            _mistCount = value;
            dispatchEvent(new Event(Event.CHANGE));
        }
        
        public function get allowedLevels():Object {
            return _allowedLevels;
        }
        
        public function get soulChangeCount():int {
            return _soulChangeCount;
        }
        
        public function set soulChangeCount(value:int):void {
            _soulChangeCount = value;
            dispatchEvent(new Event(Event.CHANGE));
        }
        
        public function get throughWallCount():int {
            return _throughWallCount;
        }
        
        public function set throughWallCount(value:int):void {
            _throughWallCount = value;
            dispatchEvent(new Event(Event.CHANGE));
        }
        
        public function get throughWallDistance():Number {
            return _throughWallDistance;
        }
        
        public function set throughWallDistance(value:Number):void {
            _throughWallDistance = value;
        }
		
		public function get mapHeight():int 
		{
			return _mapHeight;
		}
		
		public function get mapWidth():int 
		{
			return _mapWidth;
		}
    }
}
