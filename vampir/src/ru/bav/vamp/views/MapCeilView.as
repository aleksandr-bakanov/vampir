package ru.bav.vamp.views {
    import flash.display.Bitmap;
    import flash.display.DisplayObject;
	import flash.display.Sprite;
    import flash.display.Graphics;
    import ru.bav.vamp.models.consts.WallType;
    import ru.bav.vamp.models.MapCellModel;
    import ru.bav.vamp.models.Wall;
    import ru.bav.vamp.events.UserEvent;
	
	/**
     * Map ceil view.
     * @author bav
     */
    public class MapCeilView extends Sprite {
        // Ceil size
        public static const CELL_SIZE:Number = 100;
        
        // Array of walls
        private var _walls:/*WallView*/Array = [];
        
        private var _model:MapCellModel;
        private var _view:Cell_asset;
        
        public function MapCeilView(ceilInfo:MapCellModel) {
            _model = ceilInfo;
            _model.addEventListener(UserEvent.OPEN_DOOR, openDoor);
            drawCeil(_model.type);
            drawWalls(_model.walls);
        }
        
        private function openDoor(event:UserEvent):void {
			var index:int = event.data as int;
            var door:DisplayObject = _walls[index] as DisplayObject;
            removeChild(door);
            _walls[index] = null;
        }
        
        private function drawCeil(type:String = "normal"):void {
            _view = new Cell_asset();
			_view.width = _view.height = MapCeilView.CELL_SIZE;
            _view.rotation = int(Math.random() * 4) * 90;
			_view.x = _view.y = _view.width / 2;
            addChild(_view);
        }
        
        private function drawWalls(walls:Array):void {
            for (var i:int = 0; i < walls.length; i++)
                if (walls[i]) {
                    var wall:WallView;
                    if ((walls[i] as Wall).type == WallType.NORMAL)
                        wall = new WallView(WallType.DIRECTIONS[i], (walls[i] as Wall).type);
                    else
                        wall = new WallView(WallType.DIRECTIONS[i], (walls[i] as Wall).type, (walls[i] as Wall).keyColor);
                    if (i == 1) wall.x = CELL_SIZE;
                    else if (i == 2) wall.y = CELL_SIZE;
                    _walls[i] = wall;
                    addChild(wall);
                }
        }
        
        public function destroy():void {
            if (_walls.length > 0)
                while (_walls.length > 0)
                    removeChild(_walls.pop() as DisplayObject);
			if (contains(_view))
				removeChild(_view);
        }
        
    }

}