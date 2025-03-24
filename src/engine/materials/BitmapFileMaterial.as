package engine.materials 
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author 
	 */
	public class BitmapFileMaterial extends BitmapMaterial
	{
		private var loader:Loader
		
		function BitmapFileMaterial(path:String)
		{
			loader = new Loader();
			loader.load(new URLRequest(path));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void 
		{
			
		}
		
		private function loadCompleteHandler(e:Event):void 
		{
			bitmap = e.target.content.bitmapData;
		}
	}
}