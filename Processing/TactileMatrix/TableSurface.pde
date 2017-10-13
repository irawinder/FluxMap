// The following scripts Allow for the Display and Manipulation of a Tactile Matrix Grid

TableSurface matrix;
boolean showSafety = false;
boolean showLight = false;

/*      ---------------> + U-Axis
 *     |
 *     |
 *     |
 *     |
 *     |
 *     |
 *   + V-Axis
 *
 */

void setupTable() {
  offscreen = createGraphics(projectorHeight, projectorHeight);
  // TableSurface(int u, int v, boolean left_margin)
  matrix = new TableSurface(projectorHeight, projectorHeight, V_MAX, V_MAX, true);
}

void drawTable() {

  // Draw the scene, offscreen
  matrix.draw(offscreen);

  if (testProjectorOnScreen) {
    stroke(0);
    strokeWeight(1);
    fill(255, 100);
    
    int screenFit = int(0.8*height);
    float boarderFit = 1.0625;
    
    rect( (width - boarderFit*screenFit) / 2, (height - boarderFit*screenFit) / 2, boarderFit*screenFit, boarderFit*screenFit, 10);
    image(offscreen, (width - screenFit) / 2, (height - screenFit) / 2, screenFit, screenFit);
    
    matrix.mouseToGrid((width - screenFit) / 2, (height - screenFit) / 2, screenFit, screenFit);
  }
}

class TableSurface {

  int U, V;
  float cellW, cellH;
  boolean LEFT_MARGIN;
  int MARGIN_W = 4;  // Left Margin for Grid (in Lego Squares)
  int gridMouseU, gridMouseV;
  
  // Toggle Locations
  int input0_X = 5;
  int input0_Y = 20;
  int input1_X = 5;
  int input1_Y = 19;
  
  TableSurface(int W, int H, int U, int V, boolean left_margin) {
    this.U = U;
    this.V = V;
    LEFT_MARGIN = left_margin;
    
    cellW = float(W)/U;
    cellH = float(H)/V;   
    
    gridMouseU = -1;
    gridMouseV = -1;
  }
  
  // Converts screen-based mouse coordinates to table grid position represented on screen during "Screen Mode"
  PVector mouseToGrid(int mouseX_0, int mouseY_0, int mouseW, int mouseH) {
    PVector grid = new PVector();
    boolean valid = true;
    
    grid.x = float(mouseX - mouseX_0) / mouseW * U;
    grid.y = float(mouseY - mouseY_0) / mouseH * V;
    
    if (grid.x >=MARGIN_W && grid.x < U) {
      gridMouseU = int(grid.x);
    } else {
      valid = false;
    }
    
    if (grid.y >=0 && grid.y < V) {
      gridMouseV = int(grid.y);
    } else {
      valid = false;
    }
    
    if (!valid) {
      gridMouseU = -1;
      gridMouseV = -1;
    }
    
    return grid;
  }
  
  boolean mouseInGrid() {
    if (gridMouseU == -1 || gridMouseV == -1) {
      return false;
    } else {
      return true;
    }
  }
  
  // add/remove a particular ID to a particular square
  void addMousePiece(int ID) {
    if (tablePieceInput[gridMouseU - MARGIN_W][gridMouseV][0] == -1) {
      tablePieceInput[gridMouseU - MARGIN_W][gridMouseV][0] = ID;
    } else {
      tablePieceInput[gridMouseU - MARGIN_W][gridMouseV][0] = -1;
    }
  }
  
  // Generate Random Pieces, in case Colortizer is not available
  void fauxPieces(int code, int[][][] pieces, int maxID) {
    if (code == 2 ) {
      
      // Sets all grids to have "no object" (-1) with no rotation (0)
      for (int i=0; i<pieces.length; i++) {
        for (int j=0; j<pieces[0].length; j++) {
          pieces[i][j][0] = -1;
          pieces[i][j][1] = 0;
        }
      }
    } else if (code == 1 ) {
      
      // Sets grids to be alternating one of each N piece types (0-N) with no rotation (0)
      for (int i=0; i<pieces.length; i++) {
        for (int j=0; j<pieces[0].length; j++) {
          pieces[i][j][0] = i  % maxID+1;
          pieces[i][j][1] = 0;
        }
      }
    } else if (code == 0 ) {
      
      // Sets grids to be random piece types (0-N) with random rotation (0-3)
      for (int i=0; i<pieces.length; i++) {
        for (int j=0; j<pieces[0].length; j++) {
          if (random(0, 1) > 0.5) {
            pieces[i][j][0] = int(random(-1.99, maxID+1));
            pieces[i][j][1] = int(random(0, 4));
          } else { // 95% of pieces are blank
            pieces[i][j][0] = -1;
            pieces[i][j][1] = 0;
          }
        }
      }
    } else if (code == 3) {
      
      // Adds N random pieces to existing configuration
      for (int i=0; i<50; i++) {
        int u = int(random(0,pieces.length)); 
        int v = int(random(0,pieces[0].length)); 
        if (pieces[u][v][0] == -1) {
          pieces[u][v][0] = int(random(-1.99, maxID+1));
          pieces[u][v][1] = int(random(0, 4));
        }
      }
    } 
  }
  
