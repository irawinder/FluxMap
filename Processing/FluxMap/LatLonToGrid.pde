/* Class: LatLontoGrid()
 * Function to take Latitude Longitude (along with rotation grid h/w and grid size) 
 * and return the index of the point on a discrete grid.
 *
 * Azimuth in degrees, gridsize in km/stud.
 *
 * Mike Winder (mhwinder@gmail.com)
 * Ira Winder (jiw@mit.edu)
 * January, 2015
 */

int[] LatLontoGrid(float lat, float lon, float centerLat, float centerLon, float azm, float gridsize, int gh, int gw)
{
  //Create the unit conversion ratios. Earth Radius = 6371km
  //I find the km per Longitude from the center and assume its constant over the region
  float kmperLon = 2*PI*cos((float)(Math.PI/180.0*centerLat))*6371.0/360;
  float kmperLat = 2*PI*6371.0/360;
  
  //Convert from lat/lon to grid units (not yet rotated)
  float x = (lon - centerLon)*kmperLon/gridsize;
  float y = (lat - centerLat)*kmperLat/gridsize;
  
  //Rotate
  float xR, yR;
  float theta = (float)Math.PI/180*(azm+180);
  xR = + x*cos(theta) + y*sin(theta);
  yR = - x*sin(theta) + y*cos(theta);
  
  //Translate from center of grid to top left corner
  xR -= 0.5*gw;
  yR += 0.5*gh;
  // x and y are now on the grid, truncating to int will give us its location
  
  int[] xy;
  xy = new int[2];
  // Adjusts for negative latitude and longitudes
  if (centerLon < 0) {
    xy[0] = - int(xR);
  } else {
    xy[0] =   int(xR);
  }
  if (centerLat < 0) {
    xy[1] = - int(yR);
  } else {
    xy[1] =   int(yR);
  }
  
  //println(xy[0], xy[1]);
  return xy;
}
    
