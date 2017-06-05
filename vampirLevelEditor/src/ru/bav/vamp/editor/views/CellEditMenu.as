package ru.bav.vamp.editor.views 
{
    import fl.controls.Button;
    import fl.controls.CheckBox;
    import fl.controls.ComboBox;
    import fl.controls.Label;
    import fl.controls.RadioButtonGroup;
    import fl.controls.RadioButton;
    import fl.data.DataProvider;
    import flash.display.Graphics;
	import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.filters.DropShadowFilter;
    import ru.bav.vamp.editor.events.UserEvent;
    import ru.bav.vamp.editor.models.CellModel;
    import ru.bav.vamp.editor.models.WallModel;
	
	/**
     * Всплывающее меню редактирования ячейки
     * @author bav
     */
    public class CellEditMenu extends Sprite 
    {
        public static const WIDTH:int = 600;
        public static const HEIGHT:int = 300;
        public static const ROUND_RADIUS:int = 10;
        public static const MARGIN:int = 20;
        public static const WALL_TYPES:Array = [ { label:"normal" }, { label:"door_red" }, { label:"door_yellow" }, { label:"door_blue" }, { label:"door_green" } ];
        public static const ITEM_TYPES:Array = [ { label:"none" }, { label:"red_key" }, { label:"yellow_key" }, { label:"blue_key" }, { label:"green_key" } ];
        
        // Чекбокс вкл/выкл
        private var _enableCheckBox:CheckBox;
        // Чекбоксы для стен
        private var _northCheckbox:CheckBox;
        private var _eastCheckbox:CheckBox;
        private var _southCheckbox:CheckBox;
        private var _westCheckbox:CheckBox;
        // Списки типов стен
        private var _northType:ComboBox;
        private var _eastType:ComboBox;
        private var _southType:ComboBox;
        private var _westType:ComboBox;
        // Список вещей
        private var _itemType:ComboBox;
        // Кнопка Ok
        private var _okButton:Button;
        // Радиобоксы юнитов
        private var _unitGroup:RadioButtonGroup;
        private var _noUnit:RadioButton;
        private var _vampir:RadioButton;
        private var _civil:RadioButton;
        private var _policeman:RadioButton;
        private var _fatPoliceman:RadioButton;
        private var _hunter:RadioButton;
        private var _werewolf:RadioButton;
        
        // Модель ячейки изменяемая в данный момент
        private var _cellModel:CellModel;
        
        public function CellEditMenu() 
        {
            super();
            initBackground();
            initWallsCheckboxes();
            initOkButton();
            initUnits();
            initWallsTypes();
            initItemTypes();
        }
        
        private function initBackground():void
        {
            var g:Graphics = graphics;
            g.lineStyle(1);
            g.beginFill(0xCCCCCC);
            g.drawRoundRect(0, 0, WIDTH, HEIGHT, ROUND_RADIUS, ROUND_RADIUS);
            g.endFill();
            this.filters = [new DropShadowFilter(2, 45, 0, 0.6)];
        }
        
        private function initUnits():void
        {
            _unitGroup = new RadioButtonGroup("units");
            _noUnit = new RadioButton();
            _noUnit.label = "--------";
            _noUnit.x = _northCheckbox.x + _northCheckbox.width + MARGIN * 3;
            _noUnit.y = _northCheckbox.y;
            _noUnit.group = _unitGroup;
            _noUnit.value = null;
            
            _vampir = new RadioButton();
            _vampir.label = "Вампир";
            _vampir.x = _noUnit.x;
            _vampir.y = _noUnit.y + _noUnit.height;
            _vampir.group = _unitGroup;
            _vampir.value = CellModel.VAMPIR;
            
            var step:Number = _vampir.height;
            var h:Number = _vampir.y + step;
            
            _civil = new RadioButton();
            _civil.label = "Житель";
            _civil.x = _vampir.x;
            _civil.y = h;
            _civil.group = _unitGroup;
            _civil.value = CellModel.CIVIL;
            h += step;
            
            _policeman = new RadioButton();
            _policeman.label = "Полицейский";
            _policeman.x = _vampir.x;
            _policeman.y = h;
            _policeman.group = _unitGroup;
            _policeman.value = CellModel.POLICEMAN;
            h += step;
            
            _fatPoliceman = new RadioButton();
            _fatPoliceman.label = "Толстый полицейский";
            _fatPoliceman.x = _vampir.x;
            _fatPoliceman.y = h;
            _fatPoliceman.group = _unitGroup;
            _fatPoliceman.value = CellModel.FAT_POLICEMAN;
            h += step;
            
            _hunter = new RadioButton();
            _hunter.label = "Охотник";
            _hunter.x = _vampir.x;
            _hunter.y = h;
            _hunter.group = _unitGroup;
            _hunter.value = CellModel.HUNTER;
            h += step;
            
            _werewolf = new RadioButton();
            _werewolf.label = "Оборотень";
            _werewolf.x = _vampir.x;
            _werewolf.y = h;
            _werewolf.group = _unitGroup;
            _werewolf.value = CellModel.WEREWOLF;
            
            addChild(_noUnit);
            addChild(_vampir);
            addChild(_civil);
            addChild(_policeman);
            addChild(_fatPoliceman);
            addChild(_hunter);
            addChild(_werewolf);
            
            _unitGroup.selection = _noUnit;
        }
        
        
        private function initWallsCheckboxes():void
        {
            // Включение / выключение ячейки
            _enableCheckBox = new CheckBox();
            _enableCheckBox.label = "On/Off";
            _enableCheckBox.x = MARGIN;
            _enableCheckBox.y = MARGIN;
            addChild(_enableCheckBox);
            // Север
            _northCheckbox = new CheckBox();
            _northCheckbox.label = "Север";
            _northCheckbox.x = MARGIN + 50;
            _northCheckbox.y = MARGIN * 2;
            addChild(_northCheckbox);
            // Восток
            _eastCheckbox = new CheckBox();
            _eastCheckbox.label = "Восток";
            _eastCheckbox.x = MARGIN + 100;
            _eastCheckbox.y = MARGIN * 4;
            addChild(_eastCheckbox);
            // Юг
            _southCheckbox = new CheckBox();
            _southCheckbox.label = "Юг";
            _southCheckbox.x = MARGIN + 50;
            _southCheckbox.y = MARGIN * 6;
            addChild(_southCheckbox);
            // Запад
            _westCheckbox = new CheckBox();
            _westCheckbox.label = "Запад";
            _westCheckbox.x = MARGIN;
            _westCheckbox.y = MARGIN * 4;
            addChild(_westCheckbox);
        }
        
        private function initWallsTypes():void
        {
            var label:Label = new Label();
            label.text = "Север:";
            label.x = MARGIN; label.y = _southCheckbox.y + MARGIN * 2;
            addChild(label);
            _northType = createTypeList("wall");
            _northType.x = label.x + MARGIN * 3; _northType.y = label.y;
            addChild(_northType);
            
            var step:Number = label.height;
            var h:Number = label.y + label.height;
            
            label = new Label();
            label.text = "Восток:";
            label.x = MARGIN; label.y = h;
            addChild(label);
            _eastType = createTypeList("wall");
            _eastType.x = label.x + MARGIN * 3; _eastType.y = label.y;
            addChild(_eastType);
            h += step;
            
            label = new Label();
            label.text = "Юг:";
            label.x = MARGIN; label.y = h;
            addChild(label);
            _southType = createTypeList("wall");
            _southType.x = label.x + MARGIN * 3; _southType.y = label.y;
            addChild(_southType);
            h += step;
            
            label = new Label();
            label.text = "Запад:";
            label.x = MARGIN; label.y = h;
            addChild(label);
            _westType = createTypeList("wall");
            _westType.x = label.x + MARGIN * 3; _westType.y = label.y;
            addChild(_westType);
        }
        
        private function initItemTypes():void
        {
            var label:Label = new Label();
            label.text = "Предмет:";
            label.width = 120;
            label.x = WIDTH - label.width - MARGIN; label.y = MARGIN * 2;
            addChild(label);
            
            _itemType = createTypeList("item");
            _itemType.x = label.x; _itemType.y = label.y + label.height;
            addChild(_itemType);
        }
        
        private function initOkButton():void
        {
            _okButton = new Button();
            _okButton.label = "Apply";
            _okButton.y = HEIGHT - _okButton.height - MARGIN;
            _okButton.x = (WIDTH - _okButton.width) / 2;
            _okButton.addEventListener(MouseEvent.CLICK, okHandler);
            addChild(_okButton);
        }
        
        private function okHandler(event:MouseEvent):void
        {
            // Сохраняем информацию о ячейке в моделе
            updateModel();
            
            dispatchEvent(new UserEvent(UserEvent.UPDATE_SELECTED_CELL));
            if (parent) parent.removeChild(this);
        }
        
        private function updateModel():void
        {
            if (_northCheckbox.selected) {
                if (!_cellModel.north) 
                    _cellModel.north = new WallModel(_northType.selectedLabel);
                else 
                    _cellModel.north.type = _northType.selectedLabel;
            }
            else _cellModel.north = null;
            if (_eastCheckbox.selected) {
                if (!_cellModel.east)
                    _cellModel.east = new WallModel(_eastType.selectedLabel);
                else 
                    _cellModel.east.type = _eastType.selectedLabel;
            }
            else _cellModel.east = null;
            if (_southCheckbox.selected) {
                if (!_cellModel.south) 
                    _cellModel.south = new WallModel(_southType.selectedLabel);
                else 
                    _cellModel.south.type = _southType.selectedLabel;
            }
            else _cellModel.south = null;
            if (_westCheckbox.selected) {
                if (!_cellModel.west) 
                    _cellModel.west = new WallModel(_westType.selectedLabel);
                else 
                    _cellModel.west.type = _westType.selectedLabel;
            }
            else _cellModel.west = null;
            
            _cellModel.unit = _unitGroup.selectedData as String;
            _cellModel.item = (_itemType.selectedLabel != "none") ? _itemType.selectedLabel : "";
            
            _cellModel.enable = _enableCheckBox.selected;
            
            if (!_cellModel.enable)
            {
                if (!_cellModel.north) 
                    _cellModel.north = new WallModel();
                else 
                    _cellModel.north.type = "normal";
                    
                if (!_cellModel.east)
                    _cellModel.east = new WallModel();
                else 
                    _cellModel.east.type = "normal";
                        
                if (!_cellModel.south) 
                    _cellModel.south = new WallModel();
                else 
                    _cellModel.south.type = "normal";
                
                if (!_cellModel.west) 
                    _cellModel.west = new WallModel();
                else 
                    _cellModel.west.type = "normal";
                
            }
        }
        
        public function initCellParams(model:CellModel):void
        {
            _cellModel = model;
            _northCheckbox.selected = Boolean(_cellModel.north);
            _eastCheckbox.selected = Boolean(_cellModel.east);
            _southCheckbox.selected = Boolean(_cellModel.south);
            _westCheckbox.selected = Boolean(_cellModel.west);
            _unitGroup.selectedData = _cellModel.unit;
            
            if (_cellModel.north) _northType.selectedIndex = CellEditMenu.getWallIndex(model.north);
            else _northType.selectedIndex = 0;
            if (_cellModel.east) _eastType.selectedIndex = CellEditMenu.getWallIndex(model.east);
            else _eastType.selectedIndex = 0;
            if (_cellModel.south) _southType.selectedIndex = CellEditMenu.getWallIndex(model.south);
            else _southType.selectedIndex = 0;
            if (_cellModel.west) _westType.selectedIndex = CellEditMenu.getWallIndex(model.west);
            else _westType.selectedIndex = 0;
            
            if (_cellModel.item) _itemType.selectedIndex = CellEditMenu.getItemIndex(model);
            else _itemType.selectedIndex = 0;
            
            _enableCheckBox.selected = _cellModel.enable;
        }
        
        public static function getWallIndex(model:WallModel):int
        {
            var result:int = 0;
            if (model.type == "normal") result = 0;
            else
            {
                if (model.color == "red") result = 1;
                else if (model.color == "yellow") result = 2;
                else if (model.color == "blue") result = 3;
                else if (model.color == "green") result = 4;
            }
            return result;
        }
        
        public static function getItemIndex(model:CellModel):int
        {
            var result:int = 0;
            if (!model.item) result = 0;
            else
            {
                if (model.item == "red_key") result = 1;
                else if (model.item == "yellow_key") result = 2;
                else if (model.item == "blue_key") result = 3;
                else if (model.item == "green_key") result = 4;
            }
            return result;
        }
        
        private function createTypeList(type:String):ComboBox
        {
            var ls:ComboBox = new ComboBox();
            if (type == "wall")
                ls.dataProvider = new DataProvider(WALL_TYPES);
            else if (type == "item")
                ls.dataProvider = new DataProvider(ITEM_TYPES);
            ls.selectedIndex = 0;
            ls.width = 120;
            return ls;
        }
        
    }

}