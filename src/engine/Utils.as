package engine
{
	/**
	 * ...
	 * @author crash
	 */
	public class Utils
	{	
		private static var i:int;
		
		/**
		 * Concatinates two Number vectors
		 * @param	source Vector where new elements will be added
		 * @param	another Vector to concat
		 */
		public static function concatVectors(source:Vector.<Number>, another:Vector.<Number>):void
		{
			var vecLen:int = another.length;
			var j:int = source.length
			for (i = 0; i < vecLen; i++, j++)
				source[j] = another[i]
		}
		
		/**
		 * Return a vector filled by integers
		 * @param	len Desired length of vector
		 * @return Vector of integers
		 */
		public static function fillVector(len:int):Vector.<int>
		{
			var vec:Vector.<int> = new Vector.<int>(len, true);
			for (i = 0; i < len; i++)
				vec[i] = i;
			return vec;
		}
	}

}