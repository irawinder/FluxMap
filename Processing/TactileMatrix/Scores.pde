// Arrays that hold disaggregated KPIs as pixel heatmaps
// Values are 0.0 - 1.0
// Value of -1 reserved for null
float[][] safety, light;
float avgSafety, avgLight;

// Array of booleans that describe whether a square is a street square or not
boolean[][] street;

// Max brightness of light at "source"
float LIGHT_MAG = 1.0;

// Ideal Brightness for ideal safety conditions
float IDEAL_MAG  = 0.5;

// Height of the lampposts
float LAMP_HEIGHT = 7.6; //Originally 7.6 m; --> need to figure out how to convert to "pixels"  

// locations of street squares
int ST1_U = 7;  // Top Left U
int ST1_V = 5;  // Top Left V
int ST1_W = 3;  // Width
int ST1_H = 13; // Height

int ST2_U = 3;  // Top Left U
int ST2_V = 9;  // Top Left V
int ST2_W = 11; // Width
int ST2_H = 5;  // Height

void setupScores() {
  // Array of booleans that describe whether a square is a street square or not
  street = new boolean[U_MAX][V_MAX];
  
  // Arrays that hold disaggregated KPIs
  // Values are 0.0 - 1.0
  // Value of -1 reserved for null
  light = new float[U_MAX][V_MAX];
  safety = new float[U_MAX][V_MAX];
  
  // Determines which grid square are part of the street for analysis
  for (int u=0; u<U_MAX; u++) {
    for (int v=0; v<V_MAX; v++) {
      
      // Test for Street 1 or 2
      if ( (u >= ST1_U && u < ST1_U + ST1_W && v >= ST1_V && v < ST1_V + ST1_H ) ||
           (u >= ST2_U && u < ST2_U + ST2_W && v >= ST2_V && v < ST2_V + ST2_H ) ) {
        
        street[u][v] = true;
        
      } else {
        street[u][v] = false;
      }
      
      // Null Initialization
      light[u][v] = -1;
      safety[u][v] = -1;
    }
  }
  
  // Calculate lighting solution for table based upon lightpole location
  lightField(tablePieceInput);
  
  // Calculate safety solution based upon lightField solution
  safetyField();
}

// Calculates lighting value
void lightField(int[][][] pieces) {
  
  // Clear Field
  for (int u=0; u<light.length; u++) {
    for (int v=0; v<light[0].length; v++) {
      if (street[u][v]) { // Only Updates Street Squares
        light[u][v] = 0;
      }
    }
  }
  
  for (int u=0; u<light.length; u++) {
    for (int v=0; v<light[0].length; v++) {
      
      // Check that u,v position is not on toggle buttons
      boolean input0 = ( u == matrix.input0_X-4 && v == matrix.input0_Y );
      boolean input1 = ( u == matrix.input1_X-4 && v == matrix.input1_Y );
      if (!input0 && !input1) {
        
        // Checks if a piece is present
        if (pieces[u][v][0] >= 0) {
          
          for (int x=0; x<light.length; x++) {
            for (int y=0; y<light[0].length; y++) {
              if (street[x][y]) { // Only Updates Street Squares
              
                float dist = sqrt( sq(u-x) + sq(v-y)); 
                //float dist = sqrt( sq(u-x) + sq(v-y) + sq(LAMP_HEIGHT));
                float theta = acos(LAMP_HEIGHT/dist);
                if (dist > 0) {
                  // Fuction that Describes light "fall-off" curve
                  light[x][y] += LIGHT_MAG / pow(1.5*dist, 1.8); //Ira's simple model
                } else {
                  light[x][y] += LIGHT_MAG;
                }
                
              }
            }
          }
          
        }
        
      }
      
    }
  }
  
  // Limit Light's Maximum brightness
  for (int u=0; u<light.length; u++) {
    for (int v=0; v<light[0].length; v++) {
      if (street[u][v]) { // Only Updates Street Squares
        light[u][v] = min(LIGHT_MAG, light[u][v]);
      }
    }
  }
  
  // Aggregate Heatmap Values
  avgLight = averageScore(light);
}

// Calculates Deviance of lighting value from ideal for safety
void safetyField() {
  for (int u=0; u<light.length; u++) {
    for (int v=0; v<light[0].length; v++) {
      if (street[u][v]) { // Only Updates Street Squares
        safety[u][v] = 1.0 - 2 * abs(light[u][v] - IDEAL_MAG);
      }
    }
  }
  // Aggregate Heatmap Values
  avgSafety = averageScore(safety);
}

// Calculates the average value of scorable grid squares
float averageScore(float[][] score) {
  float sum = 0;
  int num = 0;
  for (int u=0; u<score.length; u++) {
    for (int v=0; v<score[0].length; v++) {
      
      if (street[u][v]) { // Only Updates Street Squares
        sum += score[u][v];
        num ++;
      }
      
    }
  }
  return sum / num;
}
