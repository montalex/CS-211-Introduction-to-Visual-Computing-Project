/*
* InteractiveProjection.pde
* Author : Alexis Montavon, Boris Flückiger and Dorian Laforest
* Group BE
*/

final static float MIN_SCALING_VALUE = 0.5;
final static float MAX_SCALING_VALUE = 5; 
float scaleValue = 1;
float scalingFactor = 0.1;

float xRotationValue = 0;
float xRotationFactor = 0.01;

float yRotationValue = 0;
float yRotationFactor = 0.01;

boolean rotateXUp = false;
boolean rotateXDown = false;

boolean rotateYUp = false;
boolean rotateYDown = false;

/*
* Method settings
* Sets up the window size to 1000x1000 and the rendering mode to P2D
*/
void settings() {
  size(1000, 1000, P2D);
}

/*
* Method setup
* Does nothing
*/
void setup() {
}

/*
* Method draw
* Draw a white background and a cuboid center at (0, 0, 0)
* The cuboid is transformed according to the value of the different variable
* xRotationValue, yRotationValue, scaleValue and a translation is done such that
* the origin (0, 0, 0) is at the center of the window
*/
void draw() {
  background(255, 255, 255);
  My3DPoint eye = new My3DPoint(0, 0, -5000);
  float dimX = 150;
  float dimY = 150;
  float dimZ = 150;
  My3DPoint origin = new My3DPoint(-dimX/2, -dimY/2, -dimZ/2); //The back bottom left vertex
  My3DBox input3DBox = new My3DBox(origin, dimX, dimY, dimZ);
  
  if(rotateXUp) {
    xRotationValue += xRotationFactor;
  }
  else if (rotateXDown) {
    xRotationValue -= xRotationFactor;
  }
  
  if(rotateYUp) {
    yRotationValue += yRotationFactor;
  }
  else if(rotateYDown) {
    yRotationValue -= yRotationFactor;
  }
  
  float[][] xRotation = rotateXMatrix(xRotationValue);
  float[][] yRotation = rotateYMatrix(yRotationValue);
  float[][] scale = scaleMatrix(scaleValue, scaleValue, scaleValue);
  float[][] translation = translationMatrix(width/2, height/2, 0);
  
  input3DBox = transformBox(input3DBox, xRotation);
  input3DBox = transformBox(input3DBox, yRotation);
  input3DBox = transformBox(input3DBox, scale);
  input3DBox = transformBox(input3DBox, translation);
  
  projectBox(eye, input3DBox).render();
}

/*
* Method mouseDragged
* Change de scaling value if the mouse is dragged among y axis
*/
void mouseDragged() {
  if(mouseY < pmouseY) {
    scaleValue += scalingFactor;
    if(scaleValue > MAX_SCALING_VALUE)
      scaleValue = MAX_SCALING_VALUE;
  }
  else if(mouseY > pmouseY) {
    scaleValue -= scalingFactor;
    if(scaleValue < MIN_SCALING_VALUE)
      scaleValue = MIN_SCALING_VALUE;
  }
}

/*
* Method keyPressed
* Change the rotation axis and orientation boolean to true when a specific key is pressed
*/
void keyPressed() {
  if(key == CODED) {
    if(keyCode == UP) {
      rotateXUp = true;
    }
    else if(keyCode == DOWN) {
      rotateXDown = true;
    }
    else if(keyCode == RIGHT) {
      rotateYUp = true;
    }
    else if(keyCode == LEFT) {
      rotateYDown = true;
    }
  }
}

/*
* Method keyReleased
* Change the rotation axis and orientation boolean to false when a specific key is pressed
*/
void keyReleased() {
  if(key == CODED) {
    if(keyCode == UP) {
      //xRotationValue += xRotationFactor;
      rotateXUp = false;
    }
    else if(keyCode == DOWN) {
      //xRotationValue -= xRotationFactor;
      rotateXDown = false;
    }
    else if(keyCode == RIGHT) {
      //yRotationValue += yRotationFactor;
      rotateYUp = false;
    }
    else if(keyCode == LEFT) {
      //yRotationValue -= yRotationFactor;
      rotateYDown = false;
    }
  }
}

/*
* Class My2DPoint
* Represents a point in 2 dimensions
*/
class My2DPoint {
 float x;
 float y;
 My2DPoint(float x, float y) {
   this.x = x;
   this.y = y;
 }
}

/*
* Class My3DPoint
* Represents a point in 3 dimensions
*/
class My3DPoint {
  float x;
  float y;
  float z;
  My3DPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

/*
* Class My2DBox
* Represents a box in 2 dimensions
*/
class My2DBox {
  My2DPoint[] s;
  My2DBox(My2DPoint[] s) {
    this.s = s;
  }
  
