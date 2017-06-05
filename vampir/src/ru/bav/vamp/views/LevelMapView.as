package ru.bav.vamp.views {
	import flash.display.Sprite;
    import ru.bav.vamp.models.MapCellModel;
	
	/**
     * Container for MapCeilView objects.
     * @author bav
     */
    public class LevelMapView extends Sprite {
        // Array of arrays of ceils
        private var _ceils:Array /* of MapCeilView */ = [];
        
        public function LevelMapView() {
            
        }
        
        /**
         * Initialization of level by ceils data.
         * @param	ceils   Array of arrays of MapCellModel objects
         */
        public function initLevelMap(ceils:Array):void {
            clear();
            for (var i:int = 0; i < ceils.length; i++) {
                _ceils[i] = [];
                var columnCount:int = (ceils[i] as Array).length;
                for (var j:int = 0; j < columnCount; j++) {
                    if (ceils[i][j]) {
                        var ceilInfo:MapCellModel = ceils[i][j] as MapCellModel;
                        var ceil:MapCeilView = new MapCeilView(ceilInfo);
                        ceil.y = i * MapCeilView.CELL_SIZE;
                        ceil.x = j * MapCeilView.CELL_SIZE;
                        _ceils[i][j] = ceil;
                        addChild(ceil);
                    }
                }
            }
        }
        
        
        public function clear():void {
            while (_ceils.length) {
                var row:Array = _ceils.pop() as Array;
                while (row.length) {
                    var ceil:MapCeilView = row.pop() as MapCeilView;
                    //ceil.destroy();
                    if (ceil)
                        removeChild(ceil);
                }
            }
        }
        
    }

}