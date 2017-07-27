// Main Tab for enabling user interface elements such as buttons, key presses, and mouse clicks

// Class that holds a button menu
Menu mainMenu, hideMenu;

// Global Text and Background Color
int textColor = 255;
int background = 50;
int BUTTON_OFFSET_H = 45;
int BUTTON_OFFSET_W = 50;

// Menu Alignment on Screen
String align = "LEFT";

// Set this to true to display the main menue upon start
boolean showMainMenu = true;

// Define/Arrange how many buttons are in the Main Menu and 
// what they are named by editing this String array:
// [0] Name; [1] Abbreviated name
String[][] buttonNames = 
{ 
  { "Data Info", "d" },
  { "Light Fixtures", "f" },
  { "Light Readings", "r" },
  { "VOID", "" },
  { "Model Info", "m" },
  { "Simulate Light", "s" },
  { "Model Error", "e" },
  { "Point Source Model", "1" },
  { "Gaussian LED Model", "2" },
  { "Next Model Fit", "t" },
  { "VOID", "" },
  { "Increase Resolution", ">" },
  { "Decrease Resolution", "<" },
  { "Zoom In", "-" },
  { "Zoom Out", "+" },
  { "Reset View", "SPACE" }
};

// Hash Map of Button Names where Key is key-command and Value is buttonNames[] index
HashMap<String, Integer> bHash;

// This Strings is for the hideMenu, formatted as array for Menu Class Constructor
String[][] show = { {"Show Main Menu (h)", "h"} };

void loadMenu(int canvasWidth, int canvasHeight) {
  // Initializes Menu Items (canvas width, canvas height, button width[pix], button height[pix], 
  // number of buttons to offset downward, String[] names of buttons)
  String[][] hideText = show;
  hideMenu = new Menu(canvasWidth, canvasHeight, max(int(width*.13), 160), 25, 0, hideText, align);
  mainMenu = new Menu(canvasWidth, canvasHeight, max(int(width*.13), 160), 25, 2, buttonNames, align);
  
  // Hash Map of Button Names where Key is key-command and Value is buttonNames[] index
  bHash = hashButtons(buttonNames);
  
  // Depress Active Buttons
  hideMenu.buttons[0].isPressed = showMainMenu;
  mainMenu.buttons[ bHash.get("f") ].isPressed = displayFixtures;
  mainMenu.buttons[ bHash.get("r") ].isPressed = displayReadings;
  mainMenu.buttons[ bHash.get("s") ].isPressed = displaySimulation;
  
  // Depress Selected Model Button
  if (modelType.equals("point")) {
    mainMenu.buttons[ bHash.get("1") ].isPressed = true;
    mainMenu.buttons[ bHash.get("2") ].isPressed = false;
  } else if (modelType.equals("gaussian")) {
    mainMenu.buttons[ bHash.get("1") ].isPressed = false;
    mainMenu.buttons[ bHash.get("2") ].isPressed = true;
  }
  
  if (gridU >= MAX_RES || gridV >= MAX_RES) {
    mainMenu.buttons[ bHash.get(">") ].active = false;
  }

}

void keyPressed() {
  switch(key) {
    case 'h': 
      key_h();
      break;
    case 'f': 
      key_f();
      break;
    case 'r': 
      key_r();
      break;
    case 's': 
      key_s();
      break;
    case '1': 
      key_1();
      break;
    case '2': 
      key_2();
      break;
    case 'e': 
      key_e();
      break;
    case 'm': 
      key_m();
      break;
    case 'd': 
      key_d();
      break;
    case '+': 
      key_plus();
      break;
    case '-': 
      key_minus();
      break;
    case '<':
      key_leftCarrot();
      break;
    case '>':
      key_rightCarrot();
      break;
    case ' ':
      key_space();
      break;
    case 't':
      key_t();
      break;
  }
  
  if (key == CODED) {
    if (keyCode == UP) {
      key_up();
    }
    
    if (keyCode == DOWN) {
      key_down();
    }
    
    if (keyCode == LEFT) {
      key_left();
    }
    
    if (keyCode == RIGHT) {
      key_right();
    }
  }
  
  loop();
}

