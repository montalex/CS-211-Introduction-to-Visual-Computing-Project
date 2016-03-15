class Ball {
  private PVector location; // Coordinate vector of ball
  private PVector velocity; // Velocity vector of ball
  private PVector gravity; // Gravity vector
  private PVector friction; // Friction vector
  private float ballRadius; // Ball radius
  private final float GRAVITY = 0.1; // Gravity constant
  private final float REBOUND_COEF = 0.5; // Rebound coeeficient
  private final float normalForce = 1;
  private final float mu = 0.01;
  private final float frictionMagnitude = normalForce * mu;
  
  Ball(){
    ballRadius = 20; 
    location = new PVector(0, - (ballRadius + board.boardThik/2), 0);
    velocity = new PVector(0, 0, 0);
    gravity = new PVector(0, 0, 0);
  }
  
  void update(Board b) {
    friction = velocity.copy();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    gravity.set(sin(radians(b.rotZ))*GRAVITY, 0, -sin(radians(b.rotX))*GRAVITY);
    velocity.add(gravity);
    velocity.add(friction);
    location.add(velocity);
  }
  
  void display() {
    noStroke();
    fill(210, 0, 0);
    lights();
    translate(location.x, location.y, location.z);
    sphere(ballRadius);
   }
   
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
}