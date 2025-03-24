package engine
{
	import engine.materials.Material;
	import engine.objects.MeshContainer;
	import engine.objects.Object3D;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.GraphicsBitmapFill;
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsTrianglePath;
	import flash.display.IGraphicsData;
	import flash.display.Sprite;
	import flash.geom.Matrix3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Utils3D;
	import engine.materials.BitmapMaterial;
	import engine.objects.Face;
	import engine.objects.Mesh;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	import org.flashdevelop.utils.FlashConnect;
	
	public class Renderer
	{
		public var camera:Sprite;
		private var projMatrix:Matrix3D;
		private var textures:Vector.<BitmapData>;
		///List of of objects to render
		public var renderList:Array;
		//public var renderList:Vector.<IRenderable>;
		private var perspectiveProjection:PerspectiveProjection;
		public var renderTo:Graphics
		private var currentFace:Face;
		private var currentObject:Object3D;
		private var currentMesh:Mesh;
		private var transformMatrix:Matrix3D;
		
		private var faces:Array;
		//private var faces:Vector.<Face>;
		private var faceCount:int;
		private var currentMaterial:Material;
		private var indicesLength:int;
		private var renderListLength:int;
		private var facesLength:int;
		
		private var trianglePath:GraphicsTrianglePath;
		private var graphicsData:Vector.<IGraphicsData>;
		private var bitmapFill:GraphicsBitmapFill;
		private var endFill:GraphicsEndFill;		
		
		private var i:int, j:int, k:int;
		private var index1:int;
		private var index2:int;
		private var index3:int;
		private var screenX1:Number;
		private var screenY1:Number;
		private var screenX2:Number;
		private var screenY2:Number;
		private var screenX3:Number;
		private var screenY3:Number;
		
		//clipping test
		private var screenVerticesCull:Vector.<int>;
		private var minX:Number = -1000;
		private var maxX:Number = 1000;
		private var minY:Number = -1000;
		private var maxY:Number = 1000;
		private var cullCount:int;
		
		function Renderer(camera:Sprite, renderList:Array, renderTo:Graphics)
		{
			faces = new Array();
			//faces = new Vector.<Face>();
			this.camera = camera;
			perspectiveProjection = new PerspectiveProjection();
			perspectiveProjection.fieldOfView = 45;
			projMatrix = perspectiveProjection.toMatrix3D();
			this.renderTo = renderTo;
			
			screenVerticesCull = new Vector.<int>();			
			graphicsData = new Vector.<IGraphicsData>();
			trianglePath = new GraphicsTrianglePath(new Vector.<Number>(), null, new Vector.<Number>());
			endFill = new GraphicsEndFill();
			
			this.renderList = renderList
		}
		
		private function sortT(a:Face, b:Face):Number
		{
			if (a.averageT < b.averageT) return -1;
			else if (a.averageT > b.averageT) return 1;
			else return 0;
		}
		
		private function project(object:Object3D, faces:Array):void
		{
			if (object is MeshContainer)
			{
				//if ((object as MeshContainer).isLoaded)
				//{
					for each (currentMesh in (object as MeshContainer).meshes)
					{
						project(currentMesh, faces)
					}
				//}
			}
			else if (object is Mesh)
			{
				currentMesh = object as Mesh;
				if (!currentMesh.visible || !currentMesh.material || !currentMesh.vertices || !currentMesh.screenVertices || !currentMesh.uvts) return
				transformMatrix = currentMesh.transform.matrix3D.clone();
				transformMatrix.append(camera.transform.matrix3D);
				transformMatrix.append(projMatrix);
				
				Utils3D.projectVectors(transformMatrix, currentMesh.vertices, currentMesh.screenVertices, currentMesh.uvts);
				
				faceCount = currentMesh.indices.length / 3;
				for (j = 0; j < faceCount; j++)
				{
					index1 = currentMesh.indices[int(j * 3)];
					index2 = currentMesh.indices[int(j * 3 + 1)];
					index3 = currentMesh.indices[int(j * 3 + 2)];
					
					screenX1 = currentMesh.screenVertices[int(index1 * 2)];
					screenY1 = currentMesh.screenVertices[int(index1 * 2 + 1)];
					screenX2 = currentMesh.screenVertices[int(index2 * 2)];
					screenY2 = currentMesh.screenVertices[int(index2 * 2 + 1)];
					screenX3 = currentMesh.screenVertices[int(index3 * 2)];
					screenY3 = currentMesh.screenVertices[int(index3 * 2 + 1)];
					
					//triangle culling
					if (currentMesh.twoSided || !isBackFace())
					{
						//cullCount = screenVerticesCull[index1] + screenVerticesCull[index2] + screenVerticesCull[index3];
						//if (!(cullCount >> 8) && (cullCount >> 6 & 3) < 3 && (cullCount >> 4 & 3) < 3 && (cullCount >> 2 & 3) < 3 && (cullCount & 3) < 3)
						//{
							var face:Face = new Face()
							face.u1 = currentMesh.uvts[int(index1 * 3)]; face.v1 = currentMesh.uvts[int(index1 * 3 + 1)]; face.t1 = currentMesh.uvts[int(index1 * 3 + 2)];
							face.u2 = currentMesh.uvts[int(index2 * 3)]; face.v2 = currentMesh.uvts[int(index2 * 3 + 1)]; face.t2 = currentMesh.uvts[int(index2 * 3 + 2)];
							face.u3 = currentMesh.uvts[int(index3 * 3)]; face.v3 = currentMesh.uvts[int(index3 * 3 + 1)]; face.t3 = currentMesh.uvts[int(index3 * 3 + 2)];
							
							face.x1 = screenX1; face.y1 = screenY1;
							face.x2 = screenX2; face.y2 = screenY2;
							face.x3 = screenX3; face.y3 = screenY3;
							
							//face.vertex1 = new Vector3D(currentMesh.vertices[int(index1 * 3)], currentMesh.vertices[int(index1 * 3 + 1)], currentMesh.vertices[int(index1 * 3 + 2)]);
							//face.vertex2 = new Vector3D(currentMesh.vertices[int(index2 * 3)], currentMesh.vertices[int(index2 * 3 + 1)], currentMesh.vertices[int(index2 * 3 + 2)]);
							//face.vertex3 = new Vector3D(currentMesh.vertices[int(index3 * 3)], currentMesh.vertices[int(index3 * 3 + 1)], currentMesh.vertices[int(index3 * 3 + 2)]);
							
							face.material = currentMesh.material;
							face.calculateAvgT();
							faces.push(face);
							//faces[faces.length] = face;
						//}			
					}
				}
			}
		}
		
		private function isBackFace():Boolean 
		{
			if (screenX1 * (screenY3 - screenY2) + screenX2 * (screenY1 - screenY3) + screenX3 * (screenY2 - screenY1) > 0)
				return true;
			else
				return false;
		}
		
		private function isOffScreen():Boolean
		{
			if ((screenX1 < -200 || screenX1 > 200) && (screenY1 < -200 || screenY1 > 200) ||
				(screenX2 < -200 || screenX2 > 200) && (screenY2 < -200 || screenY2 > 200) ||
				(screenX3 < -200 || screenX3 > 200) && (screenY3 < -200 || screenY3 > 200))
				return true
			else return false;
		}
		
		/**
		 * Render a snapshot of the 3D scene
		 */
		public function render():void
		{
			var time:int = getTimer();
			graphicsData.fixed = false;
			
			renderTo.clear()
			graphicsData.length = 0;
			faces.length = 0;
			trianglePath.uvtData.fixed = false;
			trianglePath.vertices.fixed = false;
			trianglePath.uvtData.length = 0;
			trianglePath.vertices.length = 0;			
			
			for each (currentObject in renderList)
			{
				project(currentObject, faces);
			}
			
			if (faces.length == 0) return;
			
			faces.sortOn("averageT", Array.NUMERIC)
			//faces.sort(sortT)
			
			currentMaterial = faces[0].material;
			if (!(currentMaterial as BitmapMaterial).bitmap) return
			
			bitmapFill = new GraphicsBitmapFill((currentMaterial as BitmapMaterial).bitmap, null, false, (currentMaterial as BitmapMaterial).smooth);
			graphicsData.push(bitmapFill)
			
			i = 0; j = 0;
			for each (currentFace in faces)
			{
				if (currentMaterial.compare(currentFace.material))
				{
					trianglePath.vertices[i++] = currentFace.x1;
					trianglePath.vertices[i++] = currentFace.y1;
					trianglePath.vertices[i++] = currentFace.x2;
					trianglePath.vertices[i++] = currentFace.y2;
					trianglePath.vertices[i++] = currentFace.x3;
					trianglePath.vertices[i++] = currentFace.y3;
					
					trianglePath.uvtData[j++] = currentFace.u1;
					trianglePath.uvtData[j++] = currentFace.v1;
					trianglePath.uvtData[j++] = currentFace.t1;
					trianglePath.uvtData[j++] = currentFace.u2;
					trianglePath.uvtData[j++] = currentFace.v2;
					trianglePath.uvtData[j++] = currentFace.t2;
					trianglePath.uvtData[j++] = currentFace.u3;
					trianglePath.uvtData[j++] = currentFace.v3;
					trianglePath.uvtData[j++] = currentFace.t3;
				}
				else
				{	
					i = 6; j = 9;
					currentMaterial = currentFace.material;
					bitmapFill = new GraphicsBitmapFill((currentMaterial as BitmapMaterial).bitmap, null, false, (currentMaterial as BitmapMaterial).smooth);
					trianglePath.uvtData.fixed = true;
					trianglePath.vertices.fixed = true;
					graphicsData.push(trianglePath, endFill, bitmapFill);
					trianglePath = new GraphicsTrianglePath(new <Number>[currentFace.x1, currentFace.y1, currentFace.x2, currentFace.y2, currentFace.x3, currentFace.y3], null, new <Number>[currentFace.u1, currentFace.v1, currentFace.t1,
						currentFace.u2, currentFace.v2, currentFace.t2,
						currentFace.u3, currentFace.v3, currentFace.t3]);
				}
			}
			graphicsData.push(trianglePath, endFill);
			graphicsData.fixed = true;
			renderTo.drawGraphicsData(graphicsData);
			//FlashConnect.atrace(getTimer() - time);
		}
	}
}