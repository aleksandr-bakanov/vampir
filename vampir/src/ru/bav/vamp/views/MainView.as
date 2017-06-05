package ru.bav.vamp.views {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.Point;
	import flash.utils.Timer;
    import ru.bav.vamp.controllers.*;
    import ru.bav.vamp.controllers.units.*;
    import ru.bav.vamp.events.*;
    import ru.bav.vamp.interfaces.IDestroyable;
    import ru.bav.vamp.models.*;
    import ru.bav.vamp.models.consts.*;
    import ru.bav.vamp.views.units.*;
    import ru.bav.vamp.views.items.*;
    
    import ru.bav.utils.Button;
    
	/**
     * Main game view.
     * @author bav
     */
    public class MainView extends Sprite {
        public static const STAGE_WIDTH:int = 800;// 640;
        public static const STAGE_HEIGHT:int = 600;// 480;
        public static const ZERO_POINT:Point = new Point();
        
        // Game main class instance.
        private var _host:DisplayObjectContainer;
        // Game main model instance.
        private var _mainModel:MainModel;
        private var _totalMask:Sprite;
        // Level map view
        private var _levelMap:LevelMapView;
        private var _unitsCont:Sprite;
        // Units
        private var _units:Array /* of UnitViewBase */;
        // Items
        private var _items:Array /* of DisplayObject */ = [];
        // Info panel
        private var _infoPanel:InfoPanel;
        // Main menu
        private var _mainMenu:MainMenuView;
		// Game over menu
		private var _gameOverMenu:GameOverMenuView;
		// Shop menu
		private var _shopMenu:ShopMenuView;
        // Levels menu
        private var _levelsMenu:LevelsMenuView;
        private var _levelCompleteMenu:LevelCompleteMenuView;
        // Player
        private var _player:DisplayObject;
        // Таймер сортирующий персонажей согласно их координате y
        private var _unitSortTimer:Timer;
		// Кровавый душ
		private var _bloodShower:Blood_shower_asset;
        
        public function MainView(host:DisplayObjectContainer, model:MainModel) {
            _host = host;
            _mainModel = model;
            initTotalMask();
            _host.addChild(this);
            this.mask = _totalMask;
            
            initInfoPanel();
            
            initMainMenu();
            initLevelsMenu();
            
            _mainModel.addEventListener(UserEvent.INIT_LEVEL_MAP, initLevelMap);
            _mainModel.addEventListener(UserEvent.INIT_UNITS, initUnits);
            _mainModel.addEventListener(UserEvent.LEVEL_COMPLETE, levelCompleteHandler);
            Dispatcher.instance.addEventListener(UserEvent.PLAYER_IS_DEAD, startGameOverAnimation);
            this.addEventListener(UserEvent.SHOW_SHOP_MENU, showShopMenu, true);
            this.addEventListener(UserEvent.RETURN_TO_MAIN_MENU, returnToMainMenu, true);
            
            initUnitSortTimer();
        }
		
		private function returnToMainMenu(e:UserEvent):void 
		{
			clearLevel();
			openLevelsMenu();
		}
        
        private function initTotalMask():void {
            _totalMask = new Sprite();
            _totalMask.graphics.beginFill(0x000000, 0);
            _totalMask.graphics.drawRect(0, 0, STAGE_WIDTH, STAGE_HEIGHT);
            if (_host) _host.addChild(_totalMask);
        }
        
        private function initUnitSortTimer():void {
            _unitSortTimer = new Timer(100);
            _unitSortTimer.addEventListener(TimerEvent.TIMER, sortUnitsByY);
        }
        
        private function sortUnitsByY(event:TimerEvent):void {
            var arr:Array = []; var i:int;
            var len:int = _units.length;
            for (i = 0; i < len; i++) arr.push(_units[i]);
            arr.sort(unitsSortFunction);
            for (i = 0; i < len; i++) _unitsCont.addChild(arr[i]);
        }
        
        private function unitsSortFunction(a:DisplayObject, b:DisplayObject):int {
            var result:int;
            if (a.y == b.y) result = 0;
            else if (a.y > b.y) result = 1;
            else if (a.y < b.y) result = -1;
            return result;
        }
		
		private function showShopMenu(event:UserEvent):void {
			if (!_shopMenu) {
				_shopMenu = new ShopMenuView(_mainModel);
			}
			addChild(_shopMenu);
			_mainModel.dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function startGameOverAnimation(event:UserEvent):void {
			if (!_gameOverMenu) {
				_gameOverMenu = new GameOverMenuView(_mainModel);
				_bloodShower.addFrameScript(_bloodShower.totalFrames - 1, showGameOver);
			}
			addChild(_bloodShower);
			_bloodShower.play();
		}
		
        private function showGameOver():void {
			addChild(_gameOverMenu);
			_bloodShower.gotoAndStop(1);
			removeChild(_bloodShower);
			clearLevel();
        }
		
        private function levelCompleteHandler(event:UserEvent):void {
            clearLevel();
            addChild(_levelCompleteMenu);
        }
		
		private function clearLevel():void {
            _unitSortTimer.stop();
			destroyUnits();
            removeItems();
		}
        
        private function removeItems():void {
            while (_items.length) {
                var item:DisplayObject = _items.pop() as DisplayObject;
                _levelMap.removeChild(item);
                (item as IDestroyable).destroy();
            }
        }
        
        private function initMainMenu():void {
            _mainMenu = new MainMenuView();
            addChild(_mainMenu);
            _mainMenu.gameStartButton.addEventListener(MouseEvent.CLICK, openLevelsMenu);
			
			_bloodShower = new Blood_shower_asset();
			// Временное решение
			_bloodShower.gotoAndStop(_bloodShower.totalFrames);
			_bloodShower.width = STAGE_WIDTH + 50;
			_bloodShower.height = STAGE_HEIGHT;
			_bloodShower.gotoAndStop(1);
        }
		
        private function initLevelsMenu():void {
            _levelsMenu = new LevelsMenuView(_mainModel);
            _levelsMenu.addEventListener(MouseEvent.CLICK, startLevel, true);
            _levelCompleteMenu = new LevelCompleteMenuView(_mainModel);
            addEventListener(UserEvent.OPEN_LEVELS_MENU, openLevelsMenu, true);
        }
        
        private function initLevelMap(event:UserEvent):void {
            if (!_levelMap)
                _levelMap = new LevelMapView();
            _levelMap.initLevelMap(_mainModel.map);
            _levelMap.x = (MainView.STAGE_WIDTH - _levelMap.width) / 2;
            _levelMap.y = (MainView.STAGE_HEIGHT - _levelMap.height) / 2;
            addChildAt(_levelMap, 0);
            if (!_unitsCont)
                _unitsCont = new Sprite();
            _unitsCont.x = _levelMap.x;
            _unitsCont.y = _levelMap.y;
            addChild(_unitsCont);
			// Панель информации лежит выше юнитов.
			addChild(_infoPanel);
			_infoPanel.startTimer();
        }
        
        private function initUnits(event:UserEvent):void {
            clearLevel();
            while (_unitsCont.numChildren)
                _unitsCont.removeChildAt(0);
            _units = [];
            var unitsInfo:Array = _mainModel.units;
            for (var i:int = 0; i < unitsInfo.length; i++) {
                var model:UnitModel = unitsInfo[i] as UnitModel;
                var controller:UnitController;
                var view:UnitViewBase;
                if (model.type == UnitType.POLICEMAN) {
                    _units[i] = view = new Policeman();
                    controller = new NPCController(_mainModel, model, view);
                }
                if (model.type == UnitType.FAT_POLICEMAN) {
                    _units[i] = view = new FatPoliceman();
                    controller = new NPCController(_mainModel, model, view);
                }
                else if (model.type == UnitType.HUNTER) {
                    _units[i] = view = new Hunter();
                    controller = new NPCController(_mainModel, model, view);
                }
                else if (model.type == UnitType.CIVIL) {
                    _units[i] = view = new Civil();
                    controller = new NPCController(_mainModel, model, view);
                }
                else if (model.type == UnitType.GHOUL) {
                    _units[i] = view = new Ghoul();
                    controller = new NPCController(_mainModel, model, view);
                }
                else if (model.type == UnitType.VAMPIR) {
                    _player = _units[i] = view = new Player();
                    controller = new PlayerController(_mainModel, model, view, stage, this);
                    _infoPanel.playerInfo = model;
                }
                else if (model.type == UnitType.WEREWOLF) {
                    _units[i] = view = new Werewolf();
                    controller = new NPCController(_mainModel, model, view);
                }
                
                _mainModel.unitsDict[view] = model;
                
                view.allUnits = _units;
                _unitsCont.addChild(view);
            }
            centerViewByPlayer();
            // Запускаем таймер сортировки юнитов.
            _unitSortTimer.start();
        }
        
        public function initItems(xml:XML):void {
            initKeys(xml.items.key);
            // Центрируем карту по игроку
            centerViewByPlayer();
        }
        
        private function initKeys(xml:XMLList):void {
			_infoPanel.removeAllKeys();
            for each (var keyInfo:XML in xml){
                var key:Key = makeKey(keyInfo);
                _levelMap.addChild(key);
                _items.push(key);
            }
        }
        
        private function makeKey(xml:XML):Key {
            var key:Key = new Key(xml.@color, _player);
            key.x = MapCeilView.CELL_SIZE / 2 + MapCeilView.CELL_SIZE * parseInt(xml.@x);
            key.y = MapCeilView.CELL_SIZE / 2 + MapCeilView.CELL_SIZE * parseInt(xml.@y);
            return key;
        }
        
        public function centerViewByPlayer():void {
            if (!_player) return;
            var dp:Point;
            var dx:Number;
            var dy:Number;
            if (_levelMap.width > MainView.STAGE_WIDTH) {
                dp = _player.localToGlobal(MainView.ZERO_POINT);
                dx = MainView.STAGE_WIDTH / 2 - dp.x;
                _levelMap.x += dx;
                _unitsCont.x += dx;
            }
            if (_levelMap.height > MainView.STAGE_HEIGHT - InfoPanel.HEIGHT) {
                dp = _player.localToGlobal(MainView.ZERO_POINT);
                dy = MainView.STAGE_HEIGHT / 2 - dp.y;
                _levelMap.y += dy;
                _unitsCont.y += dy;
            }
        }
        
        private function initInfoPanel():void {
            _infoPanel = new InfoPanel(_mainModel);
            _infoPanel.x = (MainView.STAGE_WIDTH - _infoPanel.width) / 2;
            addChild(_infoPanel);
        }
        
        private function openLevelsMenu(event:Object = null):void {
            if (this.contains(_mainMenu)) removeChild(_mainMenu);
            addChild(_levelsMenu);
        }
        
        
        private function startLevel(event:MouseEvent):void {
			if (event.target.name.indexOf("level_") == 0) {
            var levelNumber:int = parseInt(event.target.name.split("_")[1]);
            //if (_mainModel.allowedLevels["level_" + levelNumber]) {
				Dispatcher.instance.dispatchEvent(new UserEvent(UserEvent.START_LEVEL, levelNumber));
				if (this.contains(_levelsMenu)) removeChild(_levelsMenu);
            //}
			}
        }
        
        private function destroyUnits():void {
            if (_units)
                while (_units.length) {
                    var unit:UnitViewBase = _units.pop() as UnitViewBase;
                    unit.dispatchEvent(new UserEvent(UserEvent.DESTROY_UNIT));
                }
        }
        
    }

}