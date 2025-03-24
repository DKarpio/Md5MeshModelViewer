package engine.objects
{
	import engine.materials.Material;
	import flash.display.Sprite;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import org.flashdevelop.utils.FlashConnect;
	
	public class Plane extends Mesh
	{		
		function Plane(width:Number, height:Number, z:Number, material:Material)
		{
			super();
			var halfWidth:Number = width >> 1;
			var halfHeight:Number = height >> 1;
			this.material = material;
			//facesCount = 2;
			twoSided = true;
			
			var m:Matrix3D = new Matrix3D()
			m.appendRotation(30, Vector3D.Z_AXIS);
			
			vertices.push( -halfWidth, -halfHeight, z);
			vertices.push( halfWidth, -halfHeight, z);
			vertices.push( -halfWidth, halfHeight, z);
			vertices.push( halfWidth, halfHeight, z);
			m.transformVectors(vertices, vertices);
			
			indices.push(0, 1, 2);
			indices.push(1, 3, 2);
			
			uvts.push(0, 0, 1);
			uvts.push(1, 0, 1);
			uvts.push(0, 1, 1);
			uvts.push(1, 1, 1);
			
			indices.fixed = true;
			uvts.fixed = true;
		}		
	}
}