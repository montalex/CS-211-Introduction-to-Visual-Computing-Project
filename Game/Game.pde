/*
* Game.pde
* The game main class
* Author : Alexis Montavon, Boris Flückiger and Dorian Laforest
* Group BE
*/
private Ball ball;
private Board board;
private ArrayList<Cylinder> cylinderList;
private final float SPEED_ROT_MULT = 3.0; // Rotational speed multiplier.
private final float MAX_ANGLE = 60.0; // Max angle in degrees.
private final float MAX_SPEED_PLATE = 1.5; // Max rotational speed factor of plate.
private final float MIN_SPEED_PLATE = 0.1; // Min rotational speed factor of plate.
private final float UPDATE_SPEED_PLATE = 0.1; // Modifier value for plate rotational speed.

/*
* Method settings
* Sets up the window size to take the full display size and the rendering mode to P3D
*/
void settings(){
  size(displayWidth, displayHeight, P3D);
}

/*
* Method setup
* Creates a new board and ball and
* initialise the cylinder list to an empty one
*/
void setup(){
  board = new Board();
  ball = new Ball();
  cylinderList = new ArrayList<Cylinder>();
}

/*
* Method draw
* Draw a white background with a board and a ball on it
* If shift is clicked goes to "Add cylinder mode" and show a top view of the board
* clicking on the board will add cylinder.
* Otherwise the ball move according to gravity and frictional force, bounces on edges and cylinder.
* Mouse drag tilts the board arond the X and Z axes
* The mouse wheel inscrease/decrease the tilt motion speed
*/
void draw(){
  background(255);
  stroke(0);
  /*
  if(isShiftClicked()){
    text("PAUSE:  Cliquez pour ajouter un cylindre.", 10, 10);
  } else {
    text("Rotation en X: " + board.rotX + ", Rotation en Z: " + board.rotZ + ", Speed: " + board.speed, 10, 10);
  }
  */
  board.display(isShiftClicked());
  for(Cylinder c : cylinderList) {
    c.display();
  }
  /*
  for(int i = 0; i < cylinderList.size(); ++i){
    cylinderList.get(i).display();
  }
  */
  ball.update(board);
  ball.checkEdges();
  for(Cylinder c : cylinderList) {
    ball.checkCylinderCollision(c);
  }
  /*
  for(int i = 0; i < cylinderList.size(); ++i){
      ball.checkCylinderCollision(cylinderList.get(i));
  }
  */
  ball.display(isShiftClicked());
}

/*
* Method mouseDragged
* If not in "Add cylinder mode" :
* Changes the X and Z axes rotation value between -MAX_ANGLE and +MAX_ANGLE degrees
* X axis when the mouse moves vertically
* Y axis when the mouse moves horizontally
* 
*/
void mouseDragged(){
  if(!isShiftClicked()){
    if(board.rotX <= MAX_ANGLE && board.rotX >= -MAX_ANGLE){
      if(mouseY < pmouseY){
        board.rotX = min(board.rotX + (SPEED_ROT_MULT*board.speed), MAX_ANGLE);
      } else if(mouseY > pmouseY){
        board.rotX = max(board.rotX - (SPEED_ROT_MULT*board.speed), -MAX_ANGLE);
      }
    }
    if(board.rotZ <= MAX_ANGLE && board.rotZ >= -MAX_ANGLE){
      if(mouseX > pmouseX){
        board.rotZ = min(board.rotZ + (SPEED_ROT_MULT*board.speed), MAX_ANGLE);
      } else if(mouseX < pmouseX){
        board.rotZ = max(board.rotZ - (SPEED_ROT_MULT*board.speed), -MAX_ANGLE);
      }
    }
  }
 }

/*
* Method mouseWheel
* If not in "Add cylinder mode" :
* Changes the board tilting speed between MAX_SPEED_PLATE and MIN_SPEED_PLATE
*/
void mouseWheel(MouseEvent event){
  if(!isShiftClicked()){
    float mod = event.getCount();
    if(mod < 0 && board.speed < MAX_SPEED_PLATE){
      board.speed = min(board.speed + UPDATE_SPEED_PLATE, MAX_SPEED_PLATE);
    } else if(mod > 0 && board.speed > UPDATE_SPEED_PLATE){
      board.speed = max(board.speed - UPDATE_SPEED_PLATE, MIN_SPEED_PLATE);
    }
  }
}

/*
* Method mouseClicked
* If in "Add cylinder mode" :
* Adds a Cylinder with it center where the mouse is pointing
* if and only if it is on the plate, it is not overlapping with another cylinder
* and it is not on the ball
*/
void mouseClicked(){
  if(isShiftClicked()){
    Cylinder cylinder = new Cylinder(mouseX, -board.boardThick/2, mouseY);
    if(cylinder.checkBorder() && !cylinder.isOverlap(cylinderList)){
      cylinderList.add(cylinder);
    }
  }
}


/*
* Function isShiftClicked
* Returns true if the shift key is clicked
*/
boolean isShiftClicked(){
  return (keyPressed == true && keyCode == SHIFT);
}