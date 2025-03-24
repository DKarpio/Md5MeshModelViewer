package  
{
	import engine.materials.BitmapFileMaterial;
	import engine.materials.BitmapMaterial;
	import engine.objects.MD5Mesh;
	import engine.objects.Plane;
	import engine.Renderer;
	import flash.desktop.NativeApplication;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import org.flashdevelop.utils.FlashConnect;
	
	/**
	 * ...
	 * @author crash
	 */
	public class test extends Sprite
	{
		private var camera:Sprite;
		private var plane:Plane
		private var renderer:Renderer;
		private var loader:Loader
		private var plane2:Plane;
		private var md5:MD5Mesh;
		
		public function test() 
		{
			x = stage.stageWidth / 2;
			y = stage.stageHeight / 2;
			camera = new Sprite();
			plane = new Plane(50, 50, 0, new BitmapFileMaterial("D:/Pictures/metal_base_d.png"));
			plane2 = new Plane(20, 20, 0, new BitmapFileMaterial("D:/Pictures/avatar.jpg"));
			plane.z = -10;
			//plane2.z = 10;
			//camera.rotationX = 90;
			//camera.y = 40;
			camera.z = 100
			
			stage.addEventListener(Event.ENTER_FRAME, render);
			renderer = new Renderer(camera, [plane, plane2], this.graphics);
		}
		
		private function render(e:Event):void 
		{
			//plane2.rotationZ--
			camera.rotationY = stage.mouseX
			renderer.render();
		}		
	}
}