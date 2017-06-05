package ru.bav.vamp.editor.views 
{
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.MovieClip;
	import flash.display.Sprite;
    import flash.events.MouseEvent;
    import com.greensock.TweenLite;
    import flash.filters.DropShadowFilter;
    import ru.bav.vamp.editor.models.CellModel;
    import ru.bav.vamp.editor.models.WallModel;
	
	/**
     * Вьюшка ячейки.
     * @author bav
     */
    public class CellView extends Sprite 
    {
        public static const SIZE:int = 40;
        public static const COLOR:uint = 0xBBBBBB;
        public static const GROW_TIME:Number = 0.3;
        
        public var asset:Cell_asset;
        public var walls:Array;
        
        public var unit:DisplayObject;
        public var item:MovieClip;
        
        public function CellView() 
        {
            super();
            drawCell();
            initHandlers();
        }
        
        private function drawCell():void
        {
            walls = [];
            asset = new Cell_asset();
            asset.gotoAndStop("normal");
            asset.x -= asset.width / 2;
            asset.y -= asset.height / 2;
            addChild(asset);
        }
        
        private function initHandlers():void
        {
            addEventListener(MouseEvent.ROLL_OVER, increaseSize);
            addEventListener(MouseEvent.ROLL_OUT, decreaseSize);
        }
        
        private function increaseSize(event:MouseEvent):void
        {
            if (parent) parent.addChild(this);
            TweenLite.to(this, GROW_TIME, { scaleX:1.2, scaleY:1.2 } );
        }
        
        private function decreaseSize(event:MouseEvent):void
        {
            TweenLite.to(this, GROW_TIME, { scaleX:1, scaleY:1 } );
        }
        
        public function destroy():void
        {
            if (parent)
                parent.removeChild(this);
            graphics.clear();
            removeEventListener(MouseEvent.ROLL_OVER, increaseSize);
            removeEventListener(MouseEvent.ROLL_OUT, decreaseSize);
        }
        
        public function updateByModel(model:CellModel):void
        {
            asset.gotoAndStop(model.type);
            if (model.north) addWall(0, model.north);
            else removeWall(0);
            if (model.east) addWall(1, model.east);
            else removeWall(1);
            if (model.south) addWall(2, model.south);
            else removeWall(2);
            if (model.west) addWall(3, model.west);
            else removeWall(3);
            
            if (unit && unit.parent) unit.parent.removeChild(unit);
            if (model.unit == CellModel.VAMPIR) unit = new Vampir_asset();
            else if (model.unit == CellModel.CIVIL) unit = new Civil_asset();
            else if (model.unit == CellModel.POLICEMAN) unit = new Policeman_asset();
            else if (model.unit == CellModel.FAT_POLICEMAN) unit = new Fat_policeman_asset();
            else if (model.unit == CellModel.HUNTER) unit = new Hunter_asset();
            else if (model.unit == CellModel.WEREWOLF) unit = new Werewolf_asset();
            else unit = null;
            if (unit) addChild(unit);
            
            if (item && item.parent) item.parent.removeChild(item);
            if (model.item) {
                item = new Key_asset();
                item.gotoAndStop(CellEditMenu.getItemIndex(model));
            }
            else item = null;
            if (item) addChild(item);
            
            this.alpha = (model.enable) ? 1 : 0.1;
        }
        
        /**
         * Функция добавляет стену на указанное направление
         * @param	direction   Направления север = 0, восток = 1, юг = 2, запад = 3
         */
        private function addWall(direction:int, model:WallModel):void
        {
            var wall:Wall_asset = walls[direction] as Wall_asset;
            if (!wall) 
            {
                wall = new Wall_asset();
                wall.gotoAndStop(CellEditMenu.getWallIndex(model) + 1);
                walls[direction] = wall;
                if (direction == 1 || direction == 3) wall.rotation = 90;
                if (direction == 1) wall.x = SIZE;
                if (direction == 2) wall.y = SIZE;
                asset.addChild(wall);
            }
            else
            {
                wall.gotoAndStop(CellEditMenu.getWallIndex(model) + 1);
            }
        }
        
        private function removeWall(direction:int):void
        {
            var wall:Wall_asset = walls[direction] as Wall_asset;
            if (wall && wall.parent) {
                wall.parent.removeChild(wall);
                walls[direction] = null;
            }
            
        }
        
    }

}