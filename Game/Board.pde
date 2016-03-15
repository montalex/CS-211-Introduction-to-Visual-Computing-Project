class Board{
  private float rotX; // Rotational angle (in degrees) in X coordinate
  private float rotZ; // Rotational angle (in degrees) in Z coordinate
  private float speed; // Rotational speed of board
  private float boardSize; // Size of sqared board
  private float boardThik; // Thikness of board

  Board(){
    rotX = 0.0;
    rotZ = 0.0;
    speed = 1.0;
    boardSize = 500;
    boardThik = 20;
  }

  void display(){
    noStroke();
    fill(0, 255, 0);
    lights();
    translate(width/2, height/2, 0);
    rotateX(radians(rotX));
    rotateZ(radians(rotZ));
    box(boardSize, boardThik, boardSize);
  }  
}