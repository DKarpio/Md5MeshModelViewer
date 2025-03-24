package engine.objects
{	
	import engine.materials.Material;
	import flash.geom.Vector3D;
	
	public class Face
	{
		///6 numbers - x1, y1, x2, y2, x3, y3
		//public var screenVertices:Vector.<Number>;
		///////
		public var x1:Number;
		public var y1:Number;
		public var x2:Number;
		public var y2:Number;
		public var x3:Number;
		public var y3:Number;
		///9 numbers - u1, v1, t1, u2, v2, t2...
		//public var uvts:Vector.<Number>;
		///////
		public var u1:Number;
		public var v1:Number;
		public var t1:Number;
		public var u2:Number;
		public var v2:Number;
		public var t2:Number;
		public var u3:Number;
		public var v3:Number;
		public var t3:Number;
		public var material:Material;
		public var averageT:Number;
		public var vertex1:Vector3D;
		public var vertex2:Vector3D;
		public var vertex3:Vector3D;
		public var colorFactor:Number;
		//public var indices:Vector.<int>;
		
		function Face() { }
		
		public function calculateAvgT():void
		{
			averageT = (t1 + t2 + t3) * 0.333333;
			//averageT = Math.min(uvts[2], uvts[5], uvts[8])
		}
	}
}