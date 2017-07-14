// Main Tab for Importing and CLeaning Data from files

 // Library that Include Hashtable Utility
import java.util.*;

//Fraction of grid extents to bleed data offscreen
float margin = 0.1;

void initLightReadings() {
  
  lightReading = new ArrayList<PVector[]>();
  
  // Data Handler(s) for Importing light Readings
  Table reading1, reading2;
  
  //Lighting Data from Philips (Talmai Oliviera)
  reading1 = loadTable(readingFile[0], "header");
  reading2 = loadTable(readingFile[1], "header");
  println("Light Readings imported from " + readingFile[0] + " and " + readingFile[1]);
  
  //Extract lat-lon values and associated lux values 
  
  // Adds Readings 1 to ArrayList
  for (int i = 0; i < reading1.getRowCount (); i++) {

    // For Readings 1 Only, take the first two digits (degrees),
    // then divide the rest (minutes) by 60 and add.
      String lat = reading1.getString(i, "lat1");
      String lon = reading1.getString(i, "lon1");
  
      int latM = int(lat.substring(0, 2));
      int lonM = int(lon.substring(0, 2)) * -1;
  
      float latS = latM + float(lat.substring(2, lat.length()))/60;
      float lonS = lonM - float(lon.substring(2, lon.length()))/60;
    
    // Lat, Lon Vector
    PVector coord = new PVector(latS, lonS);
    // Grid (u, v) Vector
    int[] uv = LatLontoGrid(coord.x, coord.y, centerLatitude, centerLongitude, azimuth, gridSize, gridU, gridV);
    // Luminence Value
    float luminance = reading1.getFloat(i, "lux1");
    
    // Checks to see if data point is within extents
    if (uv[0] > -margin*gridU && uv[0] < gridU * (1 + margin) && 
        uv[1] > -margin*gridV && uv[1] < gridV * (1 + margin) ) {
      
      // Log each data point in two coordinate Systems, (1) Lat,Lon and (2) u,v
      PVector[] reading = new PVector[2];
      reading[0] = new PVector(coord.x, coord.y, luminance);
      reading[1] = new PVector(uv[0], uv[1], luminance);
      lightReading.add(reading);
      
    }
    
  }

  // Adds Readings 2 to ArrayList
  for (int j = 0; j < reading2.getRowCount (); j++) {
    // Lat, Lon Vector
    PVector coord2 = new PVector(reading2.getFloat(j, "lat2"), reading2.getFloat(j, "lon2"));
    // Grid (u, v) Vector
    int[] uv = LatLontoGrid(coord2.x, coord2.y, centerLatitude, centerLongitude, azimuth, gridSize, gridU, gridV);
    // Luminence Value
    float luminance = reading2.getFloat(j, "lux2");   
    
    // Checks to see if data point is within extents
    if (uv[0] > -margin*gridU && uv[0] < gridU * (1 + margin) && 
        uv[1] > -margin*gridV && uv[1] < gridV * (1 + margin) ) {
          
      // Log each data point in two coordinate Systems, (1) Lat,Lon and (2) u,v
      PVector[] reading = new PVector[2];
      reading[0] = new PVector(coord2.x, coord2.y, luminance);
      reading[1] = new PVector(uv[0], uv[1], luminance);
      lightReading.add(reading);
      
    }
  }
  
  // In cases where multiple values are recorded for the same grid coordinate, values are merged
  mergeRedundancies(lightReading);
  
  // Convert Values to a HashMap, useful for looking up via U,V coordinate
  lightReadingHash = listToHash(lightReading);
  
  println(lightReading.size() + " Philips Light Readings initialized.\n---");
}

