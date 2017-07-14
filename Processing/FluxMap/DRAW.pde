// Main Tab for drawing information to screen canvas

boolean displayFixtures = true;
boolean displayReadings = true;
boolean displaySimulation = false;
boolean displayError = false;
String infoType = "data";
//String infoType = "model";

// Graphic Dimensions
float buffer = 0.1; // 0.0 to 1.0
int mouseBuffer = 1; // Tolerance of Mouse Sensitivy on Canvas
int shadowGap = 5;
int strokeWidth = 2;
int textMargin = 10;
int infoHeight = 130;
int histogramHeight = 120;
int legendHeight = 320;
int coeffHeight = 220;
int pixelSummaryWidth = 400;
int pixelSummaryHeight = 100;
float errVizTolerance = 0.5; // 1 = full tolerance; Less than 1.0 is more "strict"
float cellWidth, gridWidth, gridHeight;
float dX, dY, bevel;

// Maximum reasonable lux value for visualization rendering
float LIGHT_MAX = 40.0; // lux

// Graphic Colors
int CANVAS       = 35;
int CARD         = 50;
int SHADOW       =  0;
int FIXTURE      = color(255,   0,   0);
int READING      = color(  0, 255,   0);
int LIGHT_MODEL  = color(255, 255, 255);
int TOO_DIM      = color(150,  50, 255);
int TOO_BRIGHT   = color(255, 255,   0);

// "Sodium" Color
//int LIGHT_MODEL  = color(238, 221, 130);

void draw() {
  
  background(CANVAS);
  
  // Variable to Shift grid graphic to center of screen canvas
  dX = (width - gridWidth) / 2;
  dY = (height - gridHeight) / 2;
  bevel = 0.1*min(dX, dY);
  
  // Main Grid/Map Visualization
  drawGridArea();
  
  // Pixel Summary
  drawPixelSummary();
  
  // Margin Background
  fill(SHADOW); noStroke();
  rect(dX + gridWidth + dY + shadowGap, dY + shadowGap, dX - 2*dY, gridHeight, bevel);
  fill(CARD); noStroke(); 
  rect(dX + gridWidth + dY, dY, dX - 2*dY, gridHeight, bevel);
  
  // Margin Content
  if (infoType.equals("data") ) {  
    drawAttributes();
    drawReadingHist();  
  } else if (infoType.equals("model") ) {  
    if (modelType.equals("point")) {
      drawEquations(pointModel);
      drawModelHist(pointHist);
    } else if (modelType.equals("gaussian")) {
      drawEquations(gaussianModel);
      drawModelHist(gaussianHist);
    }
  }
  
  // Logo + Credits
  drawCredits();
  
  // Menu Buttons
  hideMenu.draw();
  if (showMainMenu) {
    mainMenu.draw();
  }
  
  noLoop();
}

void drawAttributes() {
  
  // Text Information
  fill(textColor);
  textAlign(LEFT);
  
  text(
    "Background:\n\nUse this application to explore empirical urban light data and evaluate urban light simulations models.", 
    dX + gridWidth + dY + textMargin, dY + textMargin, dX - 2*dY - 2*textMargin, gridHeight
  );
  
  text(
    "Case Study:"     + "\n" +
    "Jurisdiction:"     + "\n\n" +
    "Latitude:"       + "\n" +
    "Longitide:"      + "\n\n" +
    "Grid Resolution:"+ "\n" +
    "Area Size:"      + "\n\n" +
    "Scale:"          + "\n\n" +
    "",
    dX + gridWidth + dY + textMargin, dY + textMargin + infoHeight, dX - 2*dY - 2*textMargin, gridHeight
  );
  
  textAlign(RIGHT);
  text(
    AREA                                             + "\n"   + 
    CITY                                             + "\n\n" +
    
    // Latitude/Longitude
    String.format("%.03f", centerLatitude) + " deg"  + "\n"   +
    String.format("%.03f", centerLongitude) + " deg" + "\n\n" +
    
    // Grid Resolution
    "(" + gridU + "," + gridV + ")"                + "\n" +
    
    // Area Size
    "(" + int(gridU*gridSize*1000) + "m, "         +
    int(gridV*gridSize*1000) + "m)"                + "\n\n" +
    
    // Scale
    gridSize*1000 + " m / grid cell"                + "\n\n" +
    "",
    dX + gridWidth + dY + textMargin, dY + textMargin + infoHeight, dX - 2*dY - 2*textMargin, gridHeight
  );
  
  textAlign(LEFT);
}

