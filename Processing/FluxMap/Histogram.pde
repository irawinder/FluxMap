/* Class: Histogram()
 * Generate and disply histograms based up ArrayList<> of values
 *
 * Ira Winder (jiw@mit.edu)
 * July 2017
 */

class Histogram {
  
  String units;
  int intervals, maxCount;
  int[] count;
  float intervalRange, minValue, maxValue;
  
  boolean autoFit, skipZero;
  
  Histogram(ArrayList<Float> values, int intervals, String units, boolean skipZero) {
    this.intervals = intervals;
    this.units = units;
    this.skipZero = skipZero;
    count = new int[intervals];
    
    autoFit = true;
    generateCounts(values);
  }
  
  Histogram(ArrayList<Float> values, int intervals, String units, float minValue, float maxValue, boolean skipZero) {
    this.intervals = intervals;
    this.units = units;
    this.skipZero = skipZero;
    this.minValue = minValue;
    this.maxValue = maxValue;
    count = new int[intervals];
    
    autoFit = false;
    generateCounts(values);
  }
  
  void generateCounts(ArrayList<Float> v) {
    // Determine Bucket Intervals
    if (autoFit) {
      minValue = Float.MAX_VALUE;
      maxValue = Float.MIN_VALUE;
      for (int i=0; i<v.size(); i++) {
        float value = v.get(i);
        if (value < minValue) minValue = value;
        if (value > maxValue) maxValue = value;
      }
    } 
    intervalRange = (maxValue - minValue) / intervals;
    
    clearCounts();
    
    // Determine Bucket Counts
    for (int i=0; i<v.size(); i++) {
      if (v.get(i) == 0 && skipZero) {
        // Do Nothing
      } else {
        int bucket = int( (v.get(i) - minValue) / intervalRange );
        if (bucket == intervals) bucket -= 1; // Ensures largest value placed in last index
        if (bucket < intervals) count[bucket]++; // Ensures no index out of bounds exception
      }
    }
    
    // Determine Max Frequency
    maxCount = Integer.MIN_VALUE;
    for (int i=0; i<count.length; i++) {
      if (count[i] > maxCount) {
        maxCount = count[i];
      }  
    }
  }
  
  void summarizeCounts() {
    println("Histogram Summary");
    for (int i=0; i<count.length; i++) {
      println("Interval " + i + " (" + (minValue+i*intervalRange) + "-" + (minValue+(i+1)*intervalRange) + "): " + count[i]);
    }
  }
  
  void clearCounts() {
    for(int i=0; i<intervals; i++) {
      count[i] = 0;
    }
  }
  
  void draw(int x, int y, int w, int h, color col) {
    
    int textSize = 12;
    
    // Draw CountBars
    noStroke();
    float barWidth = float(w)/count.length;
    for (int i=0; i<count.length; i++) {
      float barHeight = float(count[i]) / maxCount * (h - 2*textSize);
      fill(col);
      rect(x + i*barWidth + 1, y + h - 2*textSize - barHeight, barWidth - 2, barHeight);
      if (count[i] == maxCount) {
        fill(textColor);
        stroke(textColor);
        line(x + i*barWidth + 10, y, x + i*barWidth + 15, y);
        noStroke();
        text(count[i] + " counts\n[" + int(10*(minValue + i*intervalRange))/10.0 + "-" + int(10*(minValue + (i+1)*intervalRange))/10.0 + "] " + units, x + i*barWidth + 20, y + 6);
      }
    }
    
    // Draw Axes
    stroke(textColor); strokeWeight(2); fill(textColor);
    line(x, y + h - 2*textSize, x + w, y + h - 2*textSize);
    text(int(minValue), x, y + h - 0.7*textSize);
    textAlign(RIGHT);
    text(int(maxValue), x + w, y + h - 0.7*textSize);
    textAlign(CENTER);
    text(units, x + w/2, y + h - 0.7*textSize);
    textAlign(LEFT);
  }
  
}