  /*
  * Method render()
  * Draw the box in a 2 dimensions plane
  */
  void render() {
    //Draw the "back" of the box
    stroke(0, 255, 0);
    line(s[4].x, s[4].y, s[5].x, s[5].y);
    line(s[5].x, s[5].y, s[6].x, s[6].y);
    line(s[6].x, s[6].y, s[7].x, s[7].y);
    line(s[7].x, s[7].y, s[4].x, s[4].y);
      
    //Draw  the sides of the box
    stroke(0, 0, 255);
    line(s[0].x, s[0].y, s[4].x, s[4].y);
    line(s[3].x, s[3].y, s[7].x, s[7].y);
    line(s[1].x, s[1].y, s[5].x, s[5].y);
    line(s[2].x, s[2].y, s[6].x, s[6].y);
    
    //Draw the "front" of the box
    stroke(255, 0, 0);
    line(s[0].x, s[0].y, s[1].x, s[1].y);
    line(s[1].x, s[1].y, s[2].x, s[2].y);
    line(s[2].x, s[2].y, s[3].x, s[3].y);
    line(s[3].x, s[3].y, s[0].x, s[0].y);
  }
}

/*
* Class My3DBox
* Represents a box in 3 dimensions
*/
class My3DBox {
  My3DPoint[] p;
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ){
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[]{new My3DPoint(x, y+dimY, z+dimZ),
                             new My3DPoint(x, y, z+dimZ),
                             new My3DPoint(x+dimX, y, z+dimZ),
                             new My3DPoint(x+dimX, y+dimY, z+dimZ),
                             new My3DPoint(x, y+dimY, z),
                             origin,
                             new My3DPoint(x+dimX, y, z),
                             new My3DPoint(x+dimX, y+dimY, z)
    };
  }
  My3DBox(My3DPoint[] p) {
    this.p = p;
  }
}

/*
* Function projectPoint
* Takes the center of projection (eye position) and a point
* in 3D space and returns the perspective projection of it on the screen.
*/
My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
  float factor = -p.z/eye.z+1;
  return new My2DPoint((p.x-eye.x)/factor, (p.y-eye.y)/factor);
}

/*
* Function projectBox
* Takes the eye position and a My3DBox object
* and returns its projection as My2DBox.
*/
My2DBox projectBox(My3DPoint eye, My3DBox box) {
  My2DPoint pBox[] = new My2DPoint[8];
  for(int i = 0; i < box.p.length; ++i) {
    pBox[i] = projectPoint(eye, box.p[i]);
  }
  return new My2DBox(pBox);
}

/*
* Function homogeneous3DPoint
* Transforms the 3DPoint into an homogeneous point
* with its 4th value set to 1
*/
float[] homogeneous3DPoint(My3DPoint p) {
  float[] result = {p.x, p.y, p.z, 1};
  return result;
}

/*
* Function rotateXMatrix
* Rotation matrix along x axis of given angle
*/
float[][] rotateXMatrix(float angle) {
  return(new float[][] {{1, 0, 0, 0},
                        {0, cos(angle), sin(angle), 0},
                        {0, -sin(angle), cos(angle), 0},
                        {0, 0, 0, 1}});
}

/*
* Function rotateYMatrix
* Rotation matrix along y axis of given angle
*/
float[][] rotateYMatrix(float angle) {
  return(new float[][] {{cos(angle), 0, sin(angle), 0},
                        {0, 1, 0, 0},
                        {-sin(angle), 0, cos(angle), 0},
                        {0, 0, 0, 1}});
}

/*
* Function rotateZMatrix
* Rotation matrix along z axis of given angle
*/
float[][] rotateZMatrix(float angle) {
  return(new float[][] {{cos(angle), -sin(angle), 0, 0},
                        {sin(angle), cos(angle), 0, 0},
                        {0, 0, 1, 0},
                        {0, 0, 0, 1}});
}

/*
* Function scaleMatrix
* Scale matrix scaling in x, y and z dimension
*/
float[][] scaleMatrix(float x, float y, float z) {
  return(new float[][] {{x, 0, 0, 0},
                        {0, y, 0, 0},
                        {0, 0, z, 0},
                        {0, 0, 0, 1}});
}

/*
* Function tranlationMatrix
* Translation matrix translating among x, y and z dimension
*/
float[][] translationMatrix(float x, float y, float z) {
  return(new float[][] {{1, 0, 0, x},
                        {0, 1, 0, y},
                        {0, 0, 1, z},
                        {0, 0, 0, 1}});
}

/*
* Function matrixProduct
* Computes the dot product between a 4x4 matrix and a 4x1 matrix
*/
float[] matrixProduct(float[][] a, float[] b) {
  float[] m = new float[4];
  //Initialise m
  for(int i = 0; i < m.length; ++i) {
    m[i] = 0.0;
  }
 
  for(int i = 0; i < a.length; ++i) {
    for(int j = 0; j < a[0].length; ++j) {
      m[i] += a[i][j] * b[j];
    }
  }
  return m;
}

/*
* Function transformBox
* Applies the given transformatin to the vertices of the 3DBox
*/
My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  My3DPoint[] p3D = new My3DPoint[box.p.length];
  float[][] pH = new float[p3D.length][4];
  for(int i = 0; i < pH.length; ++i) {
    pH[i] = matrixProduct(transformMatrix, homogeneous3DPoint(box.p[i]));
  }
  
  for(int i = 0; i < pH.length; ++i) {
    p3D[i] = euclidian3DPoint(pH[i]);
  }
  
  return new My3DBox(p3D);
}

/*
* Function euclidian3DPoint
* Brings back an homogeneous point to an euclidian 3D point
*/
My3DPoint euclidian3DPoint(float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}