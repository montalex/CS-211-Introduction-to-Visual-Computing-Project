/*
* Ball.pde
* The ball class
* Author : Alexis Montavon, Boris Flückiger and Dorian Laforest
* Group BE
*
* Represents the ball on the playing board.
*/
class Ball {
  private PVector location; // Coordinate vector of ball.
  private PVector velocity; // Velocity vector of ball.
  private PVector gravity; // Gravity vector.
  private PVector friction; // Friction vector.
  private float ballRadius; // Ball radius.
  private final float GRAVITY = 0.15; // Gravity constant.
  private final float REBOUND_COEF = 0.5; // Rebound coeeficient.
  private final float frictionMagnitude = 0.01; // Friction force magnitude = normal Force * mu (1 * 0.01).
  
  /* 
  * Ball's constructor
  * Creates a new Ball object, initialize its
  * location (on the center of board), velocity and gravity.
  */
  Ball(){
    ballRadius = 20; 
    location = new PVector(0, - (ballRadius + board.boardThick/2), 0);
    velocity = new PVector(0, 0, 0);
    gravity = new PVector(0, 0, 0);
  }
  
  /*
  * Method update
  * Updates all forces that influence ball movements
  * Friction, gravity, velocity and the location vector
  * if and only if the game is not in "Add cylinder mode"
  */
  void update(Board board) {
    if(!isShiftClicked()){
      friction = velocity.copy();
      friction.mult(-1);
      friction.normalize();
      friction.mult(frictionMagnitude);
      gravity.set(sin(radians(board.rotZ))*GRAVITY, 0, -sin(radians(board.rotX))*GRAVITY);
      velocity.add(gravity);
      velocity.add(friction);
      location.add(velocity);
    }
  }
  
  /*
  * Method display
  * Displays the ball on the screen
  * at its correct position regarding in
  * which mode the game is
  */
  void display(boolean isShiftClicked) {
    pushMatrix();
    noStroke();
    fill(118);
    //lights();
    if(isShiftClicked){
      translate(location.x, -(ballRadius + board.boardThick/2), location.z);
      sphere(ballRadius);
    } else {
      translate(location.x, location.y, location.z);
      sphere(ballRadius);
    }
    popMatrix();
  }
   
   /*
   * Method checkEdges
   * Makes sure that the ball stays on the plate's surface.
   */
   void checkEdges() {
     if(location.x > board.boardSize/2) {
       velocity.x = velocity.x * -REBOUND_COEF;
       location.x = board.boardSize/2;
     } else if(location.x < -board.boardSize/2){
       velocity.x = velocity.x * -REBOUND_COEF;
       location.x = -board.boardSize/2;
     }
     if(location.z > board.boardSize/2) {
       velocity.z = velocity.z * -REBOUND_COEF;
       location.z = board.boardSize/2;
     } else if(location.z < -board.boardSize/2){
        velocity.z = velocity.z * -REBOUND_COEF;
        location.z = -board.boardSize/2;
     }
   }
   
   /*
   * Method checkCylinderCollision
   * Makes sure the ball bounces off the cylinders
   * and replaces it to its correct place if overlapping
   * with a cylinder
   */
   void checkCylinderCollision(Cylinder cylinder){
     PVector Vdist = new PVector(location.x - cylinder.location.x, location.z - cylinder.location.z);
     float distance = Vdist.mag();
     if(distance <= ballRadius + cylinder.cylinderRadius){
       location.x = location.x + Vdist.x  / (ballRadius+cylinder.cylinderRadius);
       location.z = location.z + Vdist.z / (ballRadius+cylinder.cylinderRadius);
       PVector normal = new PVector(location.x - cylinder.location.x, 0, location.z - cylinder.location.z).normalize();
       velocity = PVector.sub(velocity, normal.mult(PVector.dot(velocity, normal) * 2));
     }
   }
}