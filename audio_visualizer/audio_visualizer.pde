import ddf.minim.analysis.*;
import ddf.minim.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.GraphicsDevice;
import java.awt.GraphicsEnvironment;
import java.awt.Rectangle;
import controlP5.*;

Minim minim;
FFT fft;
AudioInput in;
BeatCounter bpm;
Capture video;
OpenCV opencv;

Control_Screen control_screen;

float sizeScale = 1.0, colorScale = 1.0;
float speed = 1.0;
float cameraZoom = 0.0;
Mode_Tracker mt;
boolean backgroundReset = false;

void setup()
{
  fullScreen(P3D);
  mt = new Mode_Tracker(0); //start with mode 1

  //load audio resources
  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO, 2048, 192000.0, 16);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  bpm = new BeatCounter();

  //load video processors... consider lazy loading them later
  video = new Capture(this, "pipeline:autovideosrc");
  opencv = new OpenCV(this, 640, 480);

  mt.add(new Visualize_Sprocket(fft));
  mt.add(new Visualize_Wall(fft));
  mt.add(new Visualize_Gravity(fft));
  mt.add(new Visualize_Particle_Rules(fft));
  mt.add(new Visualize_Skull(fft));
  mt.add(new Visualize_Skull_with_Wings(fft));
  mt.add(new Visualize_Angel(fft));
  mt.add(new Visualize_Tentacles(fft));
  mt.add(new Visualize_Edges(fft));
  mt.add(new Visualize_Glitchy_Edges(fft));
  colorMode(HSB, 360.0, 100.0, 100.0, 1.0);
  control_screen = new Control_Screen();
  // frameRate(60);
}

void draw()
{
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
  translate(0, 0, -2000);
  if(mt.mode != 7 && mt.mode!=8 && /*mt.mode!=9 && mt.mode!=0 &&*/ !backgroundReset) fill(0, 0, 0, map(bpm.getBPM(), 1.0, 10.0, 1.0, 0.0));
  else fill(0);
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
  if(key == 'f'){
    backgroundReset=!backgroundReset;
  }
}

void captureEvent(Capture c) {
    c.read();
}