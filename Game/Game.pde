import java.util.ArrayDeque;
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
private int score;
private int lastScore;
private ArrayDeque<Integer> scoreList;
private PGraphics bottomSurface;
private PGraphics topView;
private PGraphics scoreBoard;
private PGraphics barChart;
private HScrollbar scrollBar;

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
  score = 0;
  lastScore = 0;
  scoreList = new ArrayDeque();
  board = new Board();
  ball = new Ball();
  cylinderList = new ArrayList<Cylinder>();
  bottomSurface = createGraphics(width, 150, P2D);
  topView = createGraphics(130, 130, P2D);
  scoreBoard = createGraphics(110, 130, P2D);
  barChart = createGraphics(1000, 100, P2D);
  scrollBar = new HScrollbar(topView.width + scoreBoard.width + 100, height - 40, 300, 20);
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
  drawBottomSurface();
  image(bottomSurface, 0, height - bottomSurface.height);
  drawTopView();
  image(topView, 10, height - (topView.height + 10));
  drawScoreBoard();
  image(scoreBoard, 20 + topView.width, height - (scoreBoard.height + 10));
  drawBarChart();
  image(barChart, 100 + topView.width + scoreBoard.width, height - (barChart.height + 40));
  scrollBar.update();
  scrollBar.display();
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
  if(!isShiftClicked() && !scrollBar.locked){
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

/*
* Function winPoints
* Increase the current score and keeps track
* of the score list
*/
void winPoints() {
  if(ball.velocity.mag() >= 1) {
    score += round(ball.velocity.mag());
    lastScore = round(ball.velocity.mag());
    if(scoreList.size() == 100){
      scoreList.remove();
    }
    scoreList.add(score);
  }
}

/*
* Function winPoints
* Decrease the current score and keeps track
* of the score list
*/
void losePoints() {
  if(ball.velocity.mag() >= 1) {
    score -= round(ball.velocity.mag());
    lastScore = -round(ball.velocity.mag());
    if(scoreList.size() == 100){
      scoreList.remove();
    }
    scoreList.add(score);
  }
}

/*
* Function drawBottomSurface
* Draw the Bottom rectangle surface
*/
void drawBottomSurface() {
  bottomSurface.beginDraw();
  bottomSurface.background(70, 250, 170);
  bottomSurface.endDraw();
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

/*
* Function drawScoreBoard
* Display the score, ball's velocity and last points scored
*/
void drawScoreBoard() {
  int text_x = 10;
  int text_y = 20;
  scoreBoard.beginDraw();
  scoreBoard.background(70, 250, 170);
  scoreBoard.stroke(255);
  scoreBoard.strokeWeight(2);
  scoreBoard.line(1, 1, scoreBoard.width, 1);
  scoreBoard.line(scoreBoard.width-1, 0, scoreBoard.width-1, scoreBoard.height-1);
  scoreBoard.line(1, 1, 1, scoreBoard.height-1);
  scoreBoard.line(1, scoreBoard.height-1, scoreBoard.width-1, scoreBoard.height-1);
  scoreBoard.fill(0);
  scoreBoard.textSize(15);
  scoreBoard.text("Total Score:", text_x, text_y);
  text_y += 15;
  scoreBoard.text(score, text_x, text_y);
  text_y += 25;
  scoreBoard.text("Velocity:", text_x, text_y);
  text_y += 15;
  scoreBoard.text(ball.velocity.mag(), text_x, text_y);
  text_y += 25;
  scoreBoard.text("Last Score:", text_x, text_y);
  text_y += 15;
  scoreBoard.text(lastScore, text_x, text_y);
  scoreBoard.endDraw();
}

/*
* Function drawTopView
* Draw the Gaming board's top view
*/
void drawBarChart() {
  barChart.beginDraw();
  barChart.background(250, 250, 200);
  float midPoint = barChart.Y + barChart.height/2;
  float posCount = 0;
  barChart.fill(200, 80, 20);
  for(Integer i: scoreList) {
    float rectWidth = 10 * (scrollBar.sliderPosition / (scrollBar.sliderPositionMax));
    barChart.rect(barChart.X + posCount, midPoint - i/2, rectWidth, i/2);
    posCount += rectWidth;//rect width
  }
  barChart.endDraw();
}