// In cases where multiple values are recorded for the same grid coordinate, values are merged
void mergeRedundancies(ArrayList<PVector[]> values) {
  
  // Create hashtables of keyed values
  HashMap<String, float[]> valSum = new HashMap<String, float[]>();
  
  float[] count_sum; // { count, sumLux, sumLat, sumLon }
  String str;
  float valLux, valLat, valLon;
  float avgLux, avgLat, avgLon;
  int u, v;
  
  int redundancies = 0;
  int initSize = values.size();

  // Count occurrence of redundancies and track the sum of redundant values
  for (int i = values.size()-1; i>=0; i--) {
    
    // Generate Key of coordinate pairs
    u = (int)values.get(i)[1].x;
    v = (int)values.get(i)[1].y;
    str = u + "," + v;
    
    // Generate Values
    valLux = values.get(i)[1].z;
    valLat = values.get(i)[0].x;
    valLon = values.get(i)[0].y;
    
    count_sum = new float[4];
    
    // Merge instance into existing grid square if key already exists
    if (valSum.containsKey(str)) {
      
      redundancies ++;
      
      // Add 1 to Count of Values
      count_sum[0] = valSum.get(str)[0] + 1;
      
      // Add Lux Value to Sum of Values
      count_sum[1] = valSum.get(str)[1] + valLux;
      
      // Add Lat Value to Sum of Values
      count_sum[2] = valSum.get(str)[2] + valLat;
      
      // Add Lon Value to Sum of Values
      count_sum[3] = valSum.get(str)[3] + valLon;
      
      // Update HashMap
      valSum.put(str, count_sum);
      
      values.remove(i);

    // Initialize First Instance of this grid square if key not found
    } else {
      
      // Count #1 is set with initial values
      count_sum[0] = 1;
      count_sum[1] = valLux;
      count_sum[2] = valLat;
      count_sum[3] = valLon;
      valSum.put(str, count_sum); 
    }
  }
  
  // Set Values to the new average value from the HashMap
  for (PVector[] point : values) {
    u = (int) point[1].x;
    v = (int) point[1].y;
    str = u + "," + v;
    avgLux = valSum.get(str)[1] / valSum.get(str)[0];
    avgLat = valSum.get(str)[2] / valSum.get(str)[0];
    avgLon = valSum.get(str)[3] / valSum.get(str)[0];
    point[0].x = avgLat;
    point[0].y = avgLon;
    point[0].z = avgLux;
    point[1].z = avgLux;
  }
  
  // Summarize Merge Process
  println(redundancies + " grid redundancies found and merged in the set of " + initSize + " data points.");
}

void initLightFixtures() {
  
  lightFixture = new ArrayList<PVector[]>();
  
  // Data Handler for Importing Light Fixtures
  Table fixtures = loadTable("lightnodes.csv", "header"); 
  println("Light Fixtures imported from " + fixtureFile);
  
  // Add Fixtures to ArrayList
  for (int i = 0; i < fixtures.getRowCount (); i++) {
    // Lat, Lon Vector
    PVector coord = new PVector(fixtures.getFloat(i, "y"), fixtures.getFloat(i, "x") );
    // Grid (u, v) Vector
    int[] uv = LatLontoGrid(coord.x, coord.y, centerLatitude, centerLongitude, azimuth, gridSize, gridU, gridV);
    
    // Checks to see if data point is within extents
    if (uv[0] > -margin*gridU && uv[0] < gridU * (1 + margin) && 
        uv[1] > -margin*gridV && uv[1] < gridV * (1 + margin) ) {
          
      // Log each data point in two coordinate Systems, (1) Lat,Lon and (2) u,v
      PVector[] fixture = new PVector[2];
      fixture[0] = new PVector(coord.x, coord.y);
      fixture[1] = new PVector(uv[0], uv[1]);
      lightFixture.add(fixture);
      
    }
  }
  
  // Convert Values to a HashMap, useful for looking up via U,V coordinate
  lightFixtureHash = listToHash(lightFixture);
  
  println(lightFixture.size() + " Light Fixtures initialized.\n---");
}

// Convert a list of PVector[] to a Hashmap<Key, Value> for easy lookup of coordinate pairs
HashMap<String, float[]> listToHash(ArrayList<PVector[]> l) {
  String str;
  int u, v;
  float valLux, valLat, valLon;
  float[] value;
  
  HashMap<String, float[]> hash = new HashMap<String, float[]>();
  for (PVector[] point : l) {
    // Generate Key of coordinate pairs
    u = (int)point[1].x;
    v = (int)point[1].y;
    str = u + "," + v;
    
    // Generate Values
    valLux = point[1].z;
    valLat = point[0].x;
    valLon = point[0].y;
    
    value = new float[5];
    value[0] = u;
    value[1] = v;
    value[2] = valLat;
    value[3] = valLon;
    value[4] = valLux;
    hash.put(str, value); 
  }
  
  return hash;
}
