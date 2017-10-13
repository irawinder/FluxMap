// The following scripts enable User Interface elements such as buttons, key presses, and mouse clicks

void key_h() {
  // "Hide Main Menu"
  toggleMainMenu();
}

void key_r() {
  // randomize sample piece input
  matrix.fauxPieces(3, tablePieceInput, 15);
}

void key_R() {
  // randomize sample piece input
  matrix.fauxPieces(2, tablePieceInput, 15);
}

void key_TILDE() {
  //  "Enable Projection (`)"
  toggle2DProjection();
}

void key_l() {
  // toggle light score
  showLight = !showLight;
  if (showLight) {
    tablePieceInput[1][19][0] = 1;
  } else {
    tablePieceInput[1][19][0] = -1;
  }
}

void key_s() {
  // toggle safety score
  showSafety = !showSafety;
  if (showSafety) {
    tablePieceInput[1][20][0] = 0;
  } else {
    tablePieceInput[1][20][0] = -1;
  }
}

//void key_i() {
//  // "Invert Colors"
//  invertColors();
//}

void keyPressed() {
  switch(key) {
    case 'h': 
      key_h();
      break;
    case 'r': 
      key_r();
      break;
    case 'R': 
      key_R();
      break;
    case 's': 
      key_s();
      break;
    case 'l': 
      key_l();
      break;
    case '`': 
      key_TILDE();
      break;
  }
  
  // Updates draw() upon key press
  decodePieces();
  loop();
}

// Refreshes when there's a mouse mouse movement
void mouseMoved() {
  loop();
}

// Class that holds a button menu
Menu mainMenu, hideMenu;

// Global Text and Background Color
int textColor = 255;
int background = 50;
int BUTTON_OFFSET_H = 40;
int BUTTON_OFFSET_W = 50;

// Menu Alignment on Screen
String align = "LEFT";

// Set this to true to display the main menue upon start
boolean showMainMenu = true;

// Define how many buttons are in the Main Menu and 
// what they are named by editing this String array:
String[] buttonNames = 
{
  "Load Random Input (r)",  // 0
  "Clear Input (SH+R)",  // 1
  "VOID",  // 2
  "Light Overlay (l)",  // 3
  "Safety Overlay (s)",  // 4
  "VOID",  // 5
  "Project Table (`)", //6
  "VOID",  // 7
  "VOID",  // 8
  "VOID",  // 9
  "VOID",  // 10
  "VOID",  // 11
  "VOID",  // 12
  "VOID",    // 13
  "VOID",  // 14
  "VOID",  // 15
  "VOID",  // 16
  "VOID",  // 17
  "VOID",  // 18
  "VOID"   // 19
  
};

// These Strings are for the hideMenu, formatted as arrays for Menu Class Constructor
String[] hide = {"Hide Main Menu (h)"};
String[] show = {"Show Main Menu (h)"};

// The result of each button click is defined here
void mousePressed() {
  
  // Hide/Show Menu
  if(hideMenu.buttons[0].over()){  
    toggleMainMenu();
  }
  
  // Main Menu Buttons:
  
  if(mainMenu.buttons[0].over()){ 
    key_r();
  }
  
  if(mainMenu.buttons[1].over()){ 
    key_R();
  }
  
  if(mainMenu.buttons[2].over()){ 
    // NA
  }
  
  if(mainMenu.buttons[3].over()){ 
    key_l();
  }
  
  if(mainMenu.buttons[4].over()){ 
    key_s();
  }
  
  if(mainMenu.buttons[5].over()){ 
    // NA
  }
  
  if(mainMenu.buttons[6].over()){ 
    key_TILDE();
  }
  
  if(mainMenu.buttons[7].over()){ 
    // NA
  }
  
  if(mainMenu.buttons[8].over()){ 
    // NA
  }
  
  if(mainMenu.buttons[9].over()){ 
    // NA
  }
  
  if(mainMenu.buttons[0].over()){ 
    // NA
  }
  
  if(mainMenu.buttons[11].over()){ 
    // NA
  }
  
  if(mainMenu.buttons[12].over()){ 
    // NA
  }
  
  if(mainMenu.buttons[13].over()){ 
    // NA
  }
  
  if(mainMenu.buttons[14].over()){ 
    // NA
  }
  
  if(mainMenu.buttons[15].over()){ 
    // NA
  }
  
  if(mainMenu.buttons[16].over()){ 
    // NA
  }
  
  if(mainMenu.buttons[17].over()){ 
    // NA
  }
  
  if(mainMenu.buttons[18].over()){ 
    // NA
  }
  
  if(mainMenu.buttons[19].over()){ 
    // NA
  }
  
  if (matrix.mouseInGrid()) {
    matrix.addMousePiece(0);
    decodePieces();
  }
  
  loop();
}

