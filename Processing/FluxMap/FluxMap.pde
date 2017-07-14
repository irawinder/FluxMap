/*  Ira Winder, jiw@mit.edu
 *  Creative Commons, July 2017
 *
 *  Feature Scope:
 *  [COMPLETE]   (1) View Empirical Urban Lighting Data (i.e. lux values from a vehicle sensor)
 *  [COMPLETE]   (2) View Empirical Urban Lighting Fixtures (i.e. light poles)
 *  [COMPLETE]   (3) Simulate Lighting Data from Model of Lighting Fixtures
 *  [COMPLETE]   (4) Compare Fit of Model to Observed Data
 *  [INCOMPLETE] (5) Callibrate Lighting Model with Empirical Urban Lighting Data
 */
 
String CREDITS = 
  "Urban Light Sim\n" +
  "MIT - Philips" + "\n\n" +
  "Ira Winder" + "\n" +
  "Nina Lutz" + "\n" + 
  "Neha Prasad" + "\n" + 
  "Anthony Cheng" + "\n" + 
  "Kent Larson" + "\n" +
  "Talmai Oliveira" + "\n";

// Case Study Information
String AREA = "Kendall Square";
String CITY = "Cambridge, MA";

// Library needed for ComponentAdapter()
import java.awt.event.*;

// Environmental Parameters of case study
int GRID_U = 400;
int GRID_V = 400; 
int MIN_RES = 50;  // Visually meaningless beyond this
int MAX_RES = 800; // Empirically, takes too much processing power to do larger grid
float GRID_SIZE = 0.0025; // km
// (Kendall Square)
float LAT = 42.367861; 
float LON = -71.082218;
float AZIMUTH = 0;
//float AZIMUTH = -10.0; // 0 indicates North is Up

// Intermediate Parameters (allows for reset to original values)
int gridU = GRID_U;
int gridV = GRID_V;
float gridSize = GRID_SIZE;
float centerLatitude = LAT;
float centerLongitude = LON;
float nudgeDegree = 0.001; // Amount of degrees to translate when moving canvas w/ arrow keys
float azimuth = AZIMUTH; // 0 indicates North is Up

// Initial Coefficients
float pointLuminance = 2000.0;
float pointHeight = 10.0;
float gaussianLuminance = 800.0;
float gaussianHeight = 10.0;
float gaussianG = 1.5;

// (A) Existing light pole infrastructure: PVector(lat, lon); PVector(u, v)
ArrayList<PVector[]> lightFixture;
String fixtureFile = "lightnodes.csv";
HashMap<String, float[]> lightFixtureHash;

// (B) Lux Value: PVector(lat, lon, lumens); PVector(u, v, lumens)
ArrayList<PVector[]> lightReading;
String[] readingFile = { "LOG1.csv", "LOG2.csv" };
Histogram readingHist;
// Create hashmap of readings for mouse reference
HashMap<String, float[]> lightReadingHash;

// Histogram Intervals
int HIST_INTERVAL = 40;
float HIST_MIN = 0;  //lux
float HIST_MAX = 40; //lux
boolean SKIP_ZERO = true; // Skip values of zero in histogram counts

// Graphics Objects (Rasters)
PImage logo_MIT, logo_PHL;
PImage equations, basemap;

// Class for generating 2D light imulations
LightSim pointModel, gaussianModel;
String modelType = "gaussian"; // Upon Initialization, Model Light as a Simple Point Source
//String modelType = "point"; // Upon Initialization, Model Light as a Simple Point Source
Histogram pointHist, gaussianHist;

boolean initializing = false;

void setup() {
  
  size(1280, 768);
  
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
          initGrid();
        } 
      } 
    }
  );
  
  // Load Images from files ...
    logo_MIT = loadImage("MIT_logo.png");
    logo_PHL = loadImage("PHL_logo.png");
  // Load and Resize Image of Model Equations
  equations = loadImage("equations_transparent.png");
    float ratio = (float) equations.width / equations.height;
    equations.resize( int(ratio*375), 375);
  // Load Satellite Image of Kendall Neighborhood (Generated with Ira's SimpleMapApp)
    basemap = loadImage("basemap.png"); 
  
  // Load Data and Model Structures, values, and precalculations
  initEnvironment();
  initializing = false;
}

void initEnvironment() {
  
  initializing = true;
  
  // Load Empirical Data from File Into Java Objects
  initLightReadings();
  initLightFixtures();
  
  // Initialize Data Reading Histogram
  ArrayList<Float> lR = new ArrayList<Float>();
  for (int i=0; i<lightReading.size(); i++) {
    lR.add(lightReading.get(i)[0].z);
  }
  readingHist = new Histogram(lR, HIST_INTERVAL, "lux", HIST_MIN, HIST_MAX, SKIP_ZERO);
  
  // Initialize Light Model
  pointModel    = new LightSim(pointLuminance, pointHeight);
  gaussianModel = new LightSim(gaussianLuminance, gaussianHeight, gaussianG);
  
  // Calculate lighting solution for table based upon lightpole fixture locations
  pointModel.lightField(lightFixture, "point", pointLuminance, 0);
  gaussianModel.lightField(lightFixture, "gaussian", gaussianLuminance, gaussianG);
  
  // Calculate model fit errors
  pointModel.error(lightReading);
  gaussianModel.error(lightReading);
  
  // pointModel.errorMatrix(lightReading, lightFixture, "point", 3, 1000, 4000, 1, 0, 0);
  
  // Initialize Model Histograms
  ArrayList<Float> pM = new ArrayList<Float>();
  ArrayList<Float> gM = new ArrayList<Float>();
  for (int u=0; u<gridU; u++) {
    for (int v=0; v<gridV; v++) {
      pM.add(pointModel.light[u][v]);
      gM.add(gaussianModel.light[u][v]);
    }
  }
  pointHist = new Histogram(pM, HIST_INTERVAL, "lux", HIST_MIN, HIST_MAX, SKIP_ZERO);
  gaussianHist = new Histogram(gM, HIST_INTERVAL, "lux", HIST_MIN, HIST_MAX, SKIP_ZERO);
  
  // Set up Grid Display Parameters
  initGrid();
}

void initGrid() {
  
  // Pixel/Canvas Parameters
  float gridRatio = float(gridU) / gridV;
  float screenRatio = float(width) / height;
  if (gridRatio > screenRatio) {
    gridWidth = (1.0 - buffer) * width;
    gridHeight = gridWidth / gridRatio;
    cellWidth = gridWidth / gridU;
  } else {
    gridHeight = (1.0 - buffer) * height;
    gridWidth = gridHeight * gridRatio;
    cellWidth = gridHeight / gridV;
  }
}
