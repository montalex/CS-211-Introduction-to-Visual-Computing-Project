/*
* Represent a cylinder obstacle.
*/
class Cylinder {
  private PVector location; // Coordinate vector of ball.
  private float cylinderRadius = 40; // Cylinder radius.
  private float cylinderHeight = 50; // Cylinder height.
  private int cylinderResolution = 40; // Cylinder resolution.
  private PShape openCylinder = new PShape(); // The empty shell cylinder.
  private PShape topClosed = new PShape(); // The top circle of the cylinder.
  private PShape bottomClosed = new PShape(); // The bottom circle of the cylinder.
  private PShape cylinder = new PShape(); // A shape to unit them all, the complete cylinder.
  private float angle; // Use to create the cylinder.
  private float[] x = new float[cylinderResolution + 1]; // Use to create the cylinder.
  private float[] z = new float[cylinderResolution + 1]; // Use to create the cylinder.
  
  /*
  * Creates a new cylinder object, initialize his location
  * and forms the object.
  */
  Cylinder(float posX, float posY, float posZ){
    stroke(0);
    fill(128, 128, 128);
    lights();
    location = new PVector(posX - width/2, posY, posZ - height/2);
    for(int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderRadius;
      z[i] = cos(angle) * cylinderRadius;
    }
    openCylinder = createShape();
    topClosed = createShape();
    bottomClosed = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    bottomClosed.beginShape(TRIANGLE_FAN);
    topClosed.beginShape(TRIANGLE_FAN);
    bottomClosed.vertex(0, 0, 0);
    topClosed.vertex(0, -cylinderHeight, 0);
    for(int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], 0 , z[i]);
      openCylinder.vertex(x[i], -cylinderHeight, z[i]);
      bottomClosed.vertex(x[i], 0, z[i]);
      topClosed.vertex(x[i], -cylinderHeight, z[i]);
    }
    openCylinder.endShape();
    bottomClosed.endShape();   
    topClosed.endShape(); 
    cylinder = createShape(GROUP);
    cylinder.addChild(bottomClosed);
    cylinder.addChild(openCylinder);
    cylinder.addChild(topClosed);
  }
  
  /*
  * Display cylinder on the board.
  */
  void display(){
    pushMatrix();
    translate(location.x, location.y, location.z);
    shape(cylinder);
    popMatrix();
  }
  
  /*
  * Special display when SHIFT is pressed
  * Seen from above, used to add cylinders.
  */
  void shiftDisplay(){
    pushMatrix();
    translate(location.x, location.y, location.z);
    shape(cylinder);
    popMatrix();
  }
  
  boolean isOverlap(ArrayList<Cylinder> list){
    PVector vDistBall = new PVector(location.x - ball.location.x, location.z - ball.location.z);
    float distBall = vDistBall.mag();
    if(distBall <= cylinderRadius + ball.ballRadius){
      return true;
    }
    for(int i = 0; i < list.size(); ++i){
       PVector vDist = new PVector(location.x - list.get(i).location.x, location.z - list.get(i).location.z);
       float dist = vDist.mag();
       if((dist <= 2 * cylinderRadius)){
         return true;
       }
    }
    return false;
  }
  
  boolean checkBorder(){
    return ((abs(location.x) <= board.boardSize/2) && (abs(location.z) <= board.boardSize/2));
  }
}