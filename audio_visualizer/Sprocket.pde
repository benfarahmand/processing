class Sprocket {
    float[] angle;
    float[] y, x;
    int mode = 0;
    float[] centerColor;
    FFT fft;
    boolean transitioning = false;
    float myWidth, myHeight;
    int horizontalGridCubeSpacing, verticalGridCubeSpacing, gridVerticalIncrementer;

    Sprocket(FFT _fft){
        fft = _fft;
        y = new float[fft.specSize()];
        x = new float[fft.specSize()];
        angle = new float[fft.specSize()];
        myWidth = float(width);
        myHeight = float(myHeight);
        verticalGridCubeSpacing = sqrt(myWidth/myHeight*fft.specSize());
        horizontalGridCubeSpacing = myWidth/myHeight*verticalGridCubeSpacing;
        verticalGridCubeSpacing = round(verticalGridCubeSpacing);
        horizontalGridCubeSpacing = round(horizontalGridCubeSpacing);
        gridVerticalIncrementer = -1;
        centerColor = new float[3];
        centerColor[0] = 0.0;
        centerColor[1] = 15.0;
        centerColor[2] = 90.0;
    }

    void draw(){
        pushMatrix();
        cameraTracker();
        translate(width/2, height/2, 0);
        for (int i = 0; i < fft.specSize(); i++) {
            fill(colorChanger(i, true));
            calculatePosition(i);
            moveCube(i);
        }
        popMatrix();
    }

    void calculatePosition(int i){
        if(mode == 0){
            //sprocket rules
            y[i] = y[i] + fft.getBand(i)/1000;
            x[i] = x[i] + fft.getFreq(i)/1000;
            angle[i] = angle[i] + fft.getFreq(i)/10000*speed;
        }
        else if (mode == 1){
            //grid rules
            //for this rule set, we may not need to always update the position and only calculate it once
            if( i%(horizontalGridCubeSpacing) == 0){ 
                gridVerticalIncrementer++;
                if(gridVerticalIncrementer%(verticalGridCubeSpacing) == 0) gridVerticalIncrementer = 0;
            }
            x[i] = i%(horizontalGridCubeSpacing)*horizontalGridCubeSpacing;
            y[i] = gridVerticalIncrementer%(verticalGridCubeSpacing)*verticalGridCubeSpacing;
        }
        else if (mode == 2){
            //gravity rules
        }
        else if (mode == 3){
            //curtain in the wind rules
        }
    }

    void moveCube(int i){
        if (mode == 0) {
            rotateX(sin(angle[i]/2));
            rotateY(cos(angle[i]/2));
            pushMatrix();
            translate((x[i]+250)%width, (y[i]+250)%height);
            box((fft.getBand(i)/20+fft.getFreq(i)/15)*sizeScale);
            popMatrix();
        }
        else if (mode == 1){
            pushMatrix();
            translate(x[i], y[i]);
            box((fft.getBand(i)/20+fft.getFreq(i)/15)*sizeScale);
            popMatrix();
        }
        else if (mode == 2){

        }
    }

    void transitionBetweenModes(){
        //calculate the positions of the cubes as we transition between modes
        //once the transition is done, we then set the transitioning to false
    }

    //transition between modes after each song, maybe we can detect when the song ends by the duration of no beats
    //so we need some counter that will keep track of how long automatically transition to another mode
    void setMode(int i){ 
        //typical sprocket mode
        //gravity mode
        //background grid mode
        if (i != mode) transitioning = true;
        mode = i;
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
}