class Attendant {
  
  float x, y;
  PImage attendant1;
  String score;
  Attendant(float x, float y) {
    this.x = x;
    this.y = y;
    attendant1 = loadImage("attendant-sprite.png");
  }

 boolean underAttendant(Player player1) {
  float playerLeftX = player1.x;
  float playerRightX = player1.x + player1.sprites[0].width * player1.scale;
  float playerBottomY = player1.y + player1.sprites[0].height * player1.scale;

  float attendantRightX = x + attendant1.width;
  float attendantTopY = 170;
  return playerLeftX <= attendantRightX && playerRightX >= x &&
         playerBottomY >= attendantTopY && abs(player1.y - 170) < 10;
}

 void attendantLogic() {
  if (underAttendant(player)) {
    fill(255);
    rect(0, 483, 1024, 97);
    PFont gameFont = createFont("ARCADE.TTF", 35);

    fill(0);
    textFont(gameFont);
    textAlign(LEFT, TOP);
    text("Would you like to play the game?\nPress 'y' for yes and 'n' for no.", 10, 500);

    if (key == 'y' && keyIsPressed) {
      currentStage = "Selection";
      print("doodoo");
      
    } else if (key == 'n') {
      fill(255);
      rect(0, 483, 1024, 97); // clear the text box
      fill(0);
      textFont(gameFont);
      textAlign(LEFT,TOP);
      text("Press 1 to see your score.", 10, 500);
    }

      String[] lines = loadStrings("data/score.txt");
      if (lines.length > 0) {
        score = lines[0]; // First line of the file
      } else {
        score = "0";
      }
      
    if (key == '1') {
      // Player selected '1' to see the score
      fill(255);
      rect(0, 483, 1024, 97);;
      fill(0);
      text("Score: " + score + "\nIf you still want to play, press 'y'\nOr else, thanks for chatting with me. See you next time! ", 10, 490);
    } else if (key == '2') {  
      fill(255);
      rect(0, 533, 1024, 43);
    }
  }
   
  }

  void display() {
    image(attendant1, 489, 30);
  }
}
