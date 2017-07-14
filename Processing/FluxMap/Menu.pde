/* Class: Button() and Menu()
 *
 * Nina Lutz (nlutz@gmail.com)
 * Ira Winder (jiw@mit.edu)
 * Last Update: July, 2017
 */

class Button{
  // variables describing upper left corner of button, width, and height in pixels
  int x,y,w,h;
  // String of the Button Text
  String label, key_code;
  // Various Shades of button states (0-255)
  int hover = 255;
  int pressed = 100; 
  int standby = 50;
  int shadow = 0;
  int off = 25;
  
  boolean isPressed = false;
  boolean isVoid = false;
  boolean active = true;
  
  //Button Constructor
  Button(int x, int y, int w, int h, String label, String key_code){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.key_code = key_code;
  }
  
  //Button Objects are draw to a PGraphics object rather than directly to canvas
  void draw(PGraphics p){
    if (!isVoid) {
      p.noStroke();
      int gap = 0;
      
      if (active) {
        
        if (isPressed || ( over() && mousePressed) ){
          p.fill(pressed);
          p.rect(x, y, w, h, 5);
        } else {
          gap = 2;
          p.fill(shadow);
          p.rect(x, y, w, h, 5);
          p.fill(standby);
          p.rect(x-gap, y-gap, w, h, 5);
        }
        
        if( over() ) {  // Encircles button if hovering mouse over it
          p.noFill(); p.stroke(hover, 100); p.strokeWeight(1);
          p.rect(x - gap, y - gap, w, h, 5);
        } 
        
        p.fill(255);
        p.textSize(12);
        
      } else { // Button Is not Enabled
        p.fill(off);
        p.rect(x, y, w, h, 5);
        
        p.fill(255, 150);
        p.textSize(12);
      }
      
      // Button Text
      p.textAlign(LEFT);
      p.text(label, x + 10, y + 0.6*h);
      p.textAlign(RIGHT);
      p.text("[" + key_code + "]", x + w - 10, y + 0.6*h); 
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
  // Button Name Array Associated with Menu [0] = long form [1] = abbreviated form
  String[][] names;
  // Menu Alignment
  String align;
  // variables describing canvasWidth, canvas Height, Button Width, Button Height, Verticle Displacement (#buttons down)
  int w, h, x, y, vOffset;
  
  //Constructor
  Menu(int w, int h, int x, int y, int vOffset, String[][] names, String align){
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
        buttons[i] = new Button(this.w - this.x - marginW, marginH + this.vOffset*(this.y+5) + i*(this.y+5), this.x, this.y, this.names[i][0], this.names[i][1]);
      } else if ( this.align.equals("left") || this.align.equals("LEFT") ) { 
        // Left Align
        buttons[i] = new Button(marginW, marginH + this.vOffset*(this.y+5) + i*(this.y+5), this.x, this.y, names[i][0], this.names[i][1]);
      } else if ( this.align.equals("center") || this.align.equals("CENTER") ) { 
        // Center Align
        buttons[i] = new Button( (this.w-this.x)/2, marginH + this.vOffset*(this.y+5) + i*(this.y+5), this.x, this.y, this.names[i][0], this.names[i][1]);
      }
      
      // Alows a menu button spacer to be added by setting its string value to "VOID"
      if (this.names[i][0].equals("void") || this.names[i][0].equals("VOID") ) {
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

HashMap<String, Integer> hashButtons(String[][] bNames) {
  HashMap<String, Integer> bH = new HashMap<String, Integer>();
  String buttonKey;
  int buttonIndex;
  for (int i=0; i<bNames.length; i++) {
    buttonKey = bNames[i][1];
    buttonIndex = i;
    bH.put(buttonKey, buttonIndex);
  }
  return bH;
}
