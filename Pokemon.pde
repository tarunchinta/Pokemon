import processing.data.JSONArray;
import processing.data.JSONObject;
import processing.sound.*;

SoundFile initstageSound;
PImage img;

String currentStage = "initial";
ArrayList<Integer> selectedPokemonIndices = new ArrayList<Integer>(); 
boolean isMuted = false;
boolean begOfStage = true;
boolean isOpponentTurn = false;
boolean keyIsPressed = false;

InitialStage initStage;
SelectionStage selectStage;
BattleStage battleStage;
Player player;

void setup() {
    initStage = new InitialStage(player);
    selectStage = new SelectionStage();
    battleStage = new BattleStage(selectStage);
    
    size(1024,576);
    player = new Player(width/2-30, height/2+45, initStage.obstacles);
    
    initstageSound = new SoundFile(this, "initstagesong.mp3");

    if (initstageSound != null && initstageSound.duration() > 0) {
      initstageSound.loop();
    } else {
      println("Error loading the sound file");
    }
}


void draw() {  
  if (currentStage.equals("initial")) {
    initStage.initialDisplay();
    player.update();
    player.display();
  }
  if (currentStage.equals("Selection")) {
      selectStage.displaySelectionScreen();
  }
  if (currentStage.equals("Battle")) {
      if (begOfStage) {
        battleStage.initializeStats();
      } else if (isOpponentTurn) {
          battleStage.opponentTurn();
      }
      battleStage.displaySelectionScreen();
  }

  if (isMuted) {
    initstageSound.amp(0); // Mute sound
  } else {
    initstageSound.amp(1);
  }
}

void keyPressed() {
  keyIsPressed = true;
  
  if (key == 'm' || key == 'M') {
    isMuted = !isMuted;
  }
}

void keyReleased() {
  keyIsPressed = false;
}

void mouseClicked() {
    if (currentStage.equals("Selection")) {
        selectStage.handleMouseClick();
    } else if (currentStage.equals("Battle")) {
        battleStage.handleMouseClick();

    }
}
