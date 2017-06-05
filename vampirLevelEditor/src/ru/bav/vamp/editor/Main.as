package ru.bav.vamp.editor 
{
	import flash.display.Sprite;
	import flash.events.Event;
    import flash.display.StageScaleMode;
    import flash.display.StageAlign;
    import ru.bav.vamp.editor.controllers.MainController;
	
	/**
	 * ...
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
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP;
		}
		
	}
	
}