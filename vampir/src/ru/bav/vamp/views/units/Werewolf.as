package ru.bav.vamp.views.units {
    import flash.display.*;
    import ru.bav.vamp.views.*;
    import ru.bav.vamp.views.units.*;
	
	/**
     * View of werewolf.
     * @author bav
     */
    public class Werewolf extends UnitViewBase {
        
        public function Werewolf() {
            drawUnit();
        }
        
        private function drawUnit():void{
            var g:Graphics = this.graphics;
            g.lineStyle(1);
            g.beginFill(0x000000);
            g.moveTo(-MapCeilView.CELL_SIZE / 3, -MapCeilView.CELL_SIZE / 6);
            g.lineTo(MapCeilView.CELL_SIZE / 3, 0);
            g.lineTo(-MapCeilView.CELL_SIZE / 3, MapCeilView.CELL_SIZE / 6);
            g.moveTo(-MapCeilView.CELL_SIZE / 3, -MapCeilView.CELL_SIZE / 6);
            g.endFill();
        }
        
    }

}