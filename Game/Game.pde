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
private final float MAX_ANGLE = PI/3.0; // Max angle in rad.
private boolean on;
private PGraphics topView;
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
  topView = createGraphics(130, 130, P2D);
  cam = new Movie(this, "testvideo.mp4");
  on = false;
  textSize(32);
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
  if(!on) {
    text("Press P to play video", 500, height - 50);
  } else {
    text("Press L to pause video", 500, height - 50);
  }
  drawTopView();
  image(topView, 10, height - (topView.height + 10));
  if(keyPressed && (key == 'P' || key == 'p') && !on) {
    on = true;
    cam.loop();
  }
  if(keyPressed && (key == 'L' || key == 'l') && on) {
    on = false;
    cam.pause();
  }
  img = cam.get();
  image(img, 0, 0, img.width/2, img.height/2);
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
    //drawBorderLines(linesToDraw, sobelIm.width);
    intersections = getIntersections(linesToDraw, sobelIm.width, sobelIm.height);
    //drawIntersections(intersections);
    //drawQuads(Collections.singletonList(quads.get(0)), linesIntersection);
    
    if(intersections.size() == 4) {
      t2d = new TwoDThreeD(width, height);
      PVector rot = t2d.get3DRotations(sortCorners(intersections));
      if(board.rotX <= MAX_ANGLE && board.rotX >= -MAX_ANGLE){
        if(rot.x > board.rotX){
          board.rotX = min((board.rotX+rot.x)/2.0, MAX_ANGLE);
        } else if(rot.x < board.rotX){
          board.rotX = max((board.rotX+rot.x)/2.0, -MAX_ANGLE);
        }
      }
      if(board.rotZ <= MAX_ANGLE && board.rotZ >= -MAX_ANGLE){
        if(-rot.y > board.rotZ){
          board.rotZ = min((board.rotZ-rot.y)/2.0, MAX_ANGLE);
        } else if(-rot.y < board.rotZ){
          board.rotZ = max((board.rotZ-rot.y)/2.0, -MAX_ANGLE);
        }
      }
    }
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

/*
* Function drawTopView
* Display the Gaming board's top view
*/
void drawTopView() {
  topView.beginDraw();
  topView.background(128);
  float xPos = topView.width/2 + (ball.location.x * (topView.width*1.0 / board.boardSize));
  float yPos = topView.height/2 + (ball.location.z * (topView.height*1.0 / board.boardSize));
  topView.fill(100);
  topView.ellipse(xPos, yPos, ball.ballRadius/2, ball.ballRadius/2);
  for(Cylinder c : cylinderList) {
    float c_xPos = topView.width/2 + (c.location.x * (topView.width*1.0 / board.boardSize));
    float c_yPos = topView.height/2 + (c.location.z * (topView.height*1.0 / board.boardSize));
    topView.ellipse(c_xPos, c_yPos, c.cylinderRadius/2, c.cylinderRadius/2);
  }
  topView.endDraw();
}

void movieEvent(Movie m) {
  m.read();
}