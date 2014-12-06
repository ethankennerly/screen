
/*
Flash CS4 Tutorials by Barbara Kaskosz.

www.flashandmath.com

Last modified: November 12, 2008. 

*/

/*
This class is a Flash CS4 - Flash Player 10 version of the class 
com.flashandmath.bitmaps.BitmapSphereBasic from our tutorial 
'Earth and Other Celestial Bodies in 3D in Flash CS3 and AS3',
http://www.flashandmath.com/advanced/planets/
This version differs a lot from the earlier version. 
The helper class BitmapTransformer is no longer needed. 
It is replaced by the new to FP10 AS3 method
'drawTriangles'. Moreover, all the matrix calculations
that were done directly in FP9, are now perfomed by the methods
of the new AS3 class 'Matrix3D'.

We discovered significant improvements in performance 
when using the new methods. At the frame rate of 12fps and 
the mesh ('nMesh' below) set to 50 by 50 (2601 vertices, 
5202 triangles), rendering in the old version is jerky and delayed,
while it is smooth is the new version. The main rendering function
takes on average 4 times faster in the new version. 
Total memory used dropped by about 35% in the new version
in comparison with the old version. There is also
a visible improvement in rendered bitmap quality when using 
the 'drawTriangle' method as opposed to using the BitmapTransformer.
(Regardless of the sphere size.)

('nMesh' below is set to 30 as 30 by 30 mesh is sufficient for a smooth 
looking sphere.)
*/

/* 
Here is an overview of the method that we use to create our textured sphere.
The 3D sphere will be represented by a mesh of adjacent 30*30=900 quadrangles
in 3D defined by 961 vertices. ('30' is the value of the variable 'nMesh' set
in the constructor.)
		  
The points (vectors) in 3D that made up our spherical mesh correspond to a division
of a 2*PI by PI planar rectangle into a 30 by 30 mesh of adjacent planar subrectangles.
The vertices of the division (organized in rows and columns) are mapped onto the points
on the sphere of radius 'rad' using the parametric equations of the sphere.
The mapping is done in the function 'setVertsVec'. The value of 'rad' is calculated
in the constructor based on the dimensions of the BitmapData object passed to
the constructor. 
		  
With each rotation, the function 'transformSphere' recalculates the coordinates
of the vertices of the 3D mesh of quadrangles, and then projects them onto the 2D
plane. We obtain a 2D mesh of quadrangles. Before applying the 'drawTriangles'
method that will paste our bitmap over the image of the sphere, we divide each
of the quadrangles into two triangles. For each such triangle, the original position
of its vertices within the 2*PI by PI rectangle is logged in as elements
of the uvtData Vector. For each triangle, the corresponding triangle within
our BitmapData will be mapped onto it by the 'drawTriangle' method. 
The 'drawTriangle' method locates the positon of the corresponding triangle
within the BitmapData based on the uvtData. 
		  
The 'drawTriangles' method is applied within the 'transformSphere' function
as well.
*/
		  


package com.flashandmath.cs4 {
	
	 import flash.display.*;
    
	 import flash.geom.*;
	 
	 public class BitmapSphereBasic extends Sprite {
		  
		private var bdPic:BitmapData;

		private var vertsVec:Array;

        private var picWidth:Number;
		
		private var picHeight:Number;
		
		private var spSphere:Sprite;

        private var spSphereImage:Sprite;

		private var rad:Number;
		
		private var nMesh:Number;
		
		private var tilesNum:Number;
		
		/*
		The constructor takes one parameter: a BitmapData object, 'b', corresponding
		to the picture to be pasted over a sphere. Typically, it will be
		a BitmapData object corresponding to an image imported to the Library
		in a fla file and linked to AS3 or an image loaded at runtime. 
		The radius of the sphere is calculated based on the dimensions of 'b'.
		'b'  should have dimension ratio 2 to 1 for best results.
		*/
		
		public function BitmapSphereBasic(b:BitmapData) {
			
		  //bdPic holds all the pixels information about the image
		  //that will be pasted over a sphere.
			
		  bdPic=b;
		  
		  //The width of the main image is set to the width of the BitmapData
		  //object passed to the constructor. Its height is set to the half
		  // of the width. If the image passed to the constructor is taller,
		  //the bottom will be cropped. If you change picHeight to bdPic.height,
		  //the image will be distorted rather than cropped.
			
		  picWidth=bdPic.width;
		  
		  picHeight=picWidth/2;
		  
		  //The width of the picture has to be equal to the circumference
		  //of the sphere. Thus, the radius, rad, is set accordingly.
		  //Choosing a different radius will distort the image.
		  
		  rad=Math.floor(picWidth/(Math.PI*2));
		  
		  /*
		  The Sprite spSphere is an abstract 3D construct.
		  spSphere is never added to the Display List. It
		  serves as a holder for 3D vertices on the sphere, 
		  coordinates of their 2D projections, and the current transformation matrix. 
		  After all the vertex calculations are perfomed and the coordinates
		  of all 2D points necessary for drawing an image of the sphere
		  are obtained, the actual image is drawn in the Sprite spSphereImage.
		  */
		   
		  spSphere=new Sprite();
		  
		  //After we evoke a 3D property like rotationX on spSphere,
		  //it becomes a 3D object from the AS3 point of view and it gains
		  //access to all the AS3 3D methods.
		  
		  spSphere.rotationX=0;
		  
		  spSphere.rotationY=0;
		  
		  spSphere.rotationZ=0;
		   
		  //spSphereImage is the Sprite in which the sphere will be drawn.

          spSphereImage=new Sprite();

          this.addChild(spSphereImage);
		  
		  /*
		  We set our mesh, 'nMesh', to 30. Hence, the number
		  of rectangles will be 900 and the number of triangles 1800.
		  The mesh values less than 20 produce a sphere
		  which is not smooth enough. Higher meshes slow
		  things down without much improvement in image quality.
		  */
		  
		  nMesh=30;
		  
		  tilesNum=nMesh*nMesh;
		      
		  /*
		  vertsVec is an array of arrays of instances of the Vector3D class.
		  Each Vector3D holds 3D coordinates of a vertex in our 3D mesh.
		  Each element of this array corresponds to a row of vertices in
		  our subdivision of 2*Pi by PI rectangle.
		  This way vertices are well organized and do not repeat.
		  */
		  
          vertsVec=[];
		  
		  //Defining initial coordinates of 3D vertices that made up our sphere.
		    
		  setVertsVec();
		  
		  //Calling a function that produces an initial view of the sphere.

          rotateSphere(0,0,0);
	
		}
		
		
	private function setVertsVec():void {
	
	      var i:int;
	
	      var j:int;
	
	      var istep:Number;
	
          var jstep:Number;
	
          istep=2*Math.PI/nMesh;
	
          jstep=Math.PI/nMesh;

	  for(i=0;i<=nMesh;i++){
		
		  vertsVec[i]=[];
		
		 for(j=0;j<=nMesh;j++){
			 
			 //We are setting 3D coordinates of our mesh vertices on the sphere 
			 //using parametric equation of the sphere of radius 'rad'.
			
			vertsVec[i][j]=new Vector3D(rad*Math.sin(istep*i)*Math.sin(jstep*j),-rad*Math.cos(jstep*j),-rad*Math.cos(istep*i)*Math.sin(jstep*j));
				
		 }
		
	  }
	
   }
   
   /*
   The function 'rotateSphere' is evoked when the user rotates the sphere with the mouse.
   Note that we are 'appending' rotations. That is, to already existing transformation
   of our sphere (defined by the current spSphere.transform.matrix3D) we are
   adding the rotations to be perfomed next. It produces rotations
   about the stationary x, y and z axes unlike 'prepending' rotations
   as in the function 'autoSpin' that follows. The actual transformation and drawing
   is perfomed by the 'transformSphere' function.
   */
   
  public function rotateSphere(rotx:Number,roty:Number,rotz:Number):void {
	  
	  var paramMat:Matrix3D;
	  
	  spSphere.transform.matrix3D.appendRotation(rotx,Vector3D.X_AXIS);
	
	  spSphere.transform.matrix3D.appendRotation(roty,Vector3D.Y_AXIS);
	
	  spSphere.transform.matrix3D.appendRotation(rotz,Vector3D.Z_AXIS);
	  
	  paramMat=spSphere.transform.matrix3D.clone();
	  
	  transformSphere(paramMat);
	
	  
	  
  }
  
  /*
  In 'autoSpin' we are 'prepending' a rotation about the vertical axes.
  That means the rotation will be performed before the current transformations
  of the sphere. It will produce the effect of the sphere revolving about
  its north pole - south pole axis rather than the stationary y axis.
  */
  
  public function autoSpin(roty:Number):void {
	   
	  var paramMat:Matrix3D;
	  
	  spSphere.transform.matrix3D.prependRotation(roty,Vector3D.Y_AXIS);
	  
	  paramMat=spSphere.transform.matrix3D.clone();
	  
	  transformSphere(paramMat);
	
   }
   
   /*
   The function 'transformSphere' calculates the 3D positions of all the vertices
   in the mesh, sorts the rectangles based on the z coordinate of their middles,
   and projects them onto 2D plane. We do not use any perspective projection
   as it doesn't do much for a sphere. Only after all those calculations are done,
   the vertices are organized into an array 'vertices' with their corresponding
   'indices' and 'uvtData'. In the array 'vertices' there are many repetitions
   but it is hard to organize them otherwise in a way suitable for the 'drawRectangles'
   method. We then apply 'drawRectangles' to our BitmapData, bdPic, 'vertices', 'indices'
   and 'uvtData'. See our tutorial 'The drawTriangle Method in Flash Player 10 for 2D
   Image Transformations', http://www.flashandmath.com/advanced/p10triangles/, for
   an explanation of the method.
   */


  private function transformSphere(mat:Matrix3D):void {
	
	var i:int;
	
	var j:int;
	
	var n:int;
	
	var distArray=[];
	
	var dispPoints=[];
	
	var newVertsVec=[];
		
	var zAverage:Number;

	var dist:Number;
	
	var curVertsNum:int=0;
		
    var vertices:Vector.<Number>=new Vector.<Number>();
		
    var indices:Vector.<int>=new Vector.<int>();
		
    var uvtData:Vector.<Number>=new Vector.<Number>();
	
	var curv0:Point=new Point();
	
	var curv1:Point=new Point();
	
	var curv2:Point=new Point();
	
	var curv3:Point=new Point();
	
	var curObjMat:Matrix3D=mat.clone();
	
	vertices=new Vector.<Number>();
		  
    indices=new Vector.<int>();
		  
	uvtData=new Vector.<Number>();
		
	spSphereImage.graphics.clear();
	
	for(i=0;i<=nMesh;i++){
		
		newVertsVec[i]=[]; 
		
		for(j=0;j<=nMesh;j++){
			
			newVertsVec[i][j]=curObjMat.deltaTransformVector(vertsVec[i][j]);
			
		}
			
	}
	
	
	for(i=0;i<nMesh;i++){
		
		for(j=0;j<nMesh;j++){
		
		zAverage=(newVertsVec[i][j].z+newVertsVec[i+1][j].z+newVertsVec[i][j+1].z+newVertsVec[i+1][j+1].z)/4;
		
		dist=zAverage;
		
		distArray.push([dist,i,j]);
		
		}
		
	}
	
	distArray.sort(byDist);

	for(i=0;i<=nMesh;i++){
		
		dispPoints[i]=[];
		
		for(j=0;j<=nMesh;j++){
		
		dispPoints[i][j]=new Point(newVertsVec[i][j].x,newVertsVec[i][j].y);
		
		}
	}
	
	for(n=0;n<tilesNum;n++){
		
		i=distArray[n][1]; 
		
		j=distArray[n][2];
		
		curv0=dispPoints[i][j].clone();
		
		curv1=dispPoints[i+1][j].clone();
		
		curv2=dispPoints[i+1][j+1].clone();
		
		curv3=dispPoints[i][j+1].clone();
		
		vertices.push(curv0.x,curv0.y,curv1.x,curv1.y,curv2.x,curv2.y,curv3.x,curv3.y);
		
		indices.push(curVertsNum,curVertsNum+1,curVertsNum+3,curVertsNum+1,curVertsNum+2,curVertsNum+3);
		
		uvtData.push(i/nMesh,j/nMesh,(i+1)/nMesh,j/nMesh,(i+1)/nMesh,(j+1)/nMesh,i/nMesh,(j+1)/nMesh);
		
		curVertsNum+=4;
		
	 }
	 
	spSphereImage.graphics.beginBitmapFill(bdPic);
		
	spSphereImage.graphics.drawTriangles(vertices,indices,uvtData);
		
	spSphereImage.graphics.endFill();
	 
  }

   
   private function byDist(v:Array,w:Array):Number {
	
	 if (v[0]>w[0]){
		
		return -1;
		
	  } else if (v[0]<w[0]){
		
		return 1;
	
	   } else {
		
		return 0;
	  }
	  
  }
  
   
  //The public method that should be called before an instance of BitmapSphere is removed.
	  
	  public function destroy():void {
		    
		  spSphereImage.graphics.clear();
		  
		  spSphereImage=null;
		  
		  spSphere=null;
	  
	  }
	  
	 	
		
	}
	
	
}