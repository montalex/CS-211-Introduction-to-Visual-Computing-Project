/*
* Board.pde
* The board class
* Author : Alexis Montavon, Boris Flückiger and Dorian Laforest
* Group BE
*
* Represents the playing board.
*/
class Board{
  private float rotX; // Rotational angle in X coordinate.
  private float rotZ; // Rotational angle in Z coordinate.
  private final float boardSize = 500; // Size of squared board.
  private final float boardThick = 20; // Thickness of board.

  /*
  * Board's constructor
  * Creates a new Board object, initialize its
  * rotation angles for X and Z axes and rotation speed.
  */
  Board(){
    rotX = 0.0;
    rotZ = 0.0;
  }

  /*
  * Method display
  * Displays the board on the screen.
  * Rotates the board regarding the game mode
  */
  void display(boolean isShiftClicked){
    noStroke();
    fill(118);
    lights();
    translate(width/2, height/2, 0);
    if(isShiftClicked){
      rotateX(-PI/2.0);
    } else {
      rotateX(rotX);
      rotateZ(rotZ);
    }
    box(boardSize, boardThick, boardSize);
  }
}