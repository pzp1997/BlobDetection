import processing.video.*;

Capture cam;
PImage filteredImg;
color selectedColor;
int threshold;
boolean showCam, showFiltered;
int[] blob;
final color white = color(255),
            black = color(0);

void setup() {
  size(400, 400);

  if (Capture.list().length == 0) {
    println("No cameras detected.");
    exit();
  }
  cam = new Capture(this, width, height);
  cam.start();

  filteredImg = createImage(width, height, RGB);

  threshold = 20;
  
  showCam = true;
  
  fill(255);
  noStroke();
}

void draw() {
  if (cam.available()) {
    cam.read();
  }

  isolateColor(cam, filteredImg, selectedColor, threshold);
//  blob = findExtrema(filteredImg);
  blob = findMiddleMass(filteredImg);
  
  ellipse(blob[0], blob[1], 5, 5);
  
  
//  ellipse(width - blob[0], blob[1], blob[2]/2, blob[3]/2);

  if (showFiltered) {
    set(0, 0, filteredImg);
  } else if (showCam) {
    set(0, 0, cam);
  }
}

void mousePressed() {
  selectedColor = cam.get(mouseX, mouseY);
  println("selectedColor: " + colorToString(selectedColor));
}

void keyPressed() {
  if (key == CODED) {
    switch (keyCode) {
      case UP:
        threshold = constrain(threshold + 1, 0, 255);
        println("Threshold: " + threshold);
        break;
      case DOWN:
        threshold = constrain(threshold - 1, 0, 255);
        println("Threshold: " + threshold);
        break;
      case SHIFT:
        showFiltered = true;
        break;
    }
  } else if (key == ' ') {
    showCam = !showCam;
    background(0);
  }
}

void keyReleased() {
  if (key == CODED && keyCode == SHIFT) {
    showFiltered = false;
    background(0);
  }
}

void isolateColor(PImage inImg, PImage outImg, color inClr, int thresh) {
  color clr;

  inImg.loadPixels();

  for (int i = 0; i < inImg.pixels.length; i++) {
    clr = inImg.pixels[i];
    
    outImg.pixels[i] = dist(clr >> 16 & 0xFF,
                            clr >> 8 & 0xFF,
                            clr & 0xFF,
                            inClr >> 16 & 0xFF,
                            inClr >> 8 & 0xFF,
                            inClr & 0xFF) > thresh ? black : white;
  }

  outImg.updatePixels();
}

String colorToString(color clr) {
  return "(" + (clr >> 16 & 0xFF) + ", " +
               (clr >> 8 & 0xFF) + ", " +
               (clr & 0xFF) + ")";
}

int[] findExtrema(PImage inImg) {
  inImg.loadPixels();
  
  int minX = Integer.MAX_VALUE, maxX = Integer.MIN_VALUE,
      minY = Integer.MAX_VALUE, maxY = Integer.MIN_VALUE;
  
  for (int i = 0; i < inImg.pixels.length; i++) {
    if (inImg.pixels[i] == white) {
      maxX = max(i % inImg.width, maxX);
      minX = min(i % inImg.width, minX);
      maxY = max(i / inImg.width, maxY);
      minY = min(i / inImg.width, minY);
    }
  }
  
  int x, y, w, h;
  x = (int) (minX + maxX)/2;
  y = (int) (minY + maxY)/2;
  w = maxX - minX;
  h = maxY - minY;
  return new int[]{x, y, w, h};
}

int[] findMiddleMassOld(PImage inImg) {
  inImg.loadPixels();
  
  IntList xVals = new IntList();
  IntList yVals = new IntList();
  
  for (int i = 0; i < inImg.pixels.length; i++) {
    if (inImg.pixels[i] == white) {
      xVals.append(i % inImg.width);
      yVals.append(i / inImg.width);
    }
  }
  
  int x, y;
  x = (int) average(xVals);
  y = (int) average(yVals);
  return new int[]{x, y};
}

float average(IntList list) {
  if (list.size() == 0)
    return 0;
    
  int sum = 0;
  for ( int item : list ) {
    sum += item;
  }
  return sum / list.size();
}

int[] findMiddleMass(PImage inImg) {
  inImg.loadPixels();
  
  int xSum = 0,
      ySum = 0,
      numOfPxls = 0;
  
  for (int i = 0; i < inImg.pixels.length; i++) {
    if (inImg.pixels[i] == white) {
      xSum += i % inImg.width;
      ySum += i / inImg.width;
      numOfPxls++;
    }
  }
  
  if (numOfPxls == 0)
    return new int[]{0, 0};
  
  int x, y;
  x = xSum / numOfPxls;
  y = ySum / numOfPxls;
  return new int[]{x, y};
}
