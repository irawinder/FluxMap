/* Class: LightSim()
 * Calculates a Light Field in a gridded coordinate system.
 *
 * Nina Lutz (nlutz@gmail.com)
 * Ira Winder (jiw@mit.edu)
 * Last Update: July, 2017
 *  
 * Lit Review:
 *
 * Modeling LED street lighting
 * Ivan Moreno, Maximino Avendaño-Alejo, Tonatiuh Saucedo-A, and Alejandra Bugarin1
 * Unidad Academica de Fisica, Universidad Autónoma de Zacatecas, 98060 Zacatecas, Mexico
 * Universidad Nacional Autónoma de México, Centro de Ciencias Aplicadas y Desarrollo Tecnológico,
 * C. P. 04510, Distrito Federal, Mexico
 * Corresponding author: imoreno@fisica.uaz.edu.mx
 * Received 17 March 2014; accepted 7 May 2014;
 * Applied Optics, posted 2 June 2014 (Doc. ID 208353); published 3 July 2014
 */
  
class LightSim{
  // Arrays that hold light simulation as "raster" pixel map
  // Value of -1 reserved for null
  float[][] light;
  float avgLight;
  
  // Luminance of light at "source"
  float luminance; // lumens
  
  // Height of Lamp Fixture
  float h; // meters
  
  // A Coefficient that describes variable Luminance for gaussian LED lamps
  float g;
  
  // Max Distance a Fixture will have any feasible effect
  float MAX_DIST = 75.0; // meters
  
  ArrayList<float[][]> errorArray;
  ArrayList<PVector> error;
  
  LightSim(float luminance, float h) {
    init(luminance, h);
  }
  
  LightSim(float luminance, float h, float g) {
    init(luminance, h);
    this.g = g;
  }
  
  void init(float luminance, float h) {
    this.luminance = luminance;
    this.h = h;
    g = 0;
    
    // Arrays that hold disaggregated KPIs
    // Values are 0.0 - 1.0
    // Value of -1 reserved for null
    light = new float[gridU][gridV];
    clearField();
  }
  
  void clearField() {
    for (int u=0; u<light.length; u++) {
      for (int v=0; v<light[0].length; v++) {
        light[u][v] = 0;
      }
    }
  }
  
  // Calculates lighting value
  void lightField(ArrayList<PVector[]> f, String type, float L, float G) {
    
    float dist;
    
    // Clear Field
    clearField();
    
    // Max Distance a Fixture will have any feasible effect (convert to grid units)
    int lD = int(MAX_DIST / (1000.0*gridSize));
    
    // Loop through Fixtures
    for (int i=0; i<f.size(); i++) {
      // u,v coordinate of light fixture 
      int u = int(f.get(i)[1].x);
      int v = int(f.get(i)[1].y);
      // loop through solution grid
      for (int x=u-lD; x<u+lD; x++) {
        for (int y=v-lD; y<v+lD; y++) {
          
          if (x >= 0 && x < gridU && y >=0 && y < gridV) {
            
            
            // distance from lamp pole along ground
            dist = sqrt( sq(1000.0*gridSize) * (sq(u-x) + sq(v-y)) );
            
            // Fuction that Describes light "fall-off" curve
            if ( type.equals("point") ) {
              light[x][y] += simpleFlux(dist, h, L);
            } else if ( type.equals("gaussian") ) {
              light[x][y] += gaussianFlux(dist, h, L, G, 0);
            }
            
          }
          
        }
      }
    }
    // Aggregate Heatmap Values
    avgLight = averageScore(light);
    
    println("Light Model Calculated with " + f.size() + " fixtures.\nAverage Light Value: " + String.format("%.02f", avgLight) + " lux\n---");
  }
  
  /*
    Example Model Coefficients
    Lamp Height, H, 10 [meter]
    Luminance, L, 400, [lumen]
    lumMax, g1, 800, [lumen]
    lumMin, g2, 400, [lumen]
    Range, g3, 1.5, [none]
    Tilt, g4, 0, [none]
    Distance, D, sqrt( x^2 + y^2 + H^2)
  */
  
  // Model Light as a Simple Point Source
  float simpleFlux(float d, float H, float L ) {
    float D = sqrt( sq(d) + sq(H) );
    return L * H / pow(D, 3);
  }

  // Model Light Fixture with variable Luminance depending on angle of incidence
  float gaussianFlux(float d, float H, float L, float g3, float g4) {
    float g2 = L;
    float g1 = 2*L;
    float D = sqrt( sq(d) + sq(H) );
    float T = acos(H/D);
    float I = g1 - g2 * exp(-g3*sq(g4-T));
    return I * H / pow(D, 3);
  }
  
  // Calculates the average value of scorable grid squares
  float averageScore(float[][] score) {
    float sum = 0;
    int num = 0;
    for (int u=0; u<score.length; u++) {
      for (int v=0; v<score[0].length; v++) {
          sum += score[u][v];
          num ++;
      }
    }
    return sum / num;
  }
  
  // Compute the error of the current model from available readings, 'r'
  void error(ArrayList<PVector[]> r) {
    int u, v;
    float observed, model;
    PVector e;
    error = new ArrayList<PVector>();
    
    // Calculate difference of of reading from all permutations of coefficient combinations
    for (int i=0; i<r.size(); i++) {
      u = (int) r.get(i)[1].x;
      v = (int) r.get(i)[1].y;
      if (u >=0 && u < gridU && v >=0 && v < gridV) { 
        observed = r.get(i)[0].z;
        model = light[u][v];
        e = new PVector(u, v, model - observed);
        error.add(e);
      }
    }
  }
  
  /*
  
  // [Ira Note: errorMatrix() method needs a lot of work to make functional] 
  // An error matrix structed by the variations of 2 parameters (A and B) 
  // at regular intervals between min and max values for given model 'type' with fixtures 'f' and observed readings 'r'
  void errorMatrix(ArrayList<PVector[]> r, ArrayList<PVector[]> f, String type, int numL, float minL, float maxL, int numG, float minG, float maxG) {
    
    int u, v;
    float observed, model;
    float lCurrent, gCurrent, dist;
    float dL = ( maxL - minL ) / numL;
    float dG = ( maxG - minG ) / numG;
    
    float[][] errorMatrix;
    errorArray = new ArrayList<float[][]>();
    
    // Calculate difference of of reading from all permutations of coefficient combinations
    for (int i=0; i<100; i++) {
      int random = int(random(f.size()-1));
      u = (int) f.get(random)[1].x;
      v = (int) f.get(random)[1].y;
      if (u >=0 && u < gridU && v >=0 && v < gridV) { 
        
        observed = f.get(random)[0].z;
        errorMatrix = new float[numL][numG];
        
        for (int l=0; l<numL; l++) {
          lCurrent = minL + dL*l;
          for (int g=0; g<numG; g++) {
            gCurrent = minG + dG*g;
            lightField(f, type, lCurrent, gCurrent);
            model = light[u][v];
            errorMatrix[l][g] = model - observed;
          }
        }
        errorArray.add(errorMatrix);
      }
    }
  }
  
  */
  
}