  void draw(PGraphics p) {
    int buffer = 30;
    
    p.beginDraw();
    //p.background(50);
    p.background(0);
    
    // Draw Street Intersection Background
    p.image(intersection, 0, 0, p.width, p.height);

    // Cycle through each table grid, skipping margin
    for (int u=0; u<U; u++) {
      for (int v=0; v<V; v++) {
        if (!LEFT_MARGIN || (LEFT_MARGIN && u >= MARGIN_W) ) {
          
          // Score Overlays
          if (street[u - MARGIN_W][v]) {
            
            textAlign(CENTER);
            
            if (showLight) {
              float gradient = textColor * light[u - MARGIN_W][v] / LIGHT_MAG;
  
              p.fill(#FFF68E, gradient);
              p.noStroke();
              p.rect(u*cellW, v*cellH, cellW, cellH);
              
              p.fill(0);
              p.text(("" + int(100*light[u - MARGIN_W][v]) ), (u + 0.8)*cellW, (v + 0.6)*cellH);
            } 
            
            if (showSafety) {
              float gradient = textColor / 3.0 * safety[u - MARGIN_W][v];            
              
              p.colorMode(HSB);
              p.fill(gradient, 255, 255, 150);
              p.colorMode(RGB);
              p.noStroke();
              p.rect(u*cellW, v*cellH, cellW, cellH);
              
              p.fill(0);
              p.text(("" + int(100*safety[u - MARGIN_W][v]) ), (u + 0.8)*cellW, (v + 0.6)*cellH);
            }
            
            textAlign(LEFT);
            
          }
          
          // Draw Colortizer Input Pieces
          if (tablePieceInput[u - MARGIN_W][v][0] >=0 && tablePieceInput[u - MARGIN_W][v][0] < ID_MAX) {
            
            // Draw A "Light Source"
            p.fill(#FFCC00);
            p.noStroke();
            p.ellipse(u*cellW + 0.5*cellW, v*cellH + 0.5*cellW, 0.5*cellW, 0.5*cellH);
            
          }
          
          // Draw black edges where Lego grid gaps are
          p.noFill();
          p.stroke(0);
          p.strokeWeight(3);
          p.rect(u*cellW, v*cellH, cellW, cellH);
        }
      }
    }
          
    // Draw Black Edge around 4x22 left margin area
    if (LEFT_MARGIN) {
      p.fill(0);
      p.rect(0, 0, MARGIN_W*cellW, p.height);
    }
    
    // Draw Aggregate Brigtness Score
    if (showLight) {
      p.fill(50);
      p.rect(10, (V-10)*cellH, MARGIN_W*cellW - 20, 3*cellH, 5);
    }
    p.textAlign(LEFT);
    p.textSize(15);
    p.fill(255);
    p.text("Lighting\nIntensity", 20, (V-9.3)*cellH + 10);
    p.colorMode(HSB);
    p.fill(255 / 3.0 * avgLight, 255, 255);
    p.colorMode(RGB);
    p.textSize(20);
    p.text(int(100*avgLight) + "%", 20, (V-9.3)*cellH + 60);
    
    // Draw Aggregate Safety Score
    if (showSafety) {
      p.fill(50);
      p.rect(10, (V-7)*cellH, MARGIN_W*cellW - 20, 3*cellH, 5);
    }
    p.fill(255);
    p.noStroke();
    p.textAlign(LEFT);
    p.textSize(15);
    p.text("Intersection\nSafety", 20, (V-6.3)*cellH + 10);
    p.colorMode(HSB);
    p.fill(255 / 3.0 * avgSafety, 255, 255);
    p.colorMode(RGB);
    p.textSize(20);
    p.text(int(100*avgSafety) + "%", 20, (V-6.3)*cellH + 60);
    
    // Draw Interface for Toggling Score
    p.textSize(15);
    p.textAlign(RIGHT);
    p.fill(255);
    p.text("Light", 3.75*cellW, (V-2.75)*cellH + 10);
    p.text("Safety", 3.75*cellW, (V-1.5)*cellH + 10);
    
    p.fill(#0b5ed8);
    p.rect(4*cellW, (V-4)*cellH, 3*cellW, 4*cellH, 20);
    p.fill(0);
    p.rect(5*cellW + 2, (V-3)*cellH + 2, cellW - 4, cellH - 4);
    p.rect(5*cellW + 2, (V-2)*cellH + 2, cellW - 4, cellH - 4);
    
    // Light Table Button
    if (tablePieceInput[input0_X-MARGIN_W][input0_Y][0] >=0) {
      p.fill(255);
      p.rect(input0_X*cellW + 2, input0_Y*cellH + 2, cellW - 4, cellH - 4);
    } 
    
    // Safety Table Button
    if (tablePieceInput[input1_X-MARGIN_W][input1_Y][0] >=0) {
      p.fill(255);
      p.rect(input1_X*cellW + 2, input1_Y*cellH + 2, cellW - 4, cellH - 4);
    } 
    
    // Draw Mouse-based Cursor for Grid Selection
    if (gridMouseU != -1 && gridMouseV != -1) {
      p.fill(255, 150);
      p.rect(gridMouseU*cellW, gridMouseV*cellH, cellW, cellH);
    }
    
    // Draw logo_PHL, logo_MIT
    p.image(logo_PHL, 0.5*buffer, 0.87*p.height + 1.0*buffer, 1.50*buffer, 2.0*buffer); 
    p.image(logo_MIT, 0.5*buffer, 0.87*p.height - 0.2*buffer, 1.55*buffer, 0.7*buffer); 

    //drawBuilds(p);

    p.endDraw();
  }
}
