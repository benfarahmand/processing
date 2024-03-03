class Visualize_Sprocket implements Visualizer {
    String NAME = "Sprocket";
    float[] angle;
    float[] y, x, z;
    float[] centerColor;
    float myWidth, myHeight;
    FFT myFFT;
    

    Visualize_Sprocket(FFT _fft){
        myFFT = _fft;
        y = new float[myFFT.specSize()];
        x = new float[myFFT.specSize()];
        z = new float[myFFT.specSize()];
        angle = new float[myFFT.specSize()];
        myWidth = parseFloat(width);
        myHeight = parseFloat(height);
        centerColor = new float[3];
        centerColor[0] = 0.0;
        centerColor[1] = 15.0;
        centerColor[2] = 90.0;
    }

    @Override
    void draw(){
        noStroke();
        pushMatrix();
        cameraTracker();
        translate(width/2, height/2, 0);
        for (int i = 0; i < myFFT.specSize(); i++) {
            fill(this.colorChanger(i, true));
            this.calculatePosition(i);
            this.moveCube(i);
        }
        popMatrix();
    }

    @Override
    color colorChanger(int i, boolean b) {
        if (b) return color(
            map(myFFT.getFreq(i)*speed, 0, 512, 0, 360),
            map(myFFT.getFreq(i), 0, 1024, 0, 100)+colorScale,
            100.0
            );
        else return color(
            map(myFFT.getFreq(i)*speed, 0, 512, 360, 0),
            map(myFFT.getFreq(i), 0, 1024, 100, 0),
            map(myFFT.getBand(i), 0, 512, 100, 0)
            );
    }

    void calculatePosition(int i){
        //sprocket rules
        y[i] = y[i] + myFFT.getBand(i)/1000;
        x[i] = x[i] + myFFT.getFreq(i)/1000;
        z[i] = 0;
        angle[i] = angle[i] + myFFT.getFreq(i)/10000*speed;
    }

    void moveCube(int i){
        rotateX(sin(angle[i]/2));
        rotateY(cos(angle[i]/2));
        pushMatrix();
        translate((x[i]+250)%width, (y[i]+250)%height, z[i]);
        box((myFFT.getBand(i)+myFFT.getFreq(i))*sizeScale/10);
        popMatrix();
    }

    @Override
    void initMode(){
        //no init for this mode, can go straight to drawing
    }

    @Override
    void endMode() {}   

    @Override
    String getName(){
        return NAME;
    }
}
