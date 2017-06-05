package ru.bav.vamp.editor.views 
{
    import fl.controls.Button;
    import fl.controls.Label;
    import fl.controls.TextInput;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.net.FileReference;
    import flash.text.TextFieldAutoSize;
    import flash.ui.Mouse;
    import flash.ui.MouseCursor;
    import flash.ui.Keyboard;
    import flash.xml.XMLNode;
    import ru.bav.vamp.editor.events.UserEvent;
    import ru.bav.vamp.editor.models.CellModel;
    import ru.bav.vamp.editor.models.MainModel;
    import ru.bav.vamp.editor.models.WallModel;
    
    /**
     * Главная вьюшка
     * @author bav
     */
    public class MainView extends Sprite 
    {
        private var _mainModel:MainModel;
        
        // ====================================================================
        //   Элементы управления
        // ====================================================================
        // Контейнер управляющих элементов, кнопок, полей ввода и т.д.
        private var _controls:Sprite;
        private var _widthLevelLabel:Label;
        private var _heightLevelLabel:Label;
        private var _widthLevelInput:TextInput;
        private var _heightLevelInput:TextInput;
        private var _submitArea:Button;
        private var _saveButton:Button;
        private var _loadButton:Button;
        private var _cellEditMenu:CellEditMenu;
        
        // ====================================================================
        //   Элементы игрового поля
        // ====================================================================
        private var _map:Sprite;
        // Ссылки на ячейки карты. Индексы соответствуют индексам в модели.
        private var _cells:Array;
        // Выбранная в данный момент ячейка, ссылка используется для возвращения
        // выбранной ячейки в исходное состояние после окончания ее редактирования.
        private var _selectedCell:CellView;
        
        // Флаг перетаскивания карты
        private var _isSpaceDown:Boolean = false;
        private var _oldMouseX:Number = 0;
        private var _oldMouseY:Number = 0;
        private var _newMouseX:Number = 0;
        private var _newMouseY:Number = 0;
        
        // Объект для загрузки внешнего xml
        private var _fr:FileReference;
        
        public function MainView(model:MainModel) 
        {
            super();
            _mainModel = model;
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(event:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            initMap();
            initControls();
            initEditMenu();
            initHandlers();
            
            _fr = new FileReference();
            _fr.addEventListener(Event.SELECT, loadExternalXML);
            _fr.addEventListener(Event.COMPLETE, completeLoadExternalXML);
        }
        
        /**
         * Функция инициализации элементов управления.
         */
        private function initControls():void
        {
            // Инициализация контейнера
            _controls = new Sprite();
            _controls.graphics.beginFill(0xCCCCCC);
            _controls.graphics.drawRect(0, 0, stage.stageWidth, 25);
            _controls.graphics.endFill();
            addChild(_controls);
            // Метка поля ввода ширины уровня
            _widthLevelLabel = new Label();
            _widthLevelLabel.autoSize = TextFieldAutoSize.RIGHT;
            _widthLevelLabel.text = "Клеток по ширине:";
            _controls.addChild(_widthLevelLabel);
            // Поле ввода ширины уровня
            _widthLevelInput = new TextInput();
            _widthLevelInput.x = _widthLevelLabel.width + _widthLevelLabel.x;
            _widthLevelInput.width = 50;
            _widthLevelInput.restrict = "0-9";
            _widthLevelInput.maxChars = 2;
            _controls.addChild(_widthLevelInput);
            // Метка поля ввода высоты уровня
            _heightLevelLabel = new Label();
            _heightLevelLabel.autoSize = TextFieldAutoSize.RIGHT;
            _heightLevelLabel.x = _widthLevelInput.x + _widthLevelInput.width + 20;
            _heightLevelLabel.text = "Клеток по высоте:";
            _controls.addChild(_heightLevelLabel);
            // Поле ввода высоты уровня
            _heightLevelInput = new TextInput();
            _heightLevelInput.x = _heightLevelLabel.width + _heightLevelLabel.x;
            _heightLevelInput.width = 50;
            _heightLevelInput.restrict = "0-9";
            _heightLevelInput.maxChars = 2;
            _controls.addChild(_heightLevelInput);
            // Кнопка подтверждения размеров поля.
            _submitArea = new Button();
            _submitArea.width = 200;
            _submitArea.label = "Установить размеры поля";
            _submitArea.x = _heightLevelInput.x + _heightLevelInput.width + 20;
            _controls.addChild(_submitArea);
            // Сохранение карты
            _saveButton = new Button();
            _saveButton.label = "Сохранить";
            _saveButton.x = stage.stageWidth - _saveButton.width;
            _saveButton.addEventListener(MouseEvent.CLICK, saveClickHandler);
            _controls.addChild(_saveButton);
            // Загрузка уровня из внешнего xml
            _loadButton = new Button();
            _loadButton.label = "Load level";
            _loadButton.x = _saveButton.x - _loadButton.width - 10;
            _loadButton.addEventListener(MouseEvent.CLICK, loadClickHandler);
            _controls.addChild(_loadButton);
            
            // Меню редактирования ячейки
            _cellEditMenu = new CellEditMenu();
        }
        
        private function loadClickHandler(event:MouseEvent):void 
        {
            trace("browse");
            _fr.browse();
        }
        
        private function loadExternalXML(event:Event):void 
        {
            trace("load");
            _fr.load();
        }
        
        private function completeLoadExternalXML(event:Event):void 
        {
            trace("complete");
            _mainModel.parceExternalXML(new XML(_fr.data.readUTFBytes(_fr.data.length)));
        }
        
        private function initMap():void
        {
            _map = new Sprite();
            _map.addEventListener(MouseEvent.CLICK, cellClickHandler, true);
            addChild(_map);
            _cells = [];
        }
        
        private function initEditMenu():void
        {
            _cellEditMenu = new CellEditMenu();
            _cellEditMenu.x = (stage.stageWidth - _cellEditMenu.width) / 2;
            _cellEditMenu.y = (stage.stageHeight - _cellEditMenu.height) / 2;
            _cellEditMenu.addEventListener(UserEvent.UPDATE_SELECTED_CELL, updateSelectedCell);
        }
        
        private function updateSelectedCell(event:UserEvent):void 
        {
            if (!_selectedCell) return;
            var x:int = int(_selectedCell.x / CellView.SIZE);
            var y:int = int(_selectedCell.y / CellView.SIZE);
            var model:CellModel = _mainModel.map[y][x] as CellModel;
            _selectedCell.updateByModel(model);
            // Установка соответствующих стен в соседних ячейках.
            updateCellsAround(x, y);
        }
        
        /**
         * Функция приводит в соответствие соседнии ячейки относительно данной.
         * @param	x
         * @param	y
         */
        private function updateCellsAround(x:int, y:int):void
        {
            var model:CellModel = _mainModel.map[y][x] as CellModel;
            // Установка соответствующих стен в соседних ячейках.
            var tempModel:CellModel;
            var tempView:CellView;
            var tempX:int, tempY:int;
            // Север
            if (model.north) {
                tempX = x; tempY = y - 1;
                if (tempY >= 0 && tempX < _mainModel.map[tempY].length) {
                    tempModel = _mainModel.map[tempY][tempX] as CellModel;
                    tempModel.south = model.north;
                    if (_cells[tempY][tempX])
                        (_cells[tempY][tempX] as CellView).updateByModel(tempModel);
                }
            }
            else {
                tempX = x; tempY = y - 1;
                if (tempY >= 0 && tempX < _mainModel.map[tempY].length) {
                    tempModel = _mainModel.map[tempY][tempX] as CellModel;
                    tempModel.south = null;
                    if (_cells[tempY][tempX])
                        (_cells[tempY][tempX] as CellView).updateByModel(tempModel);
                }
            }
            // Восток
            if (model.east) {
                tempX = x + 1; tempY = y;
                if (tempX < _mainModel.map[tempY].length) {
                    tempModel = _mainModel.map[tempY][tempX] as CellModel;
                    tempModel.west = model.east;
                    if (_cells[tempY][tempX])
                        (_cells[tempY][tempX] as CellView).updateByModel(tempModel);
                }
            }
            else {
                tempX = x + 1; tempY = y;
                if (tempX < _mainModel.map[tempY].length) {
                    tempModel = _mainModel.map[tempY][tempX] as CellModel;
                    tempModel.west = null;
                    if (_cells[tempY][tempX])
                        (_cells[tempY][tempX] as CellView).updateByModel(tempModel);
                }
            }
            // Юг
            if (model.south) {
                tempX = x; tempY = y + 1;
                if (tempY < _mainModel.map.length && tempX < _mainModel.map[tempY].length) {
                    tempModel = _mainModel.map[tempY][tempX] as CellModel;
                    tempModel.north = model.south;
                    if (_cells[tempY][tempX])
                        (_cells[tempY][tempX] as CellView).updateByModel(tempModel);
                }
            }
            else {
                tempX = x; tempY = y + 1;
                if (tempY < _mainModel.map.length && tempX < _mainModel.map[tempY].length) {
                    tempModel = _mainModel.map[tempY][tempX] as CellModel;
                    tempModel.north = null;
                    if (_cells[tempY][tempX])
                        (_cells[tempY][tempX] as CellView).updateByModel(tempModel);
                }
            }
            // Запад
            if (model.west) {
                tempX = x - 1; tempY = y;
                if (tempX >= 0) {
                    tempModel = _mainModel.map[tempY][tempX] as CellModel;
                    tempModel.east = model.west;
                    if (_cells[tempY][tempX])
                        (_cells[tempY][tempX] as CellView).updateByModel(tempModel);
                }
            }
            else {
                tempX = x - 1; tempY = y;
                if (tempX >= 0) {
                    tempModel = _mainModel.map[tempY][tempX] as CellModel;
                    tempModel.east = null;
                    if (_cells[tempY][tempX])
                        (_cells[tempY][tempX] as CellView).updateByModel(tempModel);
                }
            }
        }
        
        /**
         * Функция приводит в соответствие стены всех ячеек карты.
         * Вызывается после добавление новых строк или столбцов.
         */
        private function matchAllCells():void
        {
            for (var i:int = 0; i < _mainModel.map.length; i++)
            {
                var len:int = _mainModel.map[i].length;
                for (var j:int = 0; j < len; j++)
                    updateCellsAround(j, i);
            }
        }
        
        /**
         * Инициализация слушателей событий.
         */
        private function initHandlers():void
        {
            // Слушатели элементов управления
            _submitArea.addEventListener(MouseEvent.CLICK, submitAreaClickHandler);
            
            // Слушатели модели
            _mainModel.addEventListener(UserEvent.MAP_DIMENTIONS_CHANGED, mapDimentionChangedHandler);
            
            // Перетаскивание карты
            stage.addEventListener(KeyboardEvent.KEY_DOWN, stageSpaceDownHandler);
            stage.addEventListener(KeyboardEvent.KEY_UP, stageSpaceUpHandler);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
        }
        
        /**
         * Слушатель MOUSE_MOVE на stage. Отслеживает предыдущие и текущие координаты
         * мыши. Если зажат пробел, перемещает карту на разницу этих координат.
         * @param	event
         */
        private function stageMouseMoveHandler(event:MouseEvent):void 
        {
            _oldMouseX = _newMouseX;
            _oldMouseY = _newMouseY;
            _newMouseX = event.stageX;
            _newMouseY = event.stageY;
            if (_isSpaceDown)
            {
                _map.x += _newMouseX - _oldMouseX;
                _map.y += _newMouseY - _oldMouseY;
            }
        }
        
        /**
         * Функция включения режима перетаскивания карты.
         * Помимо основного назначения меняет тип курсора.
         * @param	event
         */
        private function stageSpaceDownHandler(event:KeyboardEvent):void 
        {
            if (event.keyCode == Keyboard.SPACE) {
                if (!_isSpaceDown) {
                    _isSpaceDown = true;
                    Mouse.cursor = MouseCursor.HAND;
                }
            }
        }
        
        /**
         * Функция отключения режима перетаскивания карты.
         * Помимо основного назначения меняет тип курсора.
         * @param	event
         */
        private function stageSpaceUpHandler(event:KeyboardEvent):void 
        {
            if (event.keyCode == Keyboard.SPACE) {
                if (_isSpaceDown) {
                    _isSpaceDown = false;
                    Mouse.cursor = MouseCursor.AUTO;
                }
            }
        }
        
        
        /**
         * Обработчик клика по кнопке "Установить размеры поля". Шлет наверх событие,
         * в которое пишет обновленные размеры поля. Предотвращает отправку отрицательных
         * величин.
         * @param	event
         */
        private function submitAreaClickHandler(event:MouseEvent):void
        {
            var w:int = parseInt(_widthLevelInput.text);
            var h:int = parseInt(_heightLevelInput.text);
            if (w < 0 || h < 0) return;
            dispatchEvent(new UserEvent(UserEvent.MAP_DIMENTIONS_CHANGED, { width:w, height:h } ));
        }
        
        /**
         * Функция устанавливает размер игрового поля, согласно данным хранящимся в модели.
         * Таким образом первой изменяется модель, что правильно.
         * @param	event
         */
        private function mapDimentionChangedHandler(event:UserEvent):void
        {
            // Определим сколько имеется на данный момент клеток по вертикали и горизонтали
            var existHeight:int = _map.height / CellView.SIZE;
            var existWidth:int = _map.width / CellView.SIZE;
            if (!_mainModel.mapHeight || !_mainModel.mapWidth) return;
            // Если меньше, чем нужно, добавим
            var i:int, j:int, len:int, cell:CellView;
            len = _mainModel.map.length;
            // Добавляем строки.
            if (existHeight < _mainModel.map.length)
                addRows(_mainModel.map.length - existHeight);
            // Иначе, если нужно убрать несколько рядов
            else if (existHeight > _mainModel.map.length)
                removeRows(existHeight - _mainModel.map.length);
            
            // Тут надо пересчитать existWidth, потому что она могла измениться с добавлением строк
            existWidth = _map.width / CellView.SIZE;
            // Добавляем столбцы
            if (_mainModel.map[0] && existWidth < _mainModel.map[0].length)
                addColumns(_mainModel.map[0].length - existWidth);
            else if (_mainModel.map[0] && existWidth > _mainModel.map[0].length)
                removeColumns(existWidth - _mainModel.map[0].length);
                
            //centerMap();
        }
        
        /**
         * Функция центрирует карту.
         */
        private function centerMap():void 
        {
            _map.x = (stage.stageWidth - _map.width) / 2;
            _map.y = (stage.stageHeight - _map.height) / 2;
        }
        
        /**
         * Функция добавляет указанное количество строк в карту.
         * @param	numRows
         */
        private function addRows(numRows:int):void
        {
            var existHeight:int = _map.height / CellView.SIZE;
            var existWidth:int = _map.width / CellView.SIZE;
            var i:int, j:int;
            for (i = existHeight; i < existHeight + numRows; i++)
            {
                // Если уже было сколько-то ячеек в ширину, то existWidth != 0
                // Добавляем нужное количество строк ячеек
                if (existWidth > 0)
                    for (j = 0; j < existWidth; j++)
                        addCell(j, i);
                // Иначе добавляем по одной ячейке на ряд.
                else
                    addCell(j, i);
            }
            matchAllCells();
        }
        
        /**
         * Функция удаляет указанное количество строк из карты.
         * @param	numRows
         */
        private function removeRows(numRows:int):void
        {
            var existHeight:int = _map.height / CellView.SIZE;
            var existWidth:int = _map.width / CellView.SIZE;
            if (!existHeight || !existWidth) return;
            var i:int, j:int;
            for (i = existHeight - 1; i > existHeight - numRows - 1; i--)
            {
                for (j = 0; j < existWidth; j++)
                    removeCell(j, i);
            }
        }
        
        /**
         * Функция добавляет указанное количество колонок в карту.
         * @param	numColumns
         */
        private function addColumns(numColumns:int):void
        {
            var existHeight:int = _map.height / CellView.SIZE;
            var existWidth:int = _map.width / CellView.SIZE;
            var i:int, j:int;
            for (i = 0; i < existHeight; i++)
                for (j = existWidth; j < existWidth + numColumns; j++)
                    addCell(j, i);
            matchAllCells();
        }
        
        /**
         * Функция удаляет указанное количество колонок из карты.
         * @param	numColumns
         */
        private function removeColumns(numColumns:int):void
        {
            var existHeight:int = _map.height / CellView.SIZE;
            var existWidth:int = _map.width / CellView.SIZE;
            var i:int, j:int;
            for (i = 0; i < existHeight; i++)
                for (j = existWidth - 1; j > existWidth - numColumns - 1; j--)
                    removeCell(j, i);
        }
        
        /**
         * Функция добавляет новую ячейку на указзаные координаты.
         * @param	_x
         * @param	_y
         */
        private function addCell(_x:int, _y:int):void
        {
            var cell:CellView = new CellView();
            cell.x = _x * CellView.SIZE;
            cell.y = _y * CellView.SIZE;
            _map.addChild(cell);
            // Сохраняем ссылку на эту ячейку.
            if (!_cells[_y]) _cells[_y] = [];
            _cells[_y][_x] = cell;
        }
        
        /**
         * Функция удаляет ячейку с указанными индексами.
         * @param	_x
         * @param	_y
         */
        private function removeCell(_x:int, _y:int):void
        {
            var cell:CellView = (_cells[_y]) ? _cells[_y][_x] as CellView : null;
            if (cell)
                cell.destroy();
            if (_cells[_y])
                _cells[_y][_x] = null;
        }
        
        /**
         * Функция вызывает меню редактирования ячейки и передает ему
         * необходимые параметры.
         * @param	event
         */
        private function cellClickHandler(event:MouseEvent):void
        {
            var _x:int = (event.target as DisplayObject).parent.x / CellView.SIZE;
            var _y:int = (event.target as DisplayObject).parent.y / CellView.SIZE;
            var model:CellModel = _mainModel.map[_y][_x] as CellModel;
            if (!model) return;
            _selectedCell = _cells[_y][_x] as CellView;
            _cellEditMenu.initCellParams(model);
            showEditMenu();
        }
        
        /**
         * Функция показа меню редактирования ячейки
         */
        private function showEditMenu():void
        {
            addChild(_cellEditMenu);
        }
        
        /**
         * Функция скрытия меню редактирования ячейки
         */
        private function hideEditMenu():void
        {
            if (_cellEditMenu.parent) removeChild(_cellEditMenu);
        }
        
        private function saveClickHandler(event:MouseEvent):void
        {
            // Сначала установим внешние стены
            for (var a:int = 0; a < _mainModel.mapWidth; a++) {
                (_mainModel.map[0][a] as CellModel).north = new WallModel();
                (_mainModel.map[_mainModel.mapHeight - 1][a] as CellModel).south = new WallModel();
            }
            for (var b:int = 0; b < _mainModel.mapHeight; b++) {
                (_mainModel.map[b][0] as CellModel).west = new WallModel();
                (_mainModel.map[b][_mainModel.mapWidth - 1] as CellModel).east = new WallModel();
            }
            
            var xml:XML = <data><mapSize/><mapCeils></mapCeils><units></units><items></items></data>;
            xml.mapSize.@["width"] = _mainModel.mapWidth.toString();
            xml.mapSize.@["height"] = _mainModel.mapHeight.toString();
            for (var i:int = 0; i < _mainModel.mapHeight; i++)
                for (var j:int = 0; j < _mainModel.mapWidth; j++)
                {
                    if ((_mainModel.map[i][j] as CellModel).enable)
                    {
                        var cell:XML = new XML((_mainModel.map[i][j] as CellModel).getXML());
                        cell.@["x"] = j.toString();
                        cell.@["y"] = i.toString();
                        xml.mapCeils.appendChild(cell);
                        var unit:String = (_mainModel.map[i][j] as CellModel).unit;
                        if (unit) {
                            var uxml:XML = <unit/>;
                            uxml.@["type"] = unit;
                            uxml.@["x"] = j.toString();
                            uxml.@["y"] = i.toString();
                            xml.units.appendChild(uxml);
                        }
                        var item:String = (_mainModel.map[i][j] as CellModel).item;
                        if (item)
                        {
                            var ixml:XML = <key/>;
                            ixml.@["color"] = item.split("_")[0] as String;
                            ixml.@["x"] = j.toString();
                            ixml.@["y"] = i.toString();
                            xml.items.appendChild(ixml);
                        }
                    }
                }
            var str:String = xml.toXMLString();
            str = str.replace(/>(\s)*</g, "><");
            var fr:FileReference = new FileReference();
            fr.save(str, "le.xml");
        }
        
    }

}