//String directory = "C:/Users/Ben F/Documents/processing-1.2.1/libraries/OpenCVn/data/haarcascades/aGest.xml";
String directory = "C:/Users/Ben/Documents/Processing/myFace/data/haarcascade_frontalface_alt.xml";
//String directory = "C:/Users/Ben F/Documents/processing-1.2.1/libraries/OpenCVn/data/haarcascades/haarcascade_fullbody.xml";
//String directory = "C:/Users/Ben F/Documents/processing-1.2.1/libraries/OpenCVn/data/haarcascades/haarcascade_upperbody.xml";
//String directory = "C:/Users/Ben F/Documents/processing-1.2.1/libraries/OpenCVn/data/haarcascades/haarcascade_mcs_upperbody.xml";
//String directory = "C:/Users/Ben F/Documents/processing-1.2.1/libraries/OpenCVn/data/haarcascades/haarcascade_frontalface_alt_tree.xml";
//String directory = "C:/Users/Ben F/Documents/processing-1.2.1/libraries/OpenCVn/data/haarcascades/haarcascade_frontalface_alt2.xml";
//String directory = "C:/Users/Ben F/Documents/processing-1.2.1/libraries/OpenCVn/data/haarcascades/haarcascade_frontalface_default.xml";

public class detectface extends Thread {

  private boolean running;          
  private int wait;                  
  private OpenCV opencv;
  private int _w;
  private int _h;
  private int _w1;
  private int _h1;
  private PApplet parent;
  private Rectangle[] faces= new Rectangle[0];
  private PImage face;
  private PImage _img;
  private mycapture _cap;
  
  public detectface (PApplet pa, mycapture cap, int wt, int w, int h, int w1, int h1) {
    parent=pa; 
    wait = wt;
    running = false;
    _w=w;
    _h=h;
    _w1=w1;
    _h1=h1;
    _img = null;
//    face = null;
    _cap=cap;
  }

  public void start ()
  {
    running = true;
    opencv = new OpenCV(parent);
    opencv.allocate(_w1,_h1);
    opencv.cascade(directory);
    super.start();
  }

  public Rectangle[] getRectangles() {
    return faces;
  }
  
  public void setImage(PImage _thisImage){
    _img = _thisImage;
  }
  
  public PImage getFace(){
    return face;
  }
  
  public void run ()
  {
    while (running) {
      _img=_cap.get_image();
//      if(_img!=null){
        opencv.copy(_img,0, 0,_w,_h,0,0,_w1,_h1);
//        faces = opencv.detect(1.1f,4,OpenCV.HAAR_DO_CANNY_PRUNING,40,40);
        faces = opencv.detect(1.3,3,OpenCV.HAAR_DO_CANNY_PRUNING,30,30);
//        faces = opencv.detect(1.2,4,OpenCV.HAAR_DO_ROUGH_SEARCH,20,20);
//      }
      try {
        sleep((long)(wait));
      }
      catch (Exception e) {}
    }
  }

  public void display() {
    pushStyle();
    noFill();
    if(faces.length>0){
      int xcoorcenter = int(width - factor*(faces[0].x+faces[0].width/factor));
      int ycoorcenter = int(factor*(faces[0].y+faces[0].height/factor));
      int xcoorrect = int(width - factor*(faces[0].x+faces[0].width));
      int ycoorrect = int(factor*(faces[0].y));
      point(xcoorcenter, ycoorcenter);
//      println(xcoor + " , " + ycoor);
//    println(faces[0].width*factor + "," + faces[0].height*factor);
      rect(xcoorrect, ycoorrect, faces[0].width*factor, faces[0].height*factor);
    }
    popStyle();
  }

  public void quit()
  {
    running = false;   
    interrupt(); 
    // Now sleep a while to avoid memeory errors 
    try {
      sleep(100l);
    } 
    catch (Exception e) {}
    opencv.stop();
  }
}
