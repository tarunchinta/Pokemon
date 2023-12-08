import processing.data.JSONArray;
import processing.data.JSONObject;

StringDict effectiveDict;

StringDict resistantDict;

class BattleStage {
  PImage battleRoom;
  SelectionStage selectionStage;
  ArrayList<String> selectedPokemonMoves;
  ArrayList<String> selectedOpponentMoves;
  ArrayList<Integer> opponentPokemonIndices = new ArrayList<Integer>(); 
  JSONArray moveData;
  int[] pokemonHealth = new int[3];
  int[] opponentHealth = new int[3];
  int currentPlayerIndex = 0;
  int currentOpponentIndex = 0;
  boolean isMoveTextActive = false;
  String currentSelectedMove = "";
  String opponentMoveName = "";
  int currentTime = 0;
  boolean playerTurn = true;
  boolean deathScreen = false;
  boolean transitionScreen = false;
  int currentHighScore = 0;
  ArrayList<AttackBeam> attackBeams = new ArrayList<AttackBeam>();
  boolean attack = false;
  color c;

  BattleStage(SelectionStage selectionStage) {
    this.selectionStage = selectionStage;
    
    battleRoom = loadImage("purple_background.png");
    
    selectedPokemonMoves = new ArrayList<String>();
    selectedOpponentMoves = new ArrayList<String>();
    JSONObject data = loadJSONObject("Move.json"); 
    moveData = data.getJSONArray("moves");
    
    effectiveDict = new StringDict();
    //key effective against value
    effectiveDict.set("Fire","Grass");
    effectiveDict.set("Grass","Water");
    effectiveDict.set("Water","Fire");
    
    //key resistant against value
    resistantDict = new StringDict();
    resistantDict.set("Fire", "Grass");
    resistantDict.set("Grass", "Water");
    resistantDict.set("Water", "Fire");
  }
  
  void initializeStats() {
    //create random opponents
    opponentPokemonIndices.clear();
    opponentPokemonIndices.add(int(random(selectionStage.pokemonData.size())));
    opponentPokemonIndices.add(int(random(selectionStage.pokemonData.size())));
    opponentPokemonIndices.add(int(random(selectionStage.pokemonData.size())));
    
    populateSelectedPokemonMoves();
    
    //reset mutable health stats
    pokemonHealth[0] = selectionStage.pokemonData.getJSONObject(selectedPokemonIndices.get(0)).getInt("hp");
    pokemonHealth[1] = selectionStage.pokemonData.getJSONObject(selectedPokemonIndices.get(1)).getInt("hp");
    pokemonHealth[2] = selectionStage.pokemonData.getJSONObject(selectedPokemonIndices.get(2)).getInt("hp");
    opponentHealth[0] = selectionStage.pokemonData.getJSONObject(opponentPokemonIndices.get(0)).getInt("hp");
    opponentHealth[1] = selectionStage.pokemonData.getJSONObject(opponentPokemonIndices.get(1)).getInt("hp");
    opponentHealth[2] = selectionStage.pokemonData.getJSONObject(opponentPokemonIndices.get(2)).getInt("hp");
    
    //turn off initializing
    begOfStage = false;
  }

