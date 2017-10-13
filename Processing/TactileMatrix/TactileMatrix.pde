/*  Ira Winder, jiw@mit.edu
 *
 *  A Script for simulation of lighting interventions upon a Tactile Matrix with two primary KPIs:
 *  (1) Lighting Intensity
 *  (2) Pedestrian Safety from Collisions
 */

// Library needed for ComponentAdapter()
import java.awt.event.*;

PImage logo_MIT, logo_PHL, kendall, intersection;

// dimensions of main canvas, in pixes
int screenWidth, screenHeight;

void setupDemo() {
  screenWidth = 1280;
  screenHeight = 768;
  projectorWidth = 1920;
  projectorHeight = 1200;
  projectorOffset = 1280;
}

void setup() {
  setupDemo();
  
  size(screenWidth, screenHeight, P2D);
  
  // Window may be resized after initialized
  frame.setResizable(true);
  
  // Loads and formats menue items
  loadMenu(width, height);
  
  // Recalculates relative positions of canvas items if screen is resized
  frame.addComponentListener(new ComponentAdapter() { 
      public void componentResized(ComponentEvent e) { 
        if(e.getSource()==frame) { 
          // insert graphics to update
          loadMenu(width, height);
        } 
      } 
    }
  );
  
  logo_MIT = loadImage("MIT_logo.png");
  logo_PHL = loadImage("PHL_logo.png");
  // Static Image of Neighborhood for Screen
  kendall = loadImage("kendall.png");
  // Static Image of Intersection for Table
  intersection = loadImage("intersection_bw.png");
  
  // Setup Screen Font
  PFont main = loadFont("data/ArialUnicodeMS-20.vlw");
  textFont(main);
  
  // Initialize Graphics Objects for Drawing Table Surface
  setupTable();
  
  // Allows Communication with Colortizer
  initUDP();
  
  // Initialize Output Matrices for holding heatmaps
  setupScores();
  
  // Activate Table Surface Upon Application Execution
  toggle2DProjection();
}

void draw() {

  // Decode Lego pieces only if there is a change in Colortizer input
  if (changeDetected) {
    println("Lego Movement Detected");
    decodePieces();
    changeDetected = false;
  }
  
  background(0);
  image(kendall, 0.5*(width - kendall.width), 0.5*(height - kendall.height));
  
  // Refers to "drawTable" tab
  drawTable();
  
  // Draws Menu
  hideMenu.draw();
  if (showMainMenu) {
    mainMenu.draw();
  }
}

void decodePieces() {
  
  // Calculate lighting solution for table based upon lightpole location
  lightField(tablePieceInput);
  
  // Calculate safety solution based upon lightField solution
  safetyField();
  
  // Safety Display Toggle
  if (tablePieceInput[5 - matrix.MARGIN_W][matrix.V-2][0] > -1 && tablePieceInput[5 - matrix.MARGIN_W][matrix.V-2][0] < ID_MAX) {
    showSafety = true;
  } else {
    showSafety = false;
  }
  
  // Light Display Toggle
  if (tablePieceInput[5 - matrix.MARGIN_W][matrix.V-3][0] > -1 && tablePieceInput[5 - matrix.MARGIN_W][matrix.V-3][0] < ID_MAX) {
    showLight = true;
  } else {
    showLight = false;
  }
}