void drawEquations(LightSim s) {
  // Text Information
  fill(textColor); textAlign(LEFT);
  text("Model Attributes", dX + gridWidth + dY + textMargin, dY + 2*textMargin);
  
  // Draw PGraphic of Equations
  image(equations, dX + gridWidth + dY + textMargin, dY + 2*textMargin + 20);
  
  // Asterisk Highlighting Active Model in PGraphic
  stroke(#FFFF00, 200); strokeWeight(3); fill(#FFFF00, 10); // yellow
  int x = -100;
  if (modelType.equals("point")) {
    x = 275;
  } else if (modelType.equals("gaussian")) {
    x = 334;
  }
  ellipse(dX + gridWidth + dY + 1.79*textMargin, dY + textMargin + 30 + x, 15, 18);
  
  // Coefficient Values
  fill(textColor); noStroke();
  text("Model Coefficients", dX + gridWidth + dY + textMargin, height - dY - coeffHeight - 30);
  String var = "";
  if (modelType.equals("point") ){
    var += 
    "H = " + s.h + " m\n" + 
    "I\u2080 = " + s.luminance + " lum\n";
  } else if (modelType.equals("gaussian") ){
    var += 
    "H = " + s.h + " m\n" + 
    "I\u2080 = " + s.luminance + " lum\n" + 
    "g = " + s.g;
  }
  text(var, dX + gridWidth + dY + textMargin, height - dY - coeffHeight);
}

void drawReadingHist() {
  // Text Info
  textAlign(LEFT);
  text("" +
    "  Light Fixtures:" + "\n\n" + 
    "Lamp fixture locations are courtesy of publically available data from Cambridge GIS, 2014." + "\n\n" +
    "  Light Readings:" + "\n\n" + 
    "Observed illuminace readings collected January, 2017 at 9:30pm on a weeknight via personal vehicle with equipped sensors.",
    dX + gridWidth + dY + textMargin, height - dY - legendHeight - 12, dX - 2*dY - 2*textMargin, gridHeight
  );
  
  textAlign(RIGHT);
  text(
    lightFixture.size() + "\n\n\n\n\n\n" + 
    lightReading.size() + "\n\n" + 
    "", 
    dX + gridWidth + dY + textMargin, height - dY - legendHeight - 12, dX - 2*dY - 2*textMargin, gridHeight
  );
  textAlign(LEFT);;
  
  // Draw Fixture Symbol Key
  fill(FIXTURE);
  ellipse(dX + gridWidth + dY + textMargin, height - dY - legendHeight - 5, 3, 3);
  
  // Draw Reading Symbol Key
  fill(READING);
  rect(dX + gridWidth + dY + textMargin, height - dY - legendHeight + 78, 3, 3);

  // Draw Histogram of Readings
  readingHist.draw(int(dX + gridWidth + dY + textMargin), int(height - dY - histogramHeight), int(dX - 2*dY - 2*textMargin), histogramHeight, READING);
}


void drawModelHist(Histogram mH) {
  // Text Lable
  textAlign(LEFT);
  text(
    "\n\n\n\n  Simulated Values:", 
    dX + gridWidth + dY + textMargin, height - dY - coeffHeight, dX - 2*dY - 2*textMargin, gridHeight
  );
  textAlign(RIGHT);
  text(
    "\n\n\n\n" + gridU*gridV, 
    dX + gridWidth + dY + textMargin, height - dY - coeffHeight, dX - 2*dY - 2*textMargin, gridHeight
  );
  textAlign(LEFT);
  
  // Draw Fixture Symbol Key
  fill(LIGHT_MODEL);
  rect(dX + gridWidth + dY + textMargin, height - dY - coeffHeight + 63, 3, 3);

  // Draw Histogram of Readings
  mH.draw(int(dX + gridWidth + dY + textMargin), int(height - dY - histogramHeight), int(dX - 2*dY - 2*textMargin), histogramHeight, LIGHT_MODEL);
}

void drawGridArea() {
  // Background Canvas
  fill(SHADOW); stroke(0); strokeWeight(strokeWidth);
  rect(dX - strokeWidth, dY - strokeWidth, gridWidth + 2*strokeWidth, gridHeight + 2*strokeWidth, bevel);
  
  // Draw Satallite if scale is correct
  if (gridSize*gridU == 1.0 && gridSize*gridV == 1.0 && centerLatitude == LAT && centerLongitude == LON) {
    image(basemap, dX, dY, gridWidth, gridHeight);
    fill(SHADOW, 100); stroke(0); strokeWeight(strokeWidth);
    rect(dX - strokeWidth, dY - strokeWidth, gridWidth + 2*strokeWidth, gridHeight + 2*strokeWidth, bevel);
  }
    
  // Draw Simulation
  if (displaySimulation) {
    noStroke();
    for (int u=0; u<gridU; u++) {
      for (int v=0; v<gridU; v++) {
        
        if (modelType.equals("point") ) {
          fill(LIGHT_MODEL, 255.0 * pointModel.light[u][v] / LIGHT_MAX);
        } else if(modelType.equals("gaussian") ) {
          fill(LIGHT_MODEL, 255.0 * gaussianModel.light[u][v] / LIGHT_MAX);
        }
        if (u >= 0 && u < gridU && v >= 0 && v < gridV) {
          rect(u*cellWidth + dX, v*cellWidth + dY, cellWidth, cellWidth);
        }
      }
    }
    String name ="";
    if (modelType.equals("point") ) {
      name += "(1) Point Source Model";
    } else if(modelType.equals("gaussian") ) {
      name += "(2) Gaussian LED Model";
    }
    fill(textColor);
    textAlign(RIGHT);
    text(name, dX + gridWidth - 10, dY + 20);
    textAlign(LEFT);
  }
  
  // Draw Error
  if (displayError) {
    noStroke();
    for (int i=0; i<pointModel.error.size(); i++) {
      int u = 0;
      int v = 0;
      float err = 0;;
      if (modelType.equals("point") ) {
        err = pointModel.error.get(i).z;
        u = (int) pointModel.error.get(i).x;
        v = (int) pointModel.error.get(i).y;
      } else if(modelType.equals("gaussian") ) {
        err = gaussianModel.error.get(i).z;
        u = (int) gaussianModel.error.get(i).x;
        v = (int) gaussianModel.error.get(i).y;
      }
      
      int shade;
      if (err > 0) {
        // Yellow (Too Bright)
        shade = TOO_BRIGHT;
      } else {
        // Teal (Too Dim)
        shade = TOO_DIM;
      }
      
      fill(shade, 255.0 * abs(err) / (errVizTolerance*LIGHT_MAX));
      
      if (u >= 0 && u < gridU && v >= 0 && v < gridV) {
        rect(u*cellWidth + dX, v*cellWidth + dY, cellWidth, cellWidth);
      }
    }
    
    textAlign(RIGHT);
    fill(TOO_DIM);
    text("Model Too Dim", dX + gridWidth - 10, height - dY - 35);
    fill(TOO_BRIGHT);
    text("Model Too Bright", dX + gridWidth - 10, height - dY - 15);
    textAlign(LEFT);
  }
  
  // Draw Fixtures
  if (displayFixtures) {
    fill(FIXTURE);
    noStroke();
    for(int f=0; f<lightFixture.size(); f++) {
      int u = int(lightFixture.get(f)[1].x);
      int v = int(lightFixture.get(f)[1].y);
      if (u >= 0 && u < gridU && v >= 0 && v < gridV) {
        ellipse((0.5+u)*cellWidth + dX, (0.5+v)*cellWidth + dY, max(3,cellWidth), max(3,cellWidth));
      }
    }
  }
  
  // Draw Readings
  if (displayReadings) {
    noStroke();
    float alpha;
    for(int f=0; f<lightReading.size(); f++) {
      int u = int(lightReading.get(f)[1].x);
      int v = int(lightReading.get(f)[1].y);
      if (u >= 0 && u < gridU && v >= 0 && v < gridV) {
        alpha = min(255.0, 255.0 * lightReading.get(f)[1].z / LIGHT_MAX);
        colorMode(HSB);
        fill(READING, alpha);
        rect(u*cellWidth + dX, v*cellWidth + dY, cellWidth, cellWidth);
        colorMode(RGB);
      }
    }
  }
}


// p = point model
// g = gaussian model
// r = reading (observed)
// l = location
String pLux, gLux, rLux;
String rPrint, rLat, rLon;
String fPrint, fLat, fLon;
String lPrint, pPrint, gPrint;
String pErr, gErr;
int mouseU, mouseV;
void drawPixelSummary() {
  
  rPrint = "";
  fPrint = "";
  lPrint = "";
  pPrint = "";
  gPrint = "";
  rLux   = "";
  pLux   = "";
  gLux   = "";
  pErr   = "";
  gErr   = "";
  
  mouseU = mouseToU();
  mouseV = mouseToV();
  
  if (gridU >= 400) {
    mouseBuffer = gridU / 400;
  } else {
    mouseBuffer = 0;
  }
  
  // If Mouse is within grid
  if ( isGrid(mouseU, mouseV) ) {
    if (infoType.equals("model")) {
      pLux   = String.format("%.02f",    pointModel.light[mouseU][mouseV]) + " lux"; 
      gLux   = String.format("%.02f", gaussianModel.light[mouseU][mouseV]) + " lux";
    }
  
    int posU, posV;
    for (int u=mouseBuffer; u>=0; u--) {
      for (int v=mouseBuffer; v>=0; v--) {
        for (int i=-1; i<2; i+=2) {
          posU = i*u + mouseU;
          posV = i*v + mouseV;
          
          // If Light Fixture is Present
          if (lightFixtureHash.get(posU + "," + posV) != null) {
            fLat = String.format("%.04f", lightFixtureHash.get(posU + "," + posV)[2]) + " lat";
            fLon = String.format("%.04f", lightFixtureHash.get(posU + "," + posV)[3]) + " lon";
            lPrint = "(" + fLat + "," + fLon + ")";
            fPrint = "Known Lamp Fixture";
            
          }
          
          // If Light Reading is Present
          if (lightReadingHash.get(posU + "," + posV) != null) {
            rLat = String.format("%.06f", lightReadingHash.get(posU + "," + posV)[2]) + " lat";
            rLon = String.format("%.06f", lightReadingHash.get(posU + "," + posV)[3]) + " lon";
            rLux = String.format("%.02f", lightReadingHash.get(posU + "," + posV)[4]) + " lux";
            lPrint = "(" + rLat + "," + rLon + ")";
            rPrint = "Observed Reading";
            
            if (infoType.equals("model") ) {
              pLux   = String.format("%.02f",    pointModel.light[posU][posV]) + " lux"; 
              gLux   = String.format("%.02f", gaussianModel.light[posU][posV]) + " lux";
              pErr = "(Error: " + String.format("%.01f", ( pointModel.light[posU][posV]    - lightReadingHash.get(posU + "," + posV)[4] ) ) + ") ";
              gErr = "(Error: " + String.format("%.01f", ( gaussianModel.light[posU][posV] - lightReadingHash.get(posU + "," + posV)[4] ) ) + ") ";
            }
          }
    
        }
      }
    }
    
    // Cursor
    noFill(); stroke(#00FFFF); strokeWeight(strokeWidth);
    rect(dX + (mouseU-mouseBuffer)*cellWidth, dY + (mouseV-mouseBuffer)*cellWidth, (2*mouseBuffer + 1)*cellWidth, (2*mouseBuffer + 1)*cellWidth);
    
    // Background Tile
    fill(CARD, 200);
    rect(dX + gridWidth - pixelSummaryWidth - 10, dY + gridHeight - pixelSummaryHeight - 10,  pixelSummaryWidth, pixelSummaryHeight, bevel);
    
    if (infoType.equals("model") ) {
      pPrint += "(Model 1) Point Source";
      gPrint += "(Model 2) Gaussian LED";
    }
    
    // Var Name (Left Align)
    fill(textColor); textAlign(LEFT); noStroke();
    text(
      "" +
      "\n" + fPrint + 
      "\n" + 
      "\n" + rPrint +
      "\n" + pPrint +
      "\n" + gPrint, 
      dX + gridWidth - pixelSummaryWidth + 10, dY + gridHeight - pixelSummaryHeight + 10
    );
    
    // Var Value (Right Align)
    fill(textColor); textAlign(RIGHT);
    text(
      "(" + mouseU + "," + mouseV + ")" + "\n" +
      lPrint + "\n\n" + 
      rLux   + "\n" +
      pErr + pLux + "\n" +
      gErr + gLux, 
      dX + gridWidth - 20, dY + gridHeight - pixelSummaryHeight + 10
    );
  }
}

void drawCredits() {
  // Draw Logos and Credits
  image(logo_PHL, 50, height - dY - 120, 50, 65); 
  image(logo_MIT, 50, height - dY - 25, 50, 25); 
  
  fill(textColor);
  text(CREDITS, 120, height - dY - 115 + 4);
}