void loadMenu(int canvasWidth, int canvasHeight) {
  // Initializes Menu Items (canvas width, canvas height, button width[pix], button height[pix], 
  // number of buttons to offset downward, String[] names of buttons)
  String[] hideText;
  if (showMainMenu) {
    hideText = hide;
  } else {
    hideText = show;
  }
  hideMenu = new Menu(canvasWidth, canvasHeight, max(int(width*.13), 160), 25, 0, hideText, align);
  mainMenu = new Menu(canvasWidth, canvasHeight, max(int(width*.13), 160), 25, 2, buttonNames, align);
}

void toggleMainMenu() {
  showMainMenu = !showMainMenu;
  if (showMainMenu) {
    hideMenu.buttons[0].label = hide[0];
  } else {
    hideMenu.buttons[0].label = show[0];
  }
  println("showMainMenu = " + showMainMenu);
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

class Button{
  // variables describing upper left corner of button, width, and height in pixels
  int x,y,w,h;
  // String of the Button Text
  String label;
  // Various Shades of button states (0-255)
  int hover = 140;
  int pressed = 180; 
  int standby = 120;
  
  boolean isPressed = false;
  boolean isVoid = false;
  
  //Button Constructor
  Button(int x, int y, int w, int h, String label){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
  }
  
  //Button Objects are draw to a PGraphics object rather than directly to canvas
  void draw(PGraphics p){
    if (!isVoid) {
      p.noStroke();
      int gap = 3;
      if( over() ) {  // Darkens button if hovering mouse over it
        p.fill(hover, 100);
        p.rect(x, y, w, h, 5);
        if (!isPressed && !mousePressed) {
          p.fill(hover);
          p.rect(x-gap, y-gap, w, h, 5);
        }
      } else if (isPressed){
        p.fill(pressed, 100);
        p.rect(x, y, w, h, 5);
      } else {
        p.fill(100, 100);
        p.rect(x, y, w, h, 5);
        p.fill(standby);
        p.rect(x-gap, y-gap, w, h, 5);
      }
      
      p.fill(255);
      p.textSize(12);
      p.textAlign(CENTER);
      p.text(label, x + (w/2), y + 0.6*h); 
    }
  } 
  
  // returns true if mouse hovers in button region
  boolean over(){
    if(mouseX >= x  && mouseY >= y + 5 && mouseX <= x + w && mouseY <= y + 2 + h){
      return true;
    } else {
      return false;
    }
  }
}

class Menu{
  // Button Array Associated with this Menu
  Button[] buttons;
  // Graphics Object to Draw this Menu
  PGraphics canvas;
  // Button Name Array Associated with Menu
  String[] names;
  // Menu Alignment
  String align;
  // variables describing canvasWidth, canvas Height, Button Width, Button Height, Verticle Displacement (#buttons down)
  int w, h, x, y, vOffset;
  
  //Constructor
  Menu(int w, int h, int x, int y, int vOffset, String[] names, String align){
    this.names = names;
    this.w = w;
    this.h = h;
    this.vOffset = vOffset;
    this.align = align;
    this.x = x;
    this.y = y;
    
    // distance in pixels from corner of screen
    int marginH = BUTTON_OFFSET_H;
    int marginW = BUTTON_OFFSET_W;
    
    canvas = createGraphics(w, h);
    // #Buttons defined by Name String Array Length
    buttons = new Button[this.names.length];
    
    // Initializes the button objects
    for (int i=0; i<buttons.length; i++) {
      if ( this.align.equals("right") || this.align.equals("RIGHT") ) {
        // Right Align
        buttons[i] = new Button(this.w - this.x - marginW, marginH + this.vOffset*(this.y+5) + i*(this.y+5), this.x, this.y, this.names[i]);
      } else if ( this.align.equals("left") || this.align.equals("LEFT") ) { 
        // Left Align
        buttons[i] = new Button(marginW, marginH + this.vOffset*(this.y+5) + i*(this.y+5), this.x, this.y, names[i]);
      } else if ( this.align.equals("center") || this.align.equals("CENTER") ) { 
        // Center Align
        buttons[i] = new Button( (this.w-this.x)/2, marginH + this.vOffset*(this.y+5) + i*(this.y+5), this.x, this.y, this.names[i]);
      }
      
      // Alows a menu button spacer to be added by setting its string value to "VOID"
      if (this.names[i].equals("void") || this.names[i].equals("VOID") ) {
        buttons[i].isVoid = true;
      }
    }
  }
  
  // Draws the Menu to its own PGraphics canvas
  void draw() {
    canvas.beginDraw();
    canvas.clear();
    for (int i=0; i<buttons.length; i++) {
      buttons[i].draw(canvas);
    }
    canvas.endDraw();
    
    image(canvas, 0, 0);
  }
}
