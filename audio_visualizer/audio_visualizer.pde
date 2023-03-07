import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
FFT fft;
AudioInput in;
BeatCounter bpm;

float sizeScale = 1.0, colorScale = 1.0;
float speed = 1.0;
float cameraZoom = 0.0;
Mode_Tracker mt;
Visualize_Sprocket vSprock;
Visualize_Wall vWall;
Visualize_Gravity vGrav;
Visualize_Particle_Rules vPartRule;
Visualize_Skull vSkull;
Visualize_Angel vAngel;

void setup()
{
  fullScreen(P3D);
  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO, 2048, 192000.0, 16);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  bpm = new BeatCounter();
  mt = new Mode_Tracker(1); //start with mode 1
  vSprock = new Visualize_Sprocket(fft);
  vWall = new Visualize_Wall(fft);
  vGrav = new Visualize_Gravity(fft);
  vPartRule = new Visualize_Particle_Rules(fft);
  vSkull = new Visualize_Skull(fft);
  vAngel = new Visualize_Angel(fft);
  colorMode(HSB, 360.0, 100.0, 100.0, 1.0);
  // frameRate(60);
}

void draw()
{
  // cameraZoom = cameraZoom + map(bpm.getBPM(), 1.0, 7.0, -10.0, 5.0);
  speed = map(bpm.getBPM(), 1.0, 5.0, 0.1, 10.0);
  sizeScale = map(bpm.getBPM(), 1.0, 5.0, 1.0, 2.0);
  colorScale = map(bpm.getBPM(), 1.0, 10.0, -10.0, 90.0);
  backgroundSetter();
  fft.forward(in.mix);
  bpm.run();
  mt.draw(); //manages which visualizer to draw based on the selected mode
}

void backgroundSetter() {
  pushMatrix();
  cameraTracker();
  translate(0, 0, -1000);
  // fill(0);
  fill(0, 0, 0, map(bpm.getBPM(), 1.0, 10.0, 1.0, 0.0));
  rect(-2*width, -2*height, 5*width, 5*height);
  popMatrix();
}

void cameraTracker() {
  if (cameraZoom>150)cameraZoom=150;
  if (cameraZoom<0)cameraZoom=0;
  translate(0, 0, cameraZoom);
}

void stop()
{
  minim.stop();
  super.stop();
}

void keyPressed(){
  if(key == '1'){
    mt.setMode(1);
  }else if(key == '2'){
    mt.setMode(2);
  }else if(key == '3'){
    mt.setMode(3);
  }else if(key == '4'){
    mt.setMode(4);
  }else if(key == '5'){
    mt.setMode(5);
  }else if(key == '6'){
    mt.setMode(6);
  }
}