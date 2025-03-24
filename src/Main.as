package 
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.FPSMeter;
	import com.bit101.components.PushButton;
	import engine.materials.BitmapFileMaterial;
	import engine.materials.BitmapMaterial;
	import engine.objects.MD5Mesh;
	import engine.objects.Plane;
	import engine.Renderer;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import org.flashdevelop.utils.FlashConnect;
	import org.libspark.pv3d.decoders.TGADecoder;
	
	public class Main extends Sprite
	{
		private var console:TextField;		
		private var camera:Sprite;
		private var jointScreenVertices:Vector.<Number>;
		private var texturePath:String;
		private var mesh:MD5Mesh;
		private var modelFile:File;
		private var textureFile:File;
		private var loader:URLLoader;
		private var modelLoaded:Boolean;
		private var tgaDecoder:TGADecoder;
		private var modelFilter:FileFilter;
		private var textureFilter:FileFilter
		private var i:int;
		private var currentTex:int;
		private var camRot:Number;
		private var oldMousePos:Point;
		private var oldCameraRot:Point;
		private var RMBPressed:Boolean;
		private var openBtn:PushButton;
		private var fpsMeter:FPSMeter;	
		private var parentJoint:int;
		private var drawModelChk:CheckBox;
		private var drawSkeletonChk:CheckBox;
		private var renderer:Renderer;
		private var plane:Plane;
		
		public function Main()
		{			
			setupInterface();
			RMBPressed = false;
			modelLoaded = false;
			this.stage.nativeWindow
			camera = new Sprite();
			camera.rotationX = 90;
			camera.z = 150;
			camera.y = 50;			
			oldMousePos = new Point();
			oldCameraRot = new Point();
			plane = new Plane(100, 100, 0, new BitmapFileMaterial("D:/Pictures/metal_base_d.png"));
			
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			stage.addEventListener(MouseEvent.MOUSE_OUT, rmbUpHandler);
			stage.addEventListener(Event.RESIZE, resizeHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardPressHandler);
			
			modelFilter = new FileFilter("MD5Mesh Model (*.MD5Mesh)", "*.MD5Mesh");
			textureFilter = new FileFilter("TGA Images (*.tga)", "*.tga")
			modelFile = new File();
			textureFile = new File();
			
			renderer = new Renderer(camera, [plane], this.graphics);
			resizeHandler();
		}
		
		private function keyboardPressHandler(e:KeyboardEvent):void 
		{
			if (e.ctrlKey)
			{
				switch (e.keyCode)
				{
					case Keyboard.O: openModelHandler(e)
				}
			}
		}
		
		private function setupInterface():void
		{
			openBtn = new PushButton(stage, 0, 0, "Open MD5Mesh...", openModelHandler);
			fpsMeter = new FPSMeter(stage);
			//drawModelChk = new CheckBox(stage, 0, 0, "Draw model", render);
			//drawModelChk.selected = true;
			//drawSkeletonChk = new CheckBox(stage, 0, 0, "Draw skeleton", render);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.nativeWindow.height = 600;
			stage.nativeWindow.width = 800;
			stage.nativeWindow.minSize = new Point(800, 600)
			stage.frameRate = 60;
			stage.nativeWindow.title = "Model Viewer";
		}
		
		private function resizeHandler(e:Event = null):void 
		{
			x = stage.stageWidth >> 1;
			y = stage.stageHeight >> 1;
			
			fpsMeter.x = stage.stageWidth - fpsMeter.width;
			openBtn.x = openBtn.y = 4;
			//drawModelChk.y = openBtn.y + openBtn.height + 4;
			//drawSkeletonChk.y = drawModelChk.y + drawModelChk.height + 4;
		}
		
		private function openModelHandler(e:Event):void 
		{
			modelFile.browseForOpen("Select a MD5Mesh file", [modelFilter]);
			modelFile.addEventListener(Event.SELECT, onModelFileSelect);
		}
		
		private function onModelFileSelect(e:Event):void 
		{
			mesh = new MD5Mesh(modelFile.nativePath);
			mesh.addEventListener(Event.COMPLETE, loadCompleteHandler);
			modelFile.removeEventListener(Event.SELECT, onModelFileSelect);
			modelLoaded = false;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, render);
		}
		
		private function loadCompleteHandler(e:Event):void 
		{
			renderer.renderList = [mesh];
			mesh.removeEventListener(Event.COMPLETE, loadCompleteHandler);
			jointScreenVertices = new Vector.<Number>(mesh.jointsCount * 2, true);
			currentTex = 0
			textureLoad();
		}
		
		private function textureLoad():void
		{
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			texturePath = "E:/Program Files (x86)/1C/Activision/Quake4/q4base/" + mesh.shaders[currentTex] + "_d.tga";
			loader.load(new URLRequest(texturePath));
			loader.addEventListener(Event.COMPLETE, onTextureLoadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void
		{
			textureFile.browseForOpen("Select a texture for mesh " + mesh.shaders[currentTex], [textureFilter])
			textureFile.addEventListener(Event.SELECT, onTextureFileSelect);
			textureFile.addEventListener(Event.CANCEL, cancelLoadHandler);
		}
		
		private function cancelLoadHandler(e:Event):void 
		{
			currentTex++;
			if (currentTex == mesh.meshesCount)
			{			
				stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, rmbDownHandler);
				render();
				modelLoaded = true;	
			}
			else textureLoad()
		}
		
		private function rmbDownHandler(e:MouseEvent):void 
		{
			oldCameraRot = new Point(-camera.rotationX, -camera.rotationY);
			oldMousePos = new Point(stage.mouseX >> 1, stage.mouseY >> 1);
			
			RMBPressed = true;
			//stage.addEventListener(MouseEvent.MOUSE_MOVE, render);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, render);
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, rmbUpHandler);
			stage.addEventListener(Event.MOUSE_LEAVE, rmbUpHandler)
		}
		
		private function rmbUpHandler(e:Event):void 
		{
			RMBPressed = false;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, render);
			//stage.removeEventListener(Event.ENTER_FRAME, render);
		}
		
		private function onTextureFileSelect(e:Event):void 
		{
			textureFile.load()
			textureFile.removeEventListener(Event.SELECT, onTextureFileSelect);
			textureFile.addEventListener(Event.COMPLETE, onTextureLoadComplete);
		}
		
		private function onTextureLoadComplete(e:Event):void 
		{
			if (loader.bytesTotal) tgaDecoder = new TGADecoder(loader.data);
			else tgaDecoder = new TGADecoder(textureFile.data);			
			loader.removeEventListener(Event.COMPLETE, onTextureLoadComplete);
			mesh.meshes[currentTex].material =  new BitmapMaterial(tgaDecoder.bitmap);
			++currentTex
			if (currentTex == mesh.meshesCount)
			{				
				stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, rmbDownHandler)
				render();				
				modelLoaded = true;	
			}
			else textureLoad()
		}
		
		private function mouseWheelHandler(e:MouseEvent):void 
		{
			camera.z += e.delta;
			renderer.render()
		}
		
		private function render(e:Event = null):void
		{
			if (RMBPressed)
				camRot = oldCameraRot.y + ((stage.mouseX >> 1) - oldMousePos.x);
			
			camera.rotationY = -camRot
			renderer.render()
		}
	}	
}