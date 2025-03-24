package engine.materials 
{
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author crash
	 */
	public class BitmapMaterial extends Material
	{
		public var bitmap:BitmapData;
		public var smooth:Boolean
		private const PIXELS_TO_COMPARE:int = 3;
		private var equals:Boolean;
		
		public function BitmapMaterial(bitmap:BitmapData = null) 
		{
			this.bitmap = bitmap || new BitmapData(32, 32, false, 0x666666);
			smooth = true;
		}
		
		public override function compare(toCompare:Material):Boolean
		{
			if (toCompare is BitmapMaterial)
			{
				if (compareBitmapData(toCompare as BitmapMaterial) && smooth == (toCompare as BitmapMaterial).smooth)
				{
					return true
				}
			}
			return false;
		}
		
		private function compareBitmapData(toCompare:BitmapMaterial):Boolean
		{
			var x:int, y:int;
			for (var i:int = 0; i < PIXELS_TO_COMPARE; i++)
			{
				x = Math.random() * bitmap.width;
				y = Math.random() * bitmap.height;
				if (bitmap.getPixel32(x, y) != toCompare.bitmap.getPixel32(x, y))
				{
					return false;
					break;
				}
			}
			return true;
		}
	}
}