class InitialStage {
  
  Player player;
  Attendant attendant;
  
  PImage startingRoom;
  JSONArray obstacles;
  int scale = 2;
  
  InitialStage(Player p) {
    player = p;
    attendant = new Attendant(489, 30);
    startingRoom = loadImage("Starting Room.png");
    
    // Load obstacles
    JSONObject map = loadJSONObject("background.json");
    JSONArray layers = map.getJSONArray("layers");
    for (int i = 0; i < layers.size(); i++) {
      JSONObject layer = layers.getJSONObject(i);
      if (layer.getString("name").equals("Obstacles")) {
        obstacles = layer.getJSONArray("objects");
        break;
      }
    }
  }
  
  void initialDisplay () {
    image(startingRoom, 0, 0, 1024, 576);
    attendant.display();
    attendant.attendantLogic();
  }
  
  //internal testing only
  void drawObstacles() {
    noStroke();
  
    for (int i = 0; i < obstacles.size(); i++) {
    fill(255, 0, 0); // Set the color to red
      JSONObject obstacle = obstacles.getJSONObject(i);
      float obsX = (obstacle.getFloat("x")-8) * scale;
      float obsY = (obstacle.getFloat("y")+20) * scale;
      float obsWidth = obstacle.getFloat("width") * scale;
      float obsHeight = obstacle.getFloat("height") * scale;
      rect(obsX, obsY, obsWidth, obsHeight);
  
     Float id = obstacle.getFloat("id");
     float centerX = obsX + obsWidth / 2;
     float centerY = obsY + obsHeight / 2;
     fill(0);
     textAlign(CENTER, CENTER);
     text(id, centerX, centerY);
     }
  }

}