// The result of each button click is defined here
void mousePressed() {
  
  // Hide/Show Menu
  if(hideMenu.buttons[0].over()){  
    key_h();
  }
  
  // Main Menu Buttons:
  
  if(mainMenu.buttons[ bHash.get("f") ].over()){ 
    key_f();
  }
  
  if(mainMenu.buttons[ bHash.get("r") ].over()){ 
    key_r();
  }
  
  if(mainMenu.buttons[ bHash.get("s") ].over()){ 
    key_s();
  }
  
  if(mainMenu.buttons[ bHash.get("1") ].over()){ 
    key_1();
  }
  
  if(mainMenu.buttons[ bHash.get("2") ].over()){ 
    key_2();
  }
  
  if(mainMenu.buttons[ bHash.get("e") ].over()){ 
    key_e();
  }
  
  if(mainMenu.buttons[ bHash.get("d") ].over()){ 
    key_d();
  }
  
  if(mainMenu.buttons[ bHash.get("m") ].over()){ 
    key_m();
  }
  
  if(mainMenu.buttons[ bHash.get("+") ].over()){ 
    key_plus();
  }
  
  if(mainMenu.buttons[ bHash.get("-") ].over()){ 
    key_minus();
  }
  
  if(mainMenu.buttons[ bHash.get("<") ].over()){ 
    key_leftCarrot();
  }
  
  if(mainMenu.buttons[ bHash.get(">") ].over()){ 
    key_rightCarrot();
  }
  
  if(mainMenu.buttons[ bHash.get("SPACE") ].over()){ 
    key_space();
  }
  
  if(mainMenu.buttons[ bHash.get("t") ].over()){ 
    key_t();
  }
  
  loop();
}

// Refreshes when there's a mouse mouse movement
void mouseMoved() {
  loop();
}

// Updates when mouse released
void mouseReleased() {
  loop();
}

void key_h() {
  // "Hide Main Menu"
  showMainMenu = !showMainMenu;
  hideMenu.buttons[0].isPressed = showMainMenu;
}

void key_f() {
  // Show/Hide Lighting Fixtures
  displayFixtures = !displayFixtures;
  mainMenu.buttons[ bHash.get("f") ].isPressed = displayFixtures;
}

void key_r() {
  // Show/Hide Emprical Readings
  displayReadings = !displayReadings;
  mainMenu.buttons[ bHash.get("r") ].isPressed = displayReadings;
  
  displayError = false;
  mainMenu.buttons[ bHash.get("e") ].isPressed = displayError;
}

void key_s() {
  // Show Hide Simulated light model
  displaySimulation = !displaySimulation;
  mainMenu.buttons[ bHash.get("s") ].isPressed = displaySimulation;
}

void key_1() {
  modelType = "point";
  
  // Depress Selected Model Button
  mainMenu.buttons[ bHash.get("1") ].isPressed = true;
  mainMenu.buttons[ bHash.get("2") ].isPressed = false;
}

void key_2() {
  modelType = "gaussian";
  
  // Depress Selected Model Button
  mainMenu.buttons[ bHash.get("1") ].isPressed = false;
  mainMenu.buttons[ bHash.get("2") ].isPressed = true;
}

void key_e() {
  // Show/Hide Model Error
  displayError = !displayError;
  mainMenu.buttons[ bHash.get("e") ].isPressed = displayError;
  
  displayReadings = false;
  mainMenu.buttons[ bHash.get("r") ].isPressed = displayReadings;
}

void key_d() {
  infoType = "data";
  
  // Show Hide Simulated light model
  displaySimulation = false;
  mainMenu.buttons[ bHash.get("s") ].isPressed = displaySimulation;
  
  // Show/Hide Lighting Fixtures
  displayFixtures = true;
  mainMenu.buttons[ bHash.get("f") ].isPressed = displayFixtures;
  
  // Show/Hide Lighting Readings
  displayReadings = true;
  mainMenu.buttons[ bHash.get("r") ].isPressed = displayReadings;
  
  // Show/Hide Lighting Error
  displayError = false;
  mainMenu.buttons[ bHash.get("e") ].isPressed = displayError;
}

