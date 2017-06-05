package ru.bav.vamp.views.items {
	import flash.display.DisplayObject;
    import flash.display.Graphics;
	import flash.display.Sprite;
	import ru.bav.vamp.models.consts.BulletType;
	
	/**
     * Bullet view.
     * @author bav
     */
    public class Bullet extends Sprite {
		
		private var _module:DisplayObject;
        
        public function Bullet(type:int) {
            drawBullet(type);
        }
        
        public function setCoordinates(_x:Number, _y:Number):void {
            this.x = _x;
            this.y = _y;
        }
        
        private function drawBullet(type:int):void {
            if (type == BulletType.BULLET)
				_module = new Bullet_asset();
			else if (type == BulletType.DOUGHNUT)
				_module = new Doughnut_asset();
			else if (type == BulletType.STAKE)
				_module = new Stake_asset();
				
			addChild(_module);
			
			/*var g:Graphics = this.graphics;
			g.lineStyle(1);
            g.beginFill(getBulletColor(type));
            g.drawCircle(0, 0, 2);
            g.endFill();*/
        }
		
		private function getBulletColor(type:int):uint
		{
			// Инициализируем цветом обычной пули
			var color:uint = 0x000000;
			if (type == BulletType.STAKE) color = 0xFF0000;
			else if (type == BulletType.DOUGHNUT) color = 0xFFFF00;
			return color;
		}
        
    }

}