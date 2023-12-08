class Player {
  float x, y;
  int dir = 0; // 0: down, 1: left, 2: right, 3: up
  int frame = 0; 
  PImage[] sprites = new PImage[16];
  float speed = 2;
  int lastFrameChange = 0;
  int frameInterval = 200;
  float scale = 2;
  JSONArray obstacles;
  
  Player(float x, float y, JSONArray obstacles) {
    this.x = x;
    this.y = y;
    this.obstacles = obstacles;
    loadSprites();
  }

  void loadSprites() {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        sprites[i * 4 + j] = loadImage("sprite_" + i + "_" + j + ".png");
      }
    }
  }

  void update() {
   float newX = x, newY = y;
   float speedScaled = speed * scale; 
  
   if (keyPressed) {
     if (key == 'w' || key == CODED && keyCode == UP) {
       newY -= speedScaled;
       dir = 3;
     } else if (key == 's' || key == CODED && keyCode == DOWN) {
       newY += speedScaled;
       dir = 0;
     } else if (key == 'a' || key == CODED && keyCode == LEFT) {
       newX -= speedScaled;
       dir = 1;
     } else if (key == 'd' || key == CODED && keyCode == RIGHT) {
       newX += speedScaled;
       dir = 2;
     } 

     // Check for collisions before updating player's position
     if (!checkCollision(newX, newY)) {
       x = newX;
       y = newY;
     }
  
     if (millis() - lastFrameChange > frameInterval) {
       frame = (frame + 1) % 4;
       lastFrameChange = millis();
     }
   }

   x = constrain(x, -10, width - getSpriteWidth()+20);
   y = constrain(y, 0, height - getSpriteHeight());
  }

  void display() {
    PImage currentSprite = sprites[dir * 4 + frame];
    image(currentSprite, x, y, currentSprite.width, currentSprite.height);
  }

boolean checkCollision(float newX, float newY) {
 if (obstacles != null) {

   for (int i = 0; i < obstacles.size(); i++) {
   JSONObject obstacle = obstacles.getJSONObject(i);
   float obsX = (obstacle.getFloat("x")-8)*scale;
   float obsY = (obstacle.getFloat("y")+20)*scale;
   float obsWidth = obstacle.getFloat("width")*scale;
   float obsHeight = obstacle.getFloat("height")*scale;

   // Calculate the player's bounding box
   float playerX = newX;
   float playerY = newY;
   float playerWidth = getSpriteWidth();
   float playerHeight = getSpriteHeight();

   // Check for collision
   if (playerX < obsX + obsWidth && playerX + playerWidth > obsX &&
       playerY < obsY + obsHeight && playerY + playerHeight > obsY) {
     return true; // Collision detected   
      }
    }
 }
    return false; // No collision
  }

    float getSpriteWidth() {
      return sprites[dir * 4 + frame].width-5;
    }

    float getSpriteHeight() {
      return sprites[dir * 4 + frame].height-5;
    }
}
