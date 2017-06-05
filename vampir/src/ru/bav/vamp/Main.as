package ru.bav.vamp
{
	import flash.display.Sprite;
	import flash.events.Event;
    import ru.bav.vamp.controllers.MainController;
	
	/**
	 * Main game class.
	 * @author bav
	 */
	public class Main extends Sprite 
	{
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			new MainController(this);
		}
		
	}
	
}