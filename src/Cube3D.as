package    
{     
    import flash.display.*;     
    import flash.events.*;     
    import flash.geom.*;   public class Cube3D extends Sprite    
    {     
        private var matrix3D:Matrix3D;     
        private var vertices:Vector.<Number>;     
        private var projectedVertices:Vector.<Number>;     
        private var UVData:Vector.<Number>;     
        private var indices:Vector.<int>;     
        private var cube:Sprite;
		private var projMatrix:Matrix3D;
		private var perspProj:PerspectiveProjection;
		
		public function Cube3D()    
        {     
            matrix3D = new Matrix3D();
			perspProj = new PerspectiveProjection()
			perspProj.fieldOfView = 45;
			projMatrix = perspProj.toMatrix3D();
            vertices = Vector.<Number>([50,-50,50,     
                                         50,-50,-50,     
                                        -50,-50,-50,     
                                        -50,-50,50,     
                                        50,50,50,     
                                        50,50,-50,     
                                        -50,50,-50,     
                                        -50,50,50     
                                        ]);     
            projectedVertices = new Vector.<Number>;     
            UVData = new Vector.<Number>;     
            indices = Vector.<int>([3,1,0, 3,2,1, 5,7,4, 5,6,7, 1,4,0, 1,5,4, 2,5,1, 2,6,5, 3,6,2, 3,7,6, 7,0,4, 7,3,0]);            cube = new Sprite();    
            addChild(cube);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);    
        }
		
        private function onEnterFrame(e:Event):void    
        {     
            cube.x = cube.y = 200;
			matrix3D.appendRotation(1, Vector3D.X_AXIS);    
            matrix3D.appendRotation(1, Vector3D.Y_AXIS);     
            matrix3D.appendRotation(1, Vector3D.Z_AXIS);
			//matrix3D.appendTranslation(0, 0, 100)
			//matrix3D.append(projMatrix);
			Utils3D.projectVectors(matrix3D, vertices, projectedVertices, UVData);
			cube.graphics.clear();
            cube.graphics.beginFill(0x0066FF);
            cube.graphics.lineStyle(1,0x0000FF);     
            cube.graphics.drawTriangles(projectedVertices, indices);     
            cube.graphics.endFill();     
        }     
    }     
}