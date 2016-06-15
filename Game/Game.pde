import processing.video.*;
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
private final float MAX_ANGLE = 1.0472; // Max angle in rad.
private final float MAX_SPEED_PLATE = 1.5; // Max rotational speed factor of plate.
private final float MIN_SPEED_PLATE = 0.1; // Min rotational speed factor of plate.
private final float UPDATE_SPEED_PLATE = 0.1; // Modifier value for plate rotational speed.
PImage img;
PImage threshIm;
PImage blurrIm;
PImage cleanIm;
PImage sobelIm;
ArrayList<PVector> intersections;
Movie cam;
TwoDThreeD t2d;
float discretizationStepsPhi = 0.005f;
float discretizationStepsR = 2.5f;

/*
* Method settings
* Sets up the window size to take the full display size and the rendering mode to P3D
*/
void settings(){
  fullScreen();
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
  cam = new Movie(this, "testvideo.mp4");
  cam.loop();
  //cam.speed(0.4);
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
  background(0);
  img = cam.get();
  img.loadPixels();
  image(img, 0, 0, 300, 300);
  threshIm = HBSthresholding(img, 83.210526, 142.9342, 15.434211, 189.9079, 59.05263, 255.0);
  blurrIm = gaussianBlur(gaussianBlur(threshIm));
  cleanIm = brightnessThresholding(blurrIm, 253, 255);
  sobelIm = sobel(cleanIm);
  
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((sobelIm.width + sobelIm.height) * 2 + 1) / discretizationStepsR);
  // our accumulator (with a 1 pix margin around
  int[] accumulator = getHoughAccumulator(sobelIm, phiDim, rDim);
  ArrayList<PVector> linesIntersection = hough(6, accumulator, phiDim, rDim);
  ArrayList<int[]> quads = getQuad(linesIntersection, sobelIm.width, sobelIm.height);
  ArrayList<PVector> linesToDraw = new ArrayList<PVector>();
  
  //We select only the first quad or drawing
  if(quads.size() > 0) {
    for(int i : quads.get(0)) {
      linesToDraw.add(linesIntersection.get(i));
    }
    
    //lineToDraw contient les lignes du meilleur quad
    drawBorderLines(linesToDraw, sobelIm.width);
    intersections = getIntersections(linesToDraw, sobelIm.width, sobelIm.height);
    drawIntersections(intersections);
    drawQuads(Collections.singletonList(quads.get(0)), linesIntersection);
    
    t2d = new TwoDThreeD(width, height);
    PVector rot = t2d.get3DRotations(sortCorners(intersections));
    if(board.rotX <= MAX_ANGLE && board.rotX >= -MAX_ANGLE){
      if(-rot.x > board.rotX){
        board.rotX = min(-rot.x, MAX_ANGLE);
      } else if(-rot.x < board.rotX){
        board.rotX = max(-rot.x, -MAX_ANGLE);
      }
    }
    if(board.rotZ <= MAX_ANGLE && board.rotZ >= -MAX_ANGLE){
      if(-rot.y > board.rotZ){
        board.rotZ = min(-rot.y, MAX_ANGLE);
      } else if(-rot.y < board.rotZ){
        board.rotZ = max(-rot.y, -MAX_ANGLE);
      }
    }
    /*
    board.rotX = -rot.x;
    board.rotZ = -rot.y;*/
  }

  board.display(isShiftClicked());
  for(Cylinder c : cylinderList) {
    c.display();
  }
  ball.update(board);
  ball.checkEdges();
  for(Cylinder c : cylinderList) {
    ball.checkCylinderCollision(c);
  }
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

void movieEvent(Movie m) {
  m.read();
}