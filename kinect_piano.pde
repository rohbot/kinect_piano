// Daniel Shiffman
// Tracking the average location beyond a given depth threshold
// Thanks to Dan O'Sullivan

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import oscP5.*;
import netP5.*;

// The kinect stuff is happening in another class
KinectTracker tracker;
Kinect kinect;


OscP5 oscP5;
NetAddress myRemoteLocation;
int numDiv = 10;
int divWidth;
int count = 0;

long lastPlayed[] = new long[numDiv];
boolean divs[] = new boolean[numDiv];


int valX;
int valY;
boolean triggered = false;


void setup() {
  size(640, 520);
  kinect = new Kinect(this);
  tracker = new KinectTracker();
  tracker.setThreshold(600);
  for (int i = 0; i < numDiv; i++) {
    lastPlayed[i] = millis();
    divs[i] = false;
  }
  divWidth = width / numDiv;
  frameRate(25);
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 9995);
}

void draw() {
  background(255);

  // Run the tracking analysis
  tracker.track();
  // Show the image
  tracker.display();

  // Let's draw the raw location
  PVector v1 = tracker.getPos();
  fill(50, 100, 250, 200);
  noStroke();
  ellipse(v1.x, v1.y, 20, 20);

  // Let's draw the "lerped" location
  PVector v2 = tracker.getLerpedPos();
  fill(100, 250, 50, 200);
  noStroke();
  ellipse(v2.x, v2.y, 20, 20);
  //checkGrid(v2.x, v2.y);
  for (int i = 0; i < numDiv; i++) {
    if (tracker.divs[i]) {
      int scale = i * divWidth;
      fill(255, 0, 0);
      rect(scale, 0, divWidth, height);
      
      if (!divs[i]) {
        divs[i] = true;
        sendOSC(i, 1);
      }
    } else {
      if (divs[i]) {
        divs[i] = false;
        sendOSC(i, 0);
      }
    }
  }

  // Display some info
  int minDepth = tracker.getMinDepth();

  fill(0);
  text("minDepth: " + minDepth + "    " +  "framerate: " + int(frameRate) + "    " + 
    "UP increase threshold, DOWN decrease threshold", 10, 500);
}

void checkGrid(float x, float y) {
  for (int i = 0; i < numDiv; i++) {
    int scale = i * divWidth;
    if (x > scale && x < scale + divWidth) {
      if (!tracker.divs[i]) {
        tracker.divs[i] = true;
        if (lastPlayed[i] > 500) {
          sendOSC(i, int(y));
          lastPlayed[i] = millis();
        }
      } else {
      }
    }
  }
}

void sendOSC(int num, int val) {
  OscMessage myMessage = new OscMessage("/piano/" + str(num));
  myMessage.add(val); /* add an int to the osc message */
  oscP5.send(myMessage, myRemoteLocation);
  println(myMessage);
}  

// Adjust the threshold with key presses
void keyPressed() {
  int t = tracker.getThreshold();
  if (key == CODED) {
    if (keyCode == UP) {
      t+=5;
      tracker.setThreshold(t);
    } else if (keyCode == DOWN) {
      t-=5;
      tracker.setThreshold(t);
    }
  }
  //println(t);
}
