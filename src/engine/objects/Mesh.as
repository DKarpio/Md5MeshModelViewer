package engine.objects
{
	import engine.materials.Material;
	import flash.display.Sprite;
	import flash.geom.Matrix3D;
	/**
	 * ...
	 * @author Crash
	 */
	public class Mesh extends Object3D
	{
		public var vertices:Vector.<Number>;
		public var screenVertices:Vector.<Number>;
		public var uvts:Vector.<Number>;
		public var indices:Vector.<int>;
		public var material:Material;
		public var twoSided:Boolean;
		private var _visible:Boolean;
		
		public function Mesh() 
		{
			transform.matrix3D = new Matrix3D();
			screenVertices = new Vector.<Number>();
			indices = new Vector.<int>();
			vertices = new Vector.<Number>();
			uvts = new Vector.<Number>();
			twoSided = false;
			_visible = true;
		}
		
		public override function get visible():Boolean { return _visible; }
		
		public override function set visible(value:Boolean):void 
		{
			_visible = value;
		}
	}
}