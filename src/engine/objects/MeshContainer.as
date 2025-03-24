package engine.objects 
{
	/**
	 * ...
	 * @author 
	 */
	public class MeshContainer extends Object3D
	{
		public var meshes:Vector.<Mesh>;
		protected var _isLoaded:Boolean;
		
		public function MeshContainer() { }
		
		///Indicates whether MeshContainer is fully loaded
		public function get isLoaded():Boolean { return _isLoaded; }
		
	}

}