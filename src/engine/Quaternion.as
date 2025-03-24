package engine
{
	import flash.geom.Vector3D;
	import org.flashdevelop.utils.FlashConnect;

	public class Quaternion extends Vector3D
	{		
		function Quaternion(x:Number = 0, y:Number = 0, z:Number = 0, w:Number = 0)
		{
			super(x, y, z, w);
		}
		
		public function computeW():void
		{
			var t:Number = 1 - (x * x + y * y + z * z);
			if (t <= 0) w = 0
			else w = -Math.sqrt(t);
		}
		
		public override function normalize():Number
		{
			var magnitude:Number = Math.sqrt(x * x + y * y + z * z + w * w);
			
			if (magnitude > 0)
			{
				x /= magnitude;
				y /= magnitude;
				z /= magnitude;
				w /= magnitude;
			}
			//нужно возвращать что-то, иначе override не будет работать
			//оригинальный normalize возвращает длину вектора
			//return lengthSquared;
			return NaN;
		}
		
		/**
		 * Multiplies this quaternion by another
		 * @param	a Second quaternion
		 */
		public function multiply(a:Quaternion):void
		{
			var tmpW:Number = w*a.w - x*a.x - y*a.y - z*a.z;
			var tmpX:Number = w*a.x + x*a.w + y*a.z - z*a.y;
			var tmpY:Number = w*a.y - x*a.z + y*a.w + z*a.x; 
			var tmpZ:Number = w*a.z + x*a.y - y*a.x + z*a.w; 
			w = tmpW;
			x = tmpX;
			y = tmpY;
			z = tmpZ;
		}
		
		///parameter also can be a Quaternion
		///w component will be ignored anyway
		public function multiplyByVector(a:Vector3D):void
		{
			var tmpW:Number = -(x * a.x) - (y * a.y) - (z * a.z);			
			var tmpX:Number = (w * a.x) + (y * a.z) - (z * a.y);
			var tmpY:Number = (w * a.y) + (z * a.x) - (x * a.z);
			var tmpZ:Number = (w * a.z) + (x * a.y) - (y * a.x);
			w = tmpW;
			x = tmpX;
			y = tmpY;
			z = tmpZ;
		}
		
		public function rotatePoint(a:Vector3D):Vector3D
		{
			var inv:Quaternion = new Quaternion(-x, -y, -z, w);
			var tmp:Quaternion = new Quaternion(x, y, z, w);			
			inv.normalize();
			tmp.multiplyByVector(a);
			tmp.multiply(inv);
			return new Vector3D(tmp.x, tmp.y, tmp.z);
		}
		
		/**
		 * Returns a new Quaternion object that is a clone of the original instance
		 * @return New Quaternion that is identical to the original
		 */
		/*public override function clone():Quaternion
		{
			return new Quaternion(x, y, z, w);
		}*/
		
		public override function toString():String
		{
			return "Quaternion(" + x + ", " + y + ", " + z + ", " + w + ")";
		}
	}

}