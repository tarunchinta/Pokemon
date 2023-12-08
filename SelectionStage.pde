import processing.data.JSONArray;
import processing.data.JSONObject;
import java.net.URL;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.ArrayList;

boolean showError = false;

class SelectionStage {
    PImage selectionScreen;
    JSONArray pokemonData;
    int selectedPokemonIndex = -1;
    int mousehoverindex = -1;
    final int gridCount = 15;
    PImage[] pokemonSprites;
    PImage[] pokemonSpritesback;
    PImage selectedPokemonImage;
    JSONObject selectedPokemonInfo;
    
    ArrayList<PVector> pokemonPositions = new ArrayList<PVector>();
    ArrayList<PVector> pokemonSizes = new ArrayList<PVector>();
   
    SelectionStage() {
        JSONObject data = loadJSONObject("Pokemon.json"); 
        pokemonData = data.getJSONArray("pokemon");
        pokemonSprites = new PImage[pokemonData.size()];
        pokemonSpritesback = new PImage[pokemonData.size()];
        loadPokemonSprites();
        selectionScreen = loadImage("Selection Screen.png");
    }

void loadPokemonSprites() {
    for (int i = 0; i < pokemonData.size(); i++) {
        String spritePath = "data/images/" + pokemonData.getJSONObject(i).getString("imageFront");
        String spritePath2 = "data/images/" + pokemonData.getJSONObject(i).getString("imageBack");
        
        PImage fimg = loadImage( spritePath);
        PImage bimg = loadImage(spritePath2);
        
        pokemonSprites[i] = fimg;
        pokemonSpritesback[i] = bimg;
    }
}
    
void displaySelectionScreen() {
    image(selectionScreen, 0, 0);
    PFont gameFont = createFont("ARCADE.TTF", 55);
    fill(0);
    textFont(gameFont);
    textAlign(LEFT, TOP);
    text("Select up to 3 Pokemon!", 200, 10);

    displayPokemonGrid();
    displayLargeInfoBox();
    displayPokemonDetails(gameFont);
    
    //Show error
    if (showError) {
    fill(255, 0, 0);
    textSize(40);
    text("Please select at least 3 Pokemon!", 50, 530);
    }
  
    // Draw the "Confirm Team" button
    float buttonWidth = 150; 
    float buttonHeight = 50; 
    float buttonX = width - buttonWidth - 30; 
    float buttonY = height - buttonHeight - 30; 
    float cornerRadius = 20;
    fill(200); 
    rect(buttonX, buttonY, buttonWidth, buttonHeight, cornerRadius);
    fill(0); 
    textFont(gameFont, 20); 
    textAlign(CENTER, CENTER);
    text("Confirm Team", buttonX, buttonY, buttonWidth, buttonHeight);

    // Draw three white rectangles at the bottom right
    float rectLength = 50; 
    float rectSpacing = 10; 
    float totalWidth = 3 * rectLength + 2 * rectSpacing; 
    float startX = width - totalWidth - 250;
    float startY = height - rectLength - 80;
    textFont(gameFont, 30); 
    text("This is your current team:", startX - 200, startY + 26); 
    for (int i = 0; i < 3; i++) {
        float x = startX + i * (rectLength + rectSpacing);
        fill(255);
        rect(x, startY, rectLength, rectLength, cornerRadius);
    }
 
            for (int i = 0; i < selectedPokemonIndices.size(); i++) {
              float x = startX + i * (rectLength + rectSpacing);
              fill(255);
              rect(x, startY, rectLength, rectLength, cornerRadius);
              int pokemonIndex = selectedPokemonIndices.get(i);
              if (pokemonIndex < pokemonSprites.length) {
                  image(pokemonSprites[pokemonIndex], x, startY, rectLength, rectLength);
              }
        }
        
   float gridSpacing = width / (float) (gridCount);
   float squareSize = gridSpacing * 0.8f;
   int numPerRow = gridCount / 3; 

   for (int i = 0; i < gridCount; i++) {
       float x = (i % numPerRow) * gridSpacing + gridSpacing * 0.1f; 
       float y = startY + (i / numPerRow) * gridSpacing + gridSpacing * 0.1f;

       pokemonPositions.add(new PVector(x, y));
       pokemonSizes.add(new PVector(squareSize, squareSize));      
    }
}


void displayPokemonGrid() {
    float gridSpacing = width / (float) gridCount;
    float squareSize = gridSpacing * 0.8f;
    float startY = height / 6.0; 
    int numPerRow = gridCount / 3; 
    float cornerRadius = 1;
    
    for (int i = 0; i < gridCount; i++) {
        float x = (i % numPerRow) * gridSpacing + gridSpacing * 0.1f; 
        float y = startY + (i / numPerRow) * gridSpacing + gridSpacing * 0.1f;

        if (mouseX > x && mouseX < x + squareSize && mouseY > y && mouseY < y + squareSize) {
            stroke(255, 255, 0);
            strokeWeight(12);
          if (i < pokemonData.size()) {
            selectedPokemonIndex = i; 
            }
        } else {
            noStroke();
        }

        fill(255);
        rect(x, y, squareSize, squareSize, cornerRadius); 

        if (i < pokemonSprites.length) {
            image(pokemonSprites[i], x, y, squareSize, squareSize);
        }
    }
}

void handleMouseClick() {
    float gridSpacing = width / (float) gridCount;
    float startY = height / 6.0; 
    int numPerRow = gridCount / 3;

    int col = int((mouseX - gridSpacing * 0.1f) / gridSpacing);
    int row = int((mouseY - startY - gridSpacing * 0.1f) / gridSpacing);
    int index = row * numPerRow + col;

    if (index >= 0 && index < pokemonData.size()) {
        if (selectedPokemonIndices.contains(index)) {
            selectedPokemonIndices.remove(Integer.valueOf(index));
        } else if (selectedPokemonIndices.size() < 3) {
            selectedPokemonIndices.add(index);
        }
    }
    
    float buttonWidth = 150; 
    float buttonHeight = 50; 
    float buttonX = width - buttonWidth - 30; 
    float buttonY = height - buttonHeight - 30; 

    if (mouseX >= buttonX && mouseX <= buttonX + buttonWidth &&
        mouseY >= buttonY && mouseY <= buttonY + buttonHeight) {
              if (selectedPokemonIndices.size() < 3) {
                showError = true;
              } else {
                showError = false;
                currentStage = "Battle";
    }
  }
}

void displayLargeInfoBox() {
    float largeSquareSize = 300; 
    float largeSquareX = width - largeSquareSize - 300;
    float largeSquareY = height / 6.0f;
    float cornerRadius = 20;
    
    fill(255);
    noStroke();
    rect(largeSquareX, largeSquareY, largeSquareSize + 200, largeSquareSize, cornerRadius);
    fill(0); 
}

void displayPokemonDetails(PFont gameFont) {
    if (selectedPokemonIndex != -1) {
        JSONObject pokemonInfo = pokemonData.getJSONObject(selectedPokemonIndex);
        PImage largeImage = loadImage("data/images/" + pokemonInfo.getString("imageFront"));

        float largeSquareSize = 300; 
        float largeSquareX = width - largeSquareSize - 300;
        float largeSquareY = height / 6.0f;

        float imgWidth = largeSquareSize / 2;
        float imgHeight = imgWidth * (largeImage.height / (float) largeImage.width);
        image(largeImage, largeSquareX + largeSquareSize / 2, largeSquareY, imgWidth*2, imgHeight*2);

        fill(0);
        textFont(gameFont, 20);
        textAlign(LEFT, TOP);
        float textX = largeSquareX + 10;
        float textY = largeSquareY + 10;
        text("Name: " + pokemonInfo.getString("name"), textX, textY);
        textY += 30;
        text("Type: " + pokemonInfo.getString("type"), textX, textY);
        textY += 30;
        text("HP: " + pokemonInfo.getInt("hp"), textX, textY);
        textY += 30;
        text("ATK: " + pokemonInfo.getInt("atk"), textX, textY);
        textY += 30;
        text("DEF: " + pokemonInfo.getInt("def"), textX, textY);
        textY += 30;
        text("SPA: " + pokemonInfo.getInt("spa"), textX, textY);
        textY += 30;
        text("SPD: " + pokemonInfo.getInt("spd"), textX, textY);
        textY += 30;
        text("SPE: " + pokemonInfo.getInt("spe"), textX, textY);
    }
  }
}
