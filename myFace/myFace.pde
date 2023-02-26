import hypermedia.video.*;
import java.awt.Rectangle;
import processing.video.*;

String cameraname = "HP Webcam";

static final int w = 640; //1080;
static final int h = 480;//720;
static final int w1 = w/2;//540;
static final int h1 = h/2;//360;
static final float factor=2;

int counter = 0;
static final int faceFactor = 10;
static final int totalFaces = faceFactor*faceFactor;
Rectangle[] faces;
PImage backgroundImage;
Face[] allFaces;

detectface detectthread;
public mycapture cap;

void setup() {
  background(0);
  cap=new mycapture(this, w, h, cameraname);
  detectthread= new detectface(this, cap, 50, w, h, w1, h1);
  detectthread.start();
  size(1920, 1080);
  allFaces = new Face[totalFaces];
  int tempCounter = 0;
  for (int i = 0;i<faceFactor;i++) {
    for (int j = 0; j<faceFactor;j++) {
      allFaces[tempCounter] = new Face(j, i, tempCounter);
      tempCounter++;
    }
  }
  noStroke();
}

void draw() {
  backgroundImage = cap.get_image();
  faces = detectthread.getRectangles();
//  if(allFaces[totalFaces-1].faceStored()) allFaces[counter].allowFaceChange();
  allFaces[counter].setFace(faces, backgroundImage);
  for (int i=0;i<totalFaces;i++) {
    if (allFaces[i].faceStored()) {
      allFaces[i].draw();
    }
  }
  if(counter==totalFaces){
    counter = 0;
  }
  allFaces[counter].resetCheck();
}
