private Ball ball;
private Board board;
private ArrayList<Cylinder> cylinderList;
private final float SPEED_ROT_MULT = 3.0; // Rotational speed multiplier.
private final float MAX_ANGLE = 60.0; // Max angle in degrees.
private final float MAX_SPEED_PLATE = 1.5; // Max rotational speed factor of plate.
private final float UPDATE_SPEED_PLATE = 0.1; // Modifier value for plate rotational speed.
void settings(){
  size(displayWidth, displayHeight, P3D);
}

void setup(){
  board = new Board();
  ball = new Ball();
  cylinderList = new ArrayList<Cylinder>();
}

void draw(){
  if(keyPressed == true && keyCode == SHIFT){
    background(255);
    stroke(0);
    text("PAUSE:  Cliquez pour ajouter un cylindre.", 10, 10);
    board.shiftDisplay();
    for(int i = 0; i < cylinderList.size(); ++i){
      cylinderList.get(i).shiftDisplay();
    }
    ball.shiftDisplay();
  } else {
    background(255);
    stroke(0);
    text("Rotation en X: " + board.rotX + ", Rotation en Z: " + board.rotZ + ", Speed: " + board.speed, 10, 10);
    board.display();
    for(int i = 0; i < cylinderList.size(); ++i){
      cylinderList.get(i).display();
    }
    ball.update(board);
    ball.checkEdges();
    for(int i = 0; i < cylinderList.size(); ++i){
      ball.checkCylinderCollision(cylinderList.get(i));
    }
    ball.display();
  }
}

void mouseDragged(){
  if(!(keyPressed == true && keyCode == SHIFT)){
    int oldPosX = pmouseX;
    int oldPosY = pmouseY;
    if(board.rotX <= MAX_ANGLE && board.rotX >= -MAX_ANGLE){
      if(mouseY < oldPosY){
        board.rotX = min(board.rotX + (SPEED_ROT_MULT*board.speed), MAX_ANGLE);
      } else if(mouseY > oldPosY){
        board.rotX = max(board.rotX - (SPEED_ROT_MULT*board.speed), -MAX_ANGLE);
      }
    }
    if(board.rotZ <= MAX_ANGLE && board.rotZ >= -MAX_ANGLE){
      if(mouseX > oldPosX){
        board.rotZ = min(board.rotZ + (SPEED_ROT_MULT*board.speed), MAX_ANGLE);
      } else if(mouseX < oldPosX){
        board.rotZ = max(board.rotZ - (SPEED_ROT_MULT*board.speed), -MAX_ANGLE);
      }
    }
  }
 }

void mouseWheel(MouseEvent event){
  if(!(keyPressed == true && keyCode == SHIFT)){
    float mod = event.getCount();
    if(mod < 0 && board.speed < MAX_SPEED_PLATE){
      board.speed = min(board.speed + UPDATE_SPEED_PLATE, MAX_SPEED_PLATE);
    } else if(mod > 0 && board.speed > UPDATE_SPEED_PLATE){
      board.speed = max(board.speed - UPDATE_SPEED_PLATE, UPDATE_SPEED_PLATE);
    }
  }
}

void mouseClicked(){
  if(keyPressed == true && keyCode == SHIFT){
    Cylinder cylinder = new Cylinder(mouseX, -board.boardThik/2, mouseY);
    if(cylinder.checkBorder() && !cylinder.isOverlap(cylinderList)){
      cylinderList.add(cylinder);
    }
  }
}