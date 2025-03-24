package engine.objects
{
	import engine.materials.BitmapMaterial;
	import engine.Quaternion;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	import org.flashdevelop.utils.FlashConnect;
	
	/**
	 * @author crash
	 */
	
	public class MD5Mesh extends MeshContainer
	{
		private var loader:URLLoader;
		private var dataArray:Array;
		private var meshData:String;
		private var quaternion:Quaternion;
		
		private var modelVersion:uint;		
		public var jointNames:Vector.<String>;
		
		//counts
		public var meshesCount:int;
		public var jointsCount:int;
		
		//parent index, x, y, z, orientx, orienty, orientz, w component
		public var joints:Vector.<Number>;
		
		public var jointsCoord:Vector.<Number>;
		
		//weight index, weights count
		private var meshVerts:Vector.<Vector.<Number>>;
		
		//joint index, bias, x, y, z
		private var meshWeights:Vector.<Vector.<Number>>;
		
		//textures path
		public var shaders:Vector.<String>;
		
		private var completeEvent:Event;
		
		//final values
		//public var vertices:Vector.<Vector.<Number>>;
		//public var indices:Vector.<Vector.<int>>;
		//public var uvts:Vector.<Vector.<Number>>;
		
		/**
		 * Load a MD5Model file
		 * @param	path Full path to the file
		 */
		public function MD5Mesh(path:String)
		{
			dataArray = new Array();
			quaternion = new Quaternion();
			transform.matrix3D = new Matrix3D();
			loader = new URLLoader(new URLRequest(path));
			loader.addEventListener(Event.COMPLETE, loadCompleteHandler);
			completeEvent = new Event(Event.COMPLETE);
		}
		
		private function loadCompleteHandler(e:Event):void
		{
			meshData = loader.data;
			loader.removeEventListener(Event.COMPLETE, loadCompleteHandler);			
			parseModel();
			var time:int = getTimer();
			prepareMeshes();
			//FlashConnect.atrace(getTimer() - time);
			_isLoaded = true;
			dispatchEvent(completeEvent);
		}
		
		/*private function checkValidity():Boolean
		{
			
		}*/
		
		private function prepareMeshes():void
		{
			var i:uint, j:uint, k:uint;
			var verticesCount:uint;
			var weightsCount:uint;
			var inputVec:Vector3D = new Vector3D();
			var outputVec:Vector3D;
			var inputQuat:Quaternion = new Quaternion();
			var x:Number, y:Number, z:Number;
			var bias:Number, quatParam:Number, vecParam:Number, coordParam:Number;
			
			for (i = 0; i < meshesCount; i++)
			{
				verticesCount = meshVerts[i].length / 2;
				for (j = 0; j < verticesCount; j++)
				{
					weightsCount = meshVerts[i][j * 2 + 1];
					for (k = 0; k < weightsCount; k++)
					{
						//extracting orients
						quatParam = meshWeights[i][meshVerts[i][j * 2] * 5 + (k * 5)] * 8;
						inputQuat.x = joints[quatParam + 4];
						inputQuat.y = joints[quatParam + 5];
						inputQuat.z = joints[quatParam + 6];
						inputQuat.w = joints[quatParam + 7];						
						
						//extracting position vec
						vecParam = meshVerts[i][j * 2] * 5 + (k * 5);
						inputVec.x = meshWeights[i][vecParam + 2];
						inputVec.y = meshWeights[i][vecParam + 3];
						inputVec.z = meshWeights[i][vecParam + 4];						
						
						outputVec = inputQuat.rotatePoint(inputVec);						
						
						//extracting joint pos
						coordParam = meshWeights[i][meshVerts[i][j * 2] * 5 + (k * 5)] * 8;
						x = joints[coordParam + 1];
						y = joints[coordParam + 2];
						z = joints[coordParam + 3];
						
						bias = meshWeights[i][meshVerts[i][j * 2] * 5 + (k * 5) + 1];
						
						//calculate final vertices
						meshes[i].vertices[j * 3] += (x + outputVec.x) * bias;
						meshes[i].vertices[j * 3 + 1] += (y + outputVec.y) * bias;
						meshes[i].vertices[j * 3 + 2] += (z + outputVec.z) * bias;						
					}
					
				}
			}
		}
		
		private function parseModel():void
		{
			var modelVersionPat:RegExp = /MD5Version (?P<version>\d+)/;
			var jointsCountPat:RegExp = /numJoints (?P<count>\d+)/;
			var meshesCountPat:RegExp = /numMeshes (?P<count>\d+)/;
			var jointPat:RegExp = /\"(?P<name>\w+)\"	(?P<parent>\-*\d+) \( (?P<posX>[\d|\.\-]+) (?P<posY>[\d|\.\-]+) (?P<posZ>[\d|\.\-]+) \) \( (?P<orientX>[\d|\.\-]+) (?P<orientY>[\d|\.\-]+) (?P<orientZ>[\d|\.\-]+) \)/;
			var shaderPathPat:RegExp = /shader \"(?P<path>(\w|\/)*)\"/;
			var numVertsPat:RegExp = /numverts (?P<count>\d+)/;
			var vertexPat:RegExp = /vert \d+ \( (?P<U>[\d|\.\-]+) (?P<V>[\d|\.\-]+) \) (?P<startWeight>\d+) (?P<weightsCount>\d+)/;
			var numTrisPat:RegExp = /numtris (?P<count>\d+)/;
			var trianglePat:RegExp = /tri \d+ (?P<index1>\d+) (?P<index2>\d+) (?P<index3>\d+)/
			var numWeightsPat:RegExp = /numweights (?P<count>\d+)/;
			var weightPat:RegExp = /weight \d+ (?P<jointIndex>\d+) (?P<bias>[\d|\.]+) \( (?P<x>[\-|\d|\.]+) (?P<y>[\-|\d|\.]+) (?P<z>[\-|\d|\.]+) \)/;
			
			var lines:Array = meshData.split("\n");
			var currentLine:String;
			var meshesParsed:uint = 0;
			//counters...
			var i:uint, j:uint, k:uint, l:uint;
			
			while (lines.length)
			{
				currentLine = lines.shift();
				
				//md5mesh version, should be 10
				if (modelVersionPat.test(currentLine))
				{
					dataArray = modelVersionPat.exec(currentLine)
					if (dataArray.version == 10) modelVersion = 10;
					else
					{
						throw new Error("Bad model version");
						break;
					}
				}
				
				//joints count
				else if (jointsCountPat.test(currentLine))
				{
					dataArray = jointsCountPat.exec(currentLine);
					jointsCount = dataArray.count;
					joints = new Vector.<Number>(jointsCount << 3, true);
					jointNames = new Vector.<String>(jointsCount, true);
					jointsCoord = new Vector.<Number>(jointsCount * 3, true);
				}
				
				//meshes count
				else if (meshesCountPat.test(currentLine))
				{
					dataArray = meshesCountPat.exec(currentLine);
					meshesCount = dataArray.count;
					meshVerts = new Vector.<Vector.<Number>>(meshesCount, true);
					meshWeights = new Vector.<Vector.<Number>>(meshesCount, true);
					shaders = new Vector.<String>(meshesCount, true);
					//vertices = new Vector.<Vector.<Number>>(meshesCount, true);
					//uvts = new Vector.<Vector.<Number>>(meshesCount, true);
					//indices = new Vector.<Vector.<int>>(meshesCount, true);
					meshes = new Vector.<Mesh>(meshesCount, true);
					
				}				
				
				//joints
				else if (new RegExp("joints \\{").test(currentLine))
				{	
					i = 0;
					j = 0;
					k = 0;
					while (!(new RegExp("\\}").test(currentLine)))
					{
						currentLine = lines.shift();
						if (jointPat.test(currentLine))
						{
							dataArray = jointPat.exec(currentLine);
							jointNames[i++] = dataArray.name;
							joints[j++] = dataArray.parent;
							joints[j++] = jointsCoord[k++] = dataArray.posX;
							joints[j++] = jointsCoord[k++] = dataArray.posY;
							joints[j++] = jointsCoord[k++] = dataArray.posZ;
							joints[j++] = quaternion.x = dataArray.orientX;
							joints[j++] = quaternion.y = dataArray.orientY;
							joints[j++] = quaternion.z = dataArray.orientZ;
							quaternion.computeW()
							joints[j++] = quaternion.w;
						}
					}
					currentLine = lines.shift();
				}
				
				//mesh
				if (new RegExp("mesh \\{").test(currentLine))
				{	
					i = 0;
					j = 0;
					k = 0;
					l = 0;
					meshes[meshesParsed] = new Mesh();
					while (!(new RegExp("\\}").test(currentLine)))
					{
						currentLine = lines.shift();
						
						//shader
						if (shaderPathPat.test(currentLine))
						{
							dataArray = shaderPathPat.exec(currentLine);
							shaders[meshesParsed] = dataArray.path;
						}
						
						//vertices count
						else if (numVertsPat.test(currentLine))
						{
							dataArray = numVertsPat.exec(currentLine);
							meshVerts[meshesParsed] = new Vector.<Number>(dataArray.count << 1, true);
							meshes[meshesParsed].vertices = new Vector.<Number>(dataArray.count * 3, true);
							meshes[meshesParsed].uvts = new Vector.<Number>(dataArray.count * 3, true);
						}
						
						//vertex
						else if (vertexPat.test(currentLine))
						{
							dataArray = vertexPat.exec(currentLine);
							meshes[meshesParsed].uvts[i++] = dataArray.U;
							meshes[meshesParsed].uvts[i++] = dataArray.V;							
							meshes[meshesParsed].uvts[i++] = 0;
							
							meshVerts[meshesParsed][j++] = dataArray.startWeight;
							meshVerts[meshesParsed][j++] = dataArray.weightsCount;
						}
						
						//triangles count
						else if (numTrisPat.test(currentLine))
						{
							dataArray = numTrisPat.exec(currentLine);
							meshes[meshesParsed].indices = new Vector.<int>(dataArray.count * 3, true)
						}
						
						//trianle (face)
						else if (trianglePat.test(currentLine))
						{
							dataArray = trianglePat.exec(currentLine);
							meshes[meshesParsed].indices[k++] = dataArray.index1;
							meshes[meshesParsed].indices[k++] = dataArray.index2;
							meshes[meshesParsed].indices[k++] = dataArray.index3;
						}
						
						//weights count
						else if (numWeightsPat.test(currentLine))
						{
							dataArray = numWeightsPat.exec(currentLine);
							meshWeights[meshesParsed] = new Vector.<Number>(dataArray.count * 5, true);
						}
						
						//weight
						else if (weightPat.test(currentLine))
						{
							dataArray = weightPat.exec(currentLine);							
							meshWeights[meshesParsed][l++] = dataArray.jointIndex;
							meshWeights[meshesParsed][l++] = dataArray.bias;
							meshWeights[meshesParsed][l++] = dataArray.x;
							meshWeights[meshesParsed][l++] = dataArray.y;
							meshWeights[meshesParsed][l++] = dataArray.z;
						}
					}
					++meshesParsed;
				}
			}
			
			lines = null;
			dataArray = null;
		}
	}
}