  void displaySelectionScreen() {
    image(battleRoom, 0, 0, 1048, 461);

    PImage[] pokemonSpritesback = selectionStage.pokemonSpritesback;
    PImage[] pokemonSprites = selectionStage.pokemonSprites;

    populateSelectedPokemonMoves();

    // Pokemon sprite
    if (!selectedPokemonIndices.isEmpty()) {
      int firstSelectedIndex = selectedPokemonIndices.get(currentPlayerIndex);
      PImage selectedPokemonSprite = pokemonSpritesback[firstSelectedIndex];

      float y = (height - selectedPokemonSprite.height) /2.0 ;
      image(selectedPokemonSprite, 50, y, 400, 400);
    }

    if (!selectedPokemonIndices.isEmpty()) {
      int firstSelectedIndex = opponentPokemonIndices.get(currentOpponentIndex);
      PImage selectedPokemonSprite = pokemonSprites[firstSelectedIndex];

      float y = (height - selectedPokemonSprite.height) / 4.5 ;
      image(selectedPokemonSprite, 650, y, 300, 300);
    }

    fill(188, 188, 188);
    rect(0, 461, 1048, 116);

    int rectWidth = 1048 / 4;
    int rectHeight = 116 / 2;
    
    //Move Details
    fill(116, 116, 116);
    rect(2 * rectWidth, 461, 1048 - 2 * rectWidth, 116);
    fill(0);
    
    // Move buttons
    for (int i = 0; i < 4; i++) {
      int col = i % 2;
      int row = i / 2;
      int x = col * rectWidth;
      int y = 461 + row * rectHeight;

     // Hover effect
      if (mouseX >= x && mouseX < x + rectWidth && mouseY >= y && mouseY < y + rectHeight) {
        fill(0);
        String moveName = selectedPokemonMoves.get(i);
        JSONObject moveDetails = findMoveDetails(moveName);
        textAlign(LEFT);
        if (moveDetails != null) {
          String details = "Move: " + moveDetails.getString("name") + " \nType: " + moveDetails.getString("type") + " \nPower: " + moveDetails.getInt("power");
          text(details, 2 * rectWidth + (1048 - 2 * rectWidth) / 2-100, 461 + 30);
        }
        fill(220, 220, 220);
      } else {
        fill(188, 188, 188);
      }

      textAlign(CENTER);
      rect(x, y, rectWidth, rectHeight);
      fill(0);
      text(selectedPokemonMoves.get(i), x + 100, y + rectHeight / 2);
      
      if (attack == true) {
         AttackBeam attackBeam = new AttackBeam(250,480, c);
         attackBeams.add(attackBeam); // Add new AttackBeam to the list
         attack = false; // Reset attack
      }
      
      drawAttackBeams();

      }
    
        
    displayPlayerBar(currentPlayerIndex);
    displayOpponentBar(currentOpponentIndex);
    
    if (isMoveTextActive) {
      if (playerTurn == true) {
        fill(163);
        rect(0, 460, 1024, 120);
        fill(0);
        text(selectionStage.pokemonData.getJSONObject(selectedPokemonIndices.get(currentPlayerIndex)).getString("name") + " used " + currentSelectedMove + "!", 250, 533);
        
        
        if ((millis() - currentTime) >= 1500 ){    
          isMoveTextActive = false;
          isOpponentTurn = true;
          playerTurn = false;
        }
        
      } else if ((millis() - currentTime) <= 1500 && playerTurn == false){
          fill(163);
          rect(0, 460, 1024, 120);
          fill(0);
          text(selectionStage.pokemonData.getJSONObject(opponentPokemonIndices.get(currentOpponentIndex)).getString("name") + " used " + opponentMoveName + "!", 250, 533);
          
          if ((millis() - currentTime) >= 1480 ){    
            isMoveTextActive = false;
            playerTurn = true;
            isOpponentTurn = false;
          }
        }
    }
    
    if ((millis() - currentTime) <= 1500 && deathScreen) {
      fill(163);
      rect(0,0,1024,576);
      fill(0);
      text("Player is out of usable Pokemon. You lost.", 500, 225);
      
      if(millis() - currentTime >= 1480) {
        currentStage = "initial";
      }
    }
    
    if ((millis() - currentTime) <= 2000 && transitionScreen) {
      fill(163);
      rect(0,0,1024,576);
      fill(0);
      text("Good job! Get ready for the next opponent!", 500, 225);
    }
    
    if(millis() - currentTime >= 1980) {
        transitionScreen = false;
    }
  }

  void populateSelectedPokemonMoves() {
    if (!selectedPokemonIndices.isEmpty() && (selectedPokemonIndices.size() < 4) && selectionStage.pokemonData != null) {
      int firstSelectedIndex = selectedPokemonIndices.get(currentPlayerIndex);
      int firstSelectedIndexOpp = opponentPokemonIndices.get(currentOpponentIndex);
      
      JSONObject pokemon = selectionStage.pokemonData.getJSONObject(firstSelectedIndex);
      JSONObject opponent = selectionStage.pokemonData.getJSONObject(firstSelectedIndexOpp);


      selectedPokemonMoves.clear();
      selectedOpponentMoves.clear();

      selectedPokemonMoves.add(pokemon.getString("move1"));
      selectedPokemonMoves.add(pokemon.getString("move2"));
      selectedPokemonMoves.add(pokemon.getString("move3"));
      selectedPokemonMoves.add(pokemon.getString("move4"));
      
      selectedOpponentMoves.add(opponent.getString("move1"));
      selectedOpponentMoves.add(opponent.getString("move2"));
      selectedOpponentMoves.add(opponent.getString("move3"));
      selectedOpponentMoves.add(opponent.getString("move4"));
    }
  }
  
  void handleMouseClick() {
    int rectWidth = 1048 / 4;
    int rectHeight = 116 / 2;
    
    for (int i = 0; i < 4; i++) {
      int col = i % 2;
      int row = i / 2;
      int x = col * rectWidth;
      int y = 461 + row * rectHeight;

      // Hover effect
      if (mouseX >= x && mouseX < x + rectWidth && mouseY >= y && mouseY < y + rectHeight) {
        String moveName = selectedPokemonMoves.get(i);
        currentSelectedMove = moveName;
        currentTime = millis();
        isMoveTextActive = true;
        JSONObject moveDetails = findMoveDetails(moveName);
        
        JSONObject currentPlayer = selectionStage.pokemonData.getJSONObject(selectedPokemonIndices.get(currentPlayerIndex));
        JSONObject currentOpponent = selectionStage.pokemonData.getJSONObject(opponentPokemonIndices.get(currentOpponentIndex));
        
        String playerType = currentPlayer.getString("type");
        String opponentType = currentOpponent.getString("type");
        String moveType = moveDetails.getString("type");
        
        float adRatio = currentPlayer.getFloat("atk") / currentOpponent.getFloat("def");
        float power = moveDetails.getFloat("power");
        float stab = (playerType.equals(moveDetails.getString("type"))) ? 1.5 : 1;
        float effectiveMoveBonus = opponentType.equals(effectiveDict.get(moveType)) ? 1.5 : 1.0;
        float resistantBonus = opponentType.equals(effectiveDict.get(moveType)) ? 0.8 : 1.0; //always less than 1
        
        if(moveName.equals("Recover")){
          pokemonHealth[currentPlayerIndex] = min(currentPlayer.getInt("hp"), 
            int(pokemonHealth[currentPlayerIndex] + int(moveDetails.getFloat("healMod") * currentPlayer.getFloat("hp"))));
        } else {
          int calculatedDamage = int(((power * adRatio / 15) + 2) * stab * effectiveMoveBonus * resistantBonus);
  
          opponentHealth[currentOpponentIndex] = int(opponentHealth[currentOpponentIndex] - calculatedDamage);
          
          //animation logic
          if (moveType.equals("Water")) {
            attack = true;
            c = color(85, 166, 234);
          }
          if (moveType.equals("Fire")) {
                attack = true;
                c = color(250, 117, 15);
          }
          if (moveType.equals("Grass")) {
                attack = true;
                c = color(93, 170, 70);
          }
          if (moveType.equals("Normal")) {
                attack = true;
                c = color(188, 188, 188);
          }          
                    
          //check for opponent death
          if (opponentHealth[currentOpponentIndex] <= 0) {
            if (currentOpponentIndex + 1 < 3) {
              currentOpponentIndex += 1;
            } else {
              println("opponent died");
              currentHighScore += 1;

              transitionScreen = true;
              
              begOfStage = true;
              currentOpponentIndex = 0;
            }
     
          }
          //if they're dead
            //either sub in opponent pokemon
              // opponent move
              //isMoveTextActive = false;
            // or go to next opponent set (change begOfStage = true)
            
        }
      }
    } 
    
    
  
    
    //opponentTurn();
  }
  
  void displayPlayerBar(int i) {
    
    int backgroundBoxX = 80;
    int backgroundBoxY = 240;
    //TODO: health bar modifications
    float healthRatio = float(pokemonHealth[currentPlayerIndex])/float(selectionStage.pokemonData.getJSONObject(selectedPokemonIndices.get(currentPlayerIndex)).getInt("hp"));
    int healthBarW = max(0, int(155.0 * healthRatio));
    
    fill(225);
    stroke(0);
    strokeWeight(4);
    rect(50,200,width/4, 90, 20);
    noStroke();
    
    textAlign(LEFT);
    fill(0);
    text(selectionStage.pokemonData.getJSONObject(selectedPokemonIndices.get(i)).getString("name"), backgroundBoxX, backgroundBoxY);
    
    //background health bar
    stroke(0);
    strokeWeight(2.5);
    fill(255);
    rect(backgroundBoxX + 41, backgroundBoxY + 10, 155, 15, 10);
    noStroke();
    
    //health bar
    fill(color(#2FD356));
    rect(backgroundBoxX + 41, backgroundBoxY + 10, healthBarW, 15, 10);
    fill(0);
    text("HP: ", backgroundBoxX, backgroundBoxY + 30);
    textAlign(CENTER);
  }
  
  void displayOpponentBar(int i) {
    
    int backgroundBoxX = width - 80 - (width/4);
    int backgroundBoxY = 100;
    //TODO: health bar modifications
    //int healthBarW = int(155 * (opponentHealth[currentOpponentIndex]/selectionStage.pokemonData.getJSONObject(opponentPokemonIndices.get(currentOpponentIndex)).getInt("hp")));
    float healthRatio = float(opponentHealth[currentOpponentIndex])/float(selectionStage.pokemonData.getJSONObject(opponentPokemonIndices.get(currentOpponentIndex)).getInt("hp"));
    int healthBarW = max(0, int(155.0 * healthRatio));
    
    fill(225);
    stroke(0);
    strokeWeight(4);
    rect(backgroundBoxX-15,backgroundBoxY-40,width/4, 90, 20);
    noStroke();
    
    textAlign(LEFT);
    fill(0);
    text(selectionStage.pokemonData.getJSONObject(opponentPokemonIndices.get(i)).getString("name"), backgroundBoxX, backgroundBoxY);
    
    //background health bar
    stroke(0);
    strokeWeight(2.5);
    fill(255);
    rect(backgroundBoxX + 41, backgroundBoxY + 10, 155, 15, 10);
    noStroke();
    
    //health bar
    fill(color(#2FD356));
    rect(backgroundBoxX + 41, backgroundBoxY + 10, healthBarW, 15, 10);
    fill(0);
    text("HP: ", backgroundBoxX, backgroundBoxY + 30);
    textAlign(CENTER);
  }
  
  void opponentTurn() {    
    JSONObject currentPlayer = selectionStage.pokemonData.getJSONObject(selectedPokemonIndices.get(currentPlayerIndex));
    JSONObject currentOpponent = selectionStage.pokemonData.getJSONObject(opponentPokemonIndices.get(currentOpponentIndex));
    
    String moveName1 = selectedOpponentMoves.get(int(random(4)));
    opponentMoveName = moveName1;
    isMoveTextActive = true;
    currentTime = millis();
    JSONObject opponentMoveDetails = findMoveDetails(opponentMoveName);
        
    String playerType = currentPlayer.getString("type");
    String opponentType = currentOpponent.getString("type");
    String moveType = opponentMoveDetails.getString("type");
    
    float adRatio = currentOpponent.getFloat("atk") / currentPlayer.getFloat("def");
    float power = opponentMoveDetails.getFloat("power");
    float stab = (opponentType.equals(opponentMoveDetails.getString("type"))) ? 1.5 : 1;
    float effectiveMoveBonus = playerType.equals(effectiveDict.get(moveType)) ? 1.5 : 1.0;
    float resistantBonus = playerType.equals(effectiveDict.get(moveType)) ? 0.8 : 1.0; //always less than 1
    
    if(opponentMoveName.equals("Recover")){
      opponentHealth[currentOpponentIndex] = min(currentOpponent.getInt("hp"), 
        int(opponentHealth[currentOpponentIndex] + int(opponentMoveDetails.getFloat("healMod") * currentOpponent.getFloat("hp"))));
    } else {
      int calculatedDamage = int(((power * adRatio / 15) + 2) * stab * effectiveMoveBonus * resistantBonus);
    
      pokemonHealth[currentPlayerIndex] = int(pokemonHealth[currentPlayerIndex] - calculatedDamage);
      
      if (pokemonHealth[currentPlayerIndex] <= 0) {
        if (currentPlayerIndex + 1 < 3) {
              currentPlayerIndex += 1;
            } else {
              deathScreen = true;
               
              String[] lines = loadStrings("score.txt");
              String highScore = lines[0]; // First line of the file
              
              if (int(highScore) < currentHighScore) {
                String[] data = { str(currentHighScore) };
                saveStrings("data/score.txt", data);
                println(data[0]);
              }
              
            }
      } 

    }

    isOpponentTurn = false;
  }
  
  JSONObject findMoveDetails(String moveName) {
    for (int i = 0; i < moveData.size(); i++) {
        JSONObject move = moveData.getJSONObject(i);
        if (move.getString("name").equals(moveName)) {
            return move;
        }
    }
    return null;
  }
  
  void drawAttackBeams() {
    for (int i = attackBeams.size() - 1; i >= 0; i--) {
        AttackBeam attackBeam = attackBeams.get(i);
        attackBeam.updateAttack(); 
        attackBeam.displayAttack();
    }
}
  
}