void key_m() {
  infoType = "model";
  
  // Show Hide Simulated light model
  displaySimulation = true;
  mainMenu.buttons[ bHash.get("s") ].isPressed = displaySimulation;
  
  // Show/Hide Lighting Fixtures
  displayFixtures = false;
  mainMenu.buttons[ bHash.get("f") ].isPressed = displayFixtures;
  
  // Show/Hide Light Readings
  displayReadings = false;
  mainMenu.buttons[ bHash.get("r") ].isPressed = displayReadings;
  
  // Show/Hide Error
  displayError = true;
  mainMenu.buttons[ bHash.get("e") ].isPressed = displayError;
}

void key_plus() {
  if (!initializing) {
    gridSize /= 2;
    initEnvironment();
    initializing = false;
  }
}

void key_minus() {
  if (!initializing) {
    gridSize *= 2;
    initEnvironment();
    initializing = false;
  }
}

void key_up() {
  if (!initializing) {
    centerLatitude += nudgeDegree;
    initEnvironment();
    initializing = false;
  }
}

void key_down() {
  if (!initializing) {
    centerLatitude -= nudgeDegree;
    initEnvironment();
    initializing = false;
  }
}

void key_left() {
  if (!initializing) {
    centerLongitude -= nudgeDegree;
    initEnvironment();
    initializing = false;
  }
}

void key_right() {
  if (!initializing) {
    centerLongitude += nudgeDegree;
    initEnvironment();
    initializing = false;
  }
}

void key_rightCarrot() {
  if (!initializing && mainMenu.buttons[ bHash.get(">") ].active) {
    gridSize /= 2;
    gridU *= 2;
    gridV *= 2;
    initEnvironment();
    initializing = false;
    
    mainMenu.buttons[ bHash.get("<") ].active = true;
    if (gridU >= MAX_RES || gridV >= MAX_RES) {
      mainMenu.buttons[ bHash.get(">") ].active = false;
    }
  } else {
    println("Resolution is already too high!");
  }
}

void key_leftCarrot() {
  if (!initializing && mainMenu.buttons[ bHash.get("<") ].active) {
    
    gridSize *= 2;
    gridU /= 2;
    gridV /= 2;
    initEnvironment();
    initializing = false;
    
    mainMenu.buttons[ bHash.get(">") ].active = true;
    if (gridU <= MIN_RES || gridV <= MIN_RES) {
      mainMenu.buttons[ bHash.get("<") ].active = false;
    }
  } else {
    println("Resolution is already too low!");
  }
}

void key_space() {
  if (!initializing) {
    // Location of Canvas (Kendall Square)
    gridU = GRID_U;
    gridV = GRID_V;
    gridSize = GRID_SIZE;
    centerLatitude = LAT;
    centerLongitude = LON;
    initEnvironment();
    initializing = false;
  }
}

void key_t() {
  if (!initializing) {
    if (fitType < 3) {
      fitType ++;
    } else {
      fitType = 0;
    }
    setFit(fitType);
    initEnvironment();
    initializing = false;
  }
}

void alignLeft() {
  align = "LEFT";
  loadMenu(width, height);
  println(align);
}

void alignRight() {
  align = "RIGHT";
  loadMenu(width, height);
  println(align);
}

void alignCenter() {
  align = "CENTER";
  loadMenu(width, height);
  println(align);
}

void invertColors() {
  if (background == 50) {
    background = 255;
    textColor = 50;
  } else {
    background = 50;
    textColor = 255;
  }
  println ("background: " + background + ", textColor: " + textColor);
}

// Returns U-coordinate of mouse over grid
int mouseToU() {
  float dU = (float) gridU / gridWidth;
  return int( (mouseX - dX - mouseBuffer) * dU );
}

// Returns V-coordinate of mouse over grid
int mouseToV() {
  float dV = (float) gridV / gridHeight;
  return int( (mouseY - dY - mouseBuffer) * dV ) ;
}

// Returns True if Valid Grid Coordinate
boolean isGrid(int u, int v) {
  if (u >= 0 && u < gridU && v >= 0 && v < gridV) {
    return true;
  } else {
    return false;
  }
}
