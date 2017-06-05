package ru.bav.vamp.views 
{
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.utils.Dictionary;
    import flash.utils.getDefinitionByName;
	/**
     * Менеджер картинок.
     * @author bav
     */
    public class ImageFactory 
    {
        [Embed(source = '../../../../../lib/images/ground_01.jpg')] public static var ground_01:Class;
        
        private static var _instances:Dictionary = new Dictionary();
        
        public function ImageFactory() 
        {
            
        }
        
        public static function getInstance(className:Class):BitmapData {
            if (_instances[className]) {
                return _instances[className] as BitmapData;
            }
            else {
                var data:Bitmap = new className() as Bitmap;
                _instances[className] = data.bitmapData;
                return data.bitmapData;
            }
            
        }
        
    }

}