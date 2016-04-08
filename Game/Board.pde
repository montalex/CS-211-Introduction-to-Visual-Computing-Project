/*
* Represent the playing board.
*/
class Board{
  private float rotX; // Rotational angle (in degrees) in X coordinate.
  private float rotZ; // Rotational angle (in degrees) in Z coordinate.
  private float speed; // Rotational speed of board.
  private final float boardSize = 600; // Size of sqared board.
  private final float boardThik = 20; // Thikness of board.
  
  /*
  * Create new Board object, initialize his
  * rotation angles for axes X and Z and rotation speed.
  */
  Board(){
    rotX = 0.0;
    rotZ = 0.0;
    speed = 1.0;
  }
  
  /*
  * Display board on the screen.
  */
  void display(){
    noStroke();
    fill(0, 255, 0);
    lights();
    translate(width/2, height/2, 0);
    rotateX(radians(rotX));
    rotateZ(radians(rotZ));
    box(boardSize, boardThik, boardSize);
  }
  
  /*
  * Special display when SHIFT is pressed
  * Seen from above.
  */
  void shiftDisplay(){
    noStroke();
    fill(0, 255, 0);
    lights();
    translate(width/2, height/2, 0);
    rotateX(radians(-90));
    box(boardSize, boardThik, boardSize);
  }
}