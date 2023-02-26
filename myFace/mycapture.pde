public class mycapture {

  private Capture cam;
  private int _w;
  private int _h;
  private PImage _img;
  private String _cameraname;

  public mycapture (PApplet pa, int w, int h, String somecamera) {
    _w=w;
    _h=h;
    _cameraname=somecamera;
    cam=new Capture(pa,_w,_h);//,_cameraname, 30); 
    cam.start();
//   println(cam.list()); 
  }
  
  public PImage get_image(){
    cam.read();
    PImage tmp=cam.get();
    tmp.filter(PApplet.RGB);
    return tmp;
  }
  
  public void stop() {
    cam.stop();
  }
  
}
