public class Face {
  PImage[] myFace;
  int x, y, recordCounter, drawCounter;
  int myTotalFaces = 5;
  int recordTime = 50; //milliseconds
  int drawTime = 150; //milliseconds
  boolean readyToDisplay;
  Timer recordTimer;
  Timer drawTimer;
  int myID;
  
  Face(int tempx, int tempy, int _myID) {
    x = tempx*width/faceFactor;
    y = tempy*height/faceFactor;
    myID = _myID;
    myFace = new PImage[myTotalFaces];
    recordTimer = new Timer();
    drawTimer = new Timer();
    recordCounter = 0;
    drawCounter = 0;
    readyToDisplay = false;
    for (int i =0;i<myFace.length;i++) {
      myFace[i] = new PImage();
    }
    registerDraw(this);
  }
  
  int getX(){
    return x;
  }
  
  int getY(){
    return y;
  }
  
  void setFace(Rectangle[] rectFace, PImage _f){
    if (rectFace.length>0) {
      PImage temp = new PImage();
      temp = _f.get(int(rectFace[0].x*factor), int(rectFace[0].y*factor), int(rectFace[0].width*factor), int(rectFace[0].height*factor));
      temp.resize(width/faceFactor, height/faceFactor);
      if (!readyToDisplay) {
        recordTimer.run(recordTime);
        if (recordTimer.isDone()) {
          if (recordCounter<myTotalFaces) {
            myFace[recordCounter] = temp;
            recordCounter++;
            recordTimer.reset();
          }
          else{
            readyToDisplay = true;
            counter++;
          }
        }
      }
    }
  }

  boolean faceStored() {
    return readyToDisplay;
  }

  void resetCheck(){
    if(readyToDisplay){
      if(counter==myID){
        this.allowFaceChange();
      }
    }
  }
  
  void draw() {
    if (readyToDisplay) {
      drawTimer.run(drawTime);
      if (drawTimer.isDone()) {
        image(myFace[drawCounter], x, y);
        drawCounter++;
        if (drawCounter==myTotalFaces)drawCounter=0;
        drawTimer.reset();
      }
    }
  }

  void allowFaceChange() {
    readyToDisplay = false;
    recordCounter = 0;
  }
}
