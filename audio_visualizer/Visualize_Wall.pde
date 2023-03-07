class Visualize_Wall {
    
    float[] y, x, z;
    float[] centerColor;
    FFT myFFT;
    float myWidth, myHeight;
    float horizontalGridCubeSpacing, verticalGridCubeSpacing, gridVerticalIncrementer;
   
    Visualize_Wall(FFT _fft){
        myFFT = _fft;
        y = new float[myFFT.specSize()];
        x = new float[myFFT.specSize()];
        z = new float[myFFT.specSize()];
        myWidth = parseFloat(width);
        myHeight = parseFloat(height);
        verticalGridCubeSpacing = sqrt(myWidth/myHeight*myFFT.specSize());
        horizontalGridCubeSpacing = myWidth/myHeight*verticalGridCubeSpacing;
        verticalGridCubeSpacing = round(verticalGridCubeSpacing)*10;
        horizontalGridCubeSpacing = round(horizontalGridCubeSpacing)*15;
        gridVerticalIncrementer = -1;
        centerColor = new float[3];
        centerColor[0] = 0.0;
        centerColor[1] = 15.0;
        centerColor[2] = 90.0;
    }

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

    void calculatePosition(int i){
        //grid rules
        //for this rule set, we may not need to always update the position and only calculate it once
        if( i%(horizontalGridCubeSpacing) == 0){
            gridVerticalIncrementer--;
            if(gridVerticalIncrementer < 0) gridVerticalIncrementer = verticalGridCubeSpacing;
        }
        x[i] = i%(horizontalGridCubeSpacing)*(myWidth/horizontalGridCubeSpacing)-myWidth/2;
        y[i] = gridVerticalIncrementer%(verticalGridCubeSpacing)*(myHeight/verticalGridCubeSpacing)-myHeight/2-myFFT.getFreq(i)*2;
        z[i] = 0;
    }

    void moveCube(int i){
        pushMatrix();
        translate(x[i], y[i], z[i]);
        box((myFFT.getBand(i)+myFFT.getFreq(i))*sizeScale/20+1);
        popMatrix();
    }

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

    void initMode(){
        //no init for this mode, can go straight to drawing
    }
}
