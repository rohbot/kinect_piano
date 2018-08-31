// Daniel Shiffman
// Tracking the average location beyond a given depth threshold
// Thanks to Dan O'Sullivan

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

class KinectTracker {

  // Depth threshold
  int threshold = 745;

  int numDiv = 10;

  // Raw location
  PVector loc;

  // Interpolated location
  PVector lerpedLoc;

  // Depth data
  int[] depth;

  // What we'll show the user
  PImage display;

  int minDepth = 9000;

  boolean triggered = false;

  int divWidth;

  boolean divs[] = new boolean[numDiv];
  long lastPlayed[] = new long[numDiv];


  KinectTracker() {
    // This is an awkard use of a global variable here
    // But doing it this way for simplicity
    kinect.initDepth();
    kinect.enableMirror(true);
    // Make a blank image
    display = createImage(kinect.width, kinect.height, RGB);
    // Set up the vectors
    loc = new PVector(0, 0);
    lerpedLoc = new PVector(0, 0);
    divWidth = kinect.width / numDiv;
    for (int i = 0; i < numDiv; i++) {
      divs[i] = false;
      lastPlayed[i] = millis();
    }
  }

  void track() {

    minDepth = 9000;

    // Get the raw depth as array of integers
    depth = kinect.getRawDepth();

    // Being overly cautious here
    if (depth == null) return;

    float sumX = 0;
    for (int i = 0; i < numDiv; i++) {
      int scale = i * divWidth;
      float sumY = 0;
      float count = 0;
      for (int x = scale; x < scale + divWidth; x++) {
        for (int y = 0; y < kinect.height; y++) {

          int offset =  x + y*kinect.width;
          // Grabbing the raw depth
          int rawDepth = depth[offset];

          // Testing against threshold
          if (rawDepth < threshold) {
            //sumX += x;
            sumY += y;
            count++;
            if (rawDepth < minDepth) {
              minDepth = rawDepth;
            }
          }
        }
      }
      if (count > 5000) {
        divs[i] = true;
      } else {
        divs[i] = false;
      }
    }
  }

  PVector getLerpedPos() {
    return lerpedLoc;
  }

  int getMinDepth() {
    return minDepth;
  }

  PVector getPos() {
    return loc;
  }

  void display() {
    PImage img = kinect.getDepthImage();

    // Being overly cautious here
    if (depth == null || img == null) return;

    // Going to rewrite the depth image to show which pixels are in threshold
    // A lot of this is redundant, but this is just for demonstration purposes
    display.loadPixels();
    for (int x = 0; x < kinect.width; x++) {
      for (int y = 0; y < kinect.height; y++) {

        int offset = x + y * kinect.width;
        // Raw depth
        int rawDepth = depth[offset];
        int pix = x + y * display.width;
        if (rawDepth < threshold) {
          // A red color instead
          display.pixels[pix] = color(150, 50, 50);
        } else {
          display.pixels[pix] = img.pixels[offset];
        }
      }
    }
    display.updatePixels();

    // Draw the image
    image(display, 0, 0);
  }

  int getThreshold() {
    return threshold;
  }

  void setThreshold(int t) {
    threshold =  t;
  }
}
