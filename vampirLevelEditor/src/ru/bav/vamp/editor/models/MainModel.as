package ru.bav.vamp.editor.models 
{
	import flash.events.EventDispatcher;
    import ru.bav.vamp.editor.events.UserEvent;
	
	/**
     * Главная модель.
     * @author bav
     */
    public class MainModel extends EventDispatcher 
    {
        // Модель карты. Двумерный массив моделей ячеек.
        private var _map:Vector.<Vector.<CellModel>>;
        public var mapWidth:int;
        public var mapHeight:int;
        
        public function MainModel() 
        {
            super();
            _map = new Vector.<Vector.<CellModel>>();
        }
        
        public function parceExternalXML(xml:XML):void
        {
            clearMap();
            trace("afterClearMap: xml = " + xml.toXMLString());
            mapWidth = parseInt(xml.mapSize.@width);
            mapHeight = parseInt(xml.mapSize.@height);
            for (var i:int = 0; i < mapHeight; i++)
            {
                var j:int;
                _map.push(createInitedRow());
                for (j = 1; j < mapWidth; j++)
                    _map[i].push(new CellModel());
                
                for (j = 0; j < mapWidth; j++)
                {
                    var cxml:XMLList = xml.mapCeils.ceil.(@y == i && @x == j) as XMLList;
                    var model:CellModel = _map[i][j] as CellModel;
                    if (cxml.toXMLString() == "")
                    {
                        model.enable = false;
                        model.north = new WallModel();
                        model.east = new WallModel();
                        model.south = new WallModel();
                        model.west = new WallModel();
                    }
                    else
                    {
                        if (cxml.wall.(@id == "north").length()) {
                            model.north = new WallModel(cxml.wall.(@id == "north").@type);
                            model.north.color = cxml.wall.(@id == "north").@color;
                        }
                        if (cxml.wall.(@id == "east").length()) {
                            model.east = new WallModel(cxml.wall.(@id == "east").@type);
                            model.east.color = cxml.wall.(@id == "east").@color;
                        }
                        if (cxml.wall.(@id == "south").length()) {
                            model.south = new WallModel(cxml.wall.(@id == "south").@type);
                            model.south.color = cxml.wall.(@id == "south").@color;
                        }
                        if (cxml.wall.(@id == "west").length()) {
                            model.west = new WallModel(cxml.wall.(@id == "west").@type);
                            model.west.color = cxml.wall.(@id == "west").@color;
                        }
                    }
                }
            }
            // Расставим юнитов
            for each (var unit:XML in xml.units.unit)
            {
                (_map[parseInt(unit.@y)][parseInt(unit.@x)] as CellModel).unit = unit.@type;
            }
            // Расставим предметы
            for each (var key:XML in xml.items.key)
            {
                (_map[parseInt(key.@y)][parseInt(key.@x)] as CellModel).item = key.@color + "_key";
            }
            
            dispatchEvent(new UserEvent(UserEvent.MAP_DIMENTIONS_CHANGED));
        }
        
        private function clearMap():void
        {
            _map.length = 0;
        }
        
        /**
         * Функция установки размеров карты
         * @param	width   Ширина
         * @param	height  Высота
         */
        public function setMapDimentions(width:int, height:int):void
        {
            if (!width || !height) return;
            mapWidth = width;
            mapHeight = height;
            var len:int;
            var i:int;
            // Сверим старые и новые размеры карты, если новые размеры меньше,
            // уменьнаем длины массивов, если больше, добавляем нужное количество элементов.
            // Проверяем сначала высоту.
            if (_map.length > height)
                _map.length = height;
            else if (_map.length < height)
            {
                for (i = _map.length; i < height; i++)
                    _map.push(createInitedRow());
            }
            // Теперь проверим ширину
            len = _map.length;
            if (len && _map[0].length > width)
            {
                for (i = 0; i < len; i++)
                    _map[i].length = width;
            }
            else if (len && _map[0].length < width)
            {
                for (i = 0; i < len; i++)
                    for (var j:int = _map[i].length; j < width; j++)
                        _map[i].push(new CellModel());
            }
            dispatchEvent(new UserEvent(UserEvent.MAP_DIMENTIONS_CHANGED));
        }
        
        /**
         * Функция возвращает векторный массив инициализированный
         * первым элементом типа CellModel.
         * @return
         */
        private function createInitedRow():Vector.<CellModel>
        {
            var row:Vector.<CellModel> = new Vector.<CellModel>();
            row.push(new CellModel());
            return row;
        }
        
        public function get map():Vector.<Vector.<CellModel>> 
        {
            return _map;
        }
        
    }

}