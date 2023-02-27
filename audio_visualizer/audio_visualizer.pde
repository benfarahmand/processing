import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
FFT fft;
AudioInput in;
BeatCounter bpm;

float[] angle;
float[] y, x;
float sizeScale = 1.0, colorScale = 1.0;
float speed = 1.0;
float cameraZoom = 0.0;
Sprocket s;

void setup()
{
  fullScreen(P3D);
  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO, 2048, 192000.0, 16);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  bpm = new BeatCounter();
  s = new Sprocket(fft);
  // y = new float[fft.specSize()];
  // x = new float[fft.specSize()];
  // angle = new float[fft.specSize()];
  // centerColor = new float[3];
  // centerColor[0] = 0.0;
  // centerColor[1] = 15.0;
  // centerColor[2] = 90.0;
  colorMode(HSB, 360.0, 100.0, 100.0, 1.0);
  frameRate(30);
}

void draw()
{
  // cameraZoom = cameraZoom + map(bpm.getBPM(), 1.0, 7.0, -10.0, 5.0);
  speed = map(bpm.getBPM(), 1.0, 5.0, 0.1, 10.0);
  sizeScale = map(bpm.getBPM(), 1.0, 5.0, 1.0, 2.0);
  colorScale = map(bpm.getBPM(), 1.0, 10.0, -10.0, 90.0);
  backgroundSetter();
  fft.forward(in.mix);
  // doubleAtomicSprocket();
  bpm.run();
  s.draw();
  // println(bpm.getBPM());
}

void backgroundSetter() {
  pushMatrix();
  cameraTracker();
  translate(0, 0, -1000);
  fill(0, 0, 0, map(bpm.getBPM(), 1.0, 8.0, 1.0, 0.0));
  rect(-2*width, -2*height, 5*width, 5*height);
  popMatrix();
}

color colorChanger(int i, boolean b) {
  if (b) return color(
    map(fft.getFreq(i)*speed, 0, 512, 0, 360),
    map(fft.getFreq(i), 0, 1024, 0, 100)+colorScale,
    100.0
    );
  else return color(
    map(fft.getFreq(i)*speed, 0, 512, 360, 0),
    map(fft.getFreq(i), 0, 1024, 100, 0),
    map(fft.getBand(i), 0, 512, 100, 0)
    );
}

void cameraTracker() {
  if (cameraZoom>150)cameraZoom=150;
  if (cameraZoom<0)cameraZoom=0;
  translate(0, 0, cameraZoom);
}

// void doubleAtomicSprocket() {
//   noStroke();
//   pushMatrix();
//   cameraTracker();
//   translate(width/2, height/2, 0);
//   for (int i = 0; i < fft.specSize(); i++) {
//     y[i] = y[i] + fft.getBand(i)/1000;
//     x[i] = x[i] + fft.getFreq(i)/1000;
//     angle[i] = angle[i] + fft.getFreq(i)/10000*speed;
//     rotateX(sin(angle[i]/2));
//     rotateY(cos(angle[i]/2));
//     fill(colorChanger(i, true));
//     pushMatrix();
//     translate((x[i]+250)%width, (y[i]+250)%height);
//     box((fft.getBand(i)/20+fft.getFreq(i)/15)*sizeScale);
//     popMatrix();
//   }
//   popMatrix();
//   pushMatrix();
//   cameraTracker();
//   translate(width/2, height/2);
//   for (int i = 0; i < fft.specSize(); i++) {
//     rotateX(sin(angle[i]/2));
//     rotateY(cos(angle[i]/2));
//     fill(colorChanger(i, false));
//     pushMatrix();
//     translate((x[i]+125)%width/2, (y[i]+125)%height/2);
//     box((fft.getBand(i)/20+fft.getFreq(i)/15)*sizeScale);
//     popMatrix();
//   }
//   popMatrix();
// }

void stop()
{
  minim.stop();
  super.stop();
}

void keyPressed(){
  if(key == '1'){
    s.setMode(1);
  }else if(key == '2'){
    s.setMode(2);
  }else if(key == '3'){
    s.setMode(3);
  }else if(key == '4'){
    s.setMode(4);
  }
}