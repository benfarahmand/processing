class Sprocket {
    float[] angle;
    float[] y, x, z, xf,yf,zf; //the t arrays are for transitioning between modes
    float[] vx, vy, vz; //velocities for gravity mode
    int mode = 1, lastMode = 1;
    float[] centerColor;
    FFT myFFT;
    boolean transitioning = false;
    float transitionalPositionIncrementer = 0.0, totalTransitionIncrements = 40.0;
    float myWidth, myHeight;
    float horizontalGridCubeSpacing, verticalGridCubeSpacing, gridVerticalIncrementer;
    float modeTransitionTimer = 0.0, modeTransitionTimerDuration = 2000.0; //if the beats are low for more than 3 seconds, switch the mode

    Sprocket(FFT _fft){
        myFFT = _fft;
        y = new float[myFFT.specSize()];
        x = new float[myFFT.specSize()];
        z = new float[myFFT.specSize()];
        yf = new float[myFFT.specSize()];
        xf = new float[myFFT.specSize()];
        zf = new float[myFFT.specSize()];
        vy = new float[myFFT.specSize()];
        vx = new float[myFFT.specSize()];
        vz = new float[myFFT.specSize()];
        angle = new float[myFFT.specSize()];
        myWidth = parseFloat(width);
        myHeight = parseFloat(height);
        verticalGridCubeSpacing = sqrt(myWidth/myHeight*myFFT.specSize());
        horizontalGridCubeSpacing = myWidth/myHeight*verticalGridCubeSpacing;
        verticalGridCubeSpacing = round(verticalGridCubeSpacing);
        horizontalGridCubeSpacing = round(horizontalGridCubeSpacing);
        gridVerticalIncrementer = -1;
        centerColor = new float[3];
        centerColor[0] = 0.0;
        centerColor[1] = 15.0;
        centerColor[2] = 90.0;
        modeTransitionTimer = millis()+10000.0;
    }

    void draw(){
        this.modeTransitioner();
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
        this.modeTransitionTracker();
    }

    void modeTransitionTracker(){
        if(transitioning){
            transitionalPositionIncrementer++;
            if(transitionalPositionIncrementer>=totalTransitionIncrements){
                yf = new float[myFFT.specSize()];
                xf = new float[myFFT.specSize()];
                zf = new float[myFFT.specSize()];
                transitionalPositionIncrementer = 0.0;
                transitioning = false;
            }
        }
    }

    void calculatePosition(int i){
        // if(i==1) println(x[i]+" , "+y[i]+" , "+z[i]);
        if(transitioning) transitionBetweenModes(i);
        else {
            if(mode == 1){
                //sprocket rules
                y[i] = y[i] + myFFT.getBand(i)/1000;
                x[i] = x[i] + myFFT.getFreq(i)/1000;
                z[i] = 0;
                angle[i] = angle[i] + myFFT.getFreq(i)/10000*speed;
            }
            else if (mode == 2){
                //grid rules
                //for this rule set, we may not need to always update the position and only calculate it once
                if( i%(horizontalGridCubeSpacing) == 0){
                    gridVerticalIncrementer++;
                    if(gridVerticalIncrementer%(verticalGridCubeSpacing) == 0) gridVerticalIncrementer = 0;
                }
                x[i] = i%(horizontalGridCubeSpacing)*(myWidth/horizontalGridCubeSpacing)-myWidth/2;
                y[i] = gridVerticalIncrementer%(verticalGridCubeSpacing)*(myHeight/verticalGridCubeSpacing)-myHeight/2;
                z[i] = 0;
            }
            else if (mode == 3){
                //gravity rules
                float volumeAdjuster = myFFT.getBand(i)/10;
                float massAdjuster = myFFT.getFreq(i);
                float velocityDamp = 0.5;
                for(int j = 0 ; j < myFFT.specSize() ; j++){
                    if(i!=j){
                        if(dist(x[i],y[i],z[i],x[j],y[j],z[j])<200){
                            vx[i] = vx[i] + (x[j] - x[i])*.00001*massAdjuster;
                            vy[i] = vy[i] + (y[j] - y[i])*.00001*massAdjuster;
                            vz[i] = vz[i] + (z[j] - z[i])*.00001*massAdjuster;
                            // if(dist(x[i],y[i],z[i],x[j],y[j],z[j])<10){
                            //     vx[i] = vx[i]*0.9 + (x[j] - x[i])*-.00001;
                            //     vy[i] = vy[i]*0.9 + (y[j] - y[i])*-.00001;
                            //     vz[i] = vz[i]*0.9 + (z[j] - z[i])*-.00001;
                            // }
                        }
                    }
                }
                x[i] = x[i] + vx[i]*volumeAdjuster;
                y[i] = y[i] + vy[i]*volumeAdjuster;
                z[i] = z[i] + vz[i]*volumeAdjuster;
                if(x[i]<-myWidth/2)vx[i]=-vx[i]*velocityDamp;
                else if(x[i]>myWidth/2)vx[i]=-vx[i]*velocityDamp;
                if(y[i]<-myHeight/2)vy[i]=-vy[i]*velocityDamp;
                else if(y[i]>myHeight/2)vy[i]=-vy[i]*velocityDamp;
                if(z[i]<-250)vz[i]=-vz[i]*velocityDamp;
                else if(z[i]>250)vz[i]=-vz[i]*velocityDamp;
            }
            else if (mode == 4){
                //curtain in the wind rules
                //or particles with connecting lines and instead color the lines and increase the line thickness
                //based on the volume and stuff
            }
        }
    }

    void moveCube(int i){
            if (mode == 1) {
                rotateX(sin(angle[i]/2));
                rotateY(cos(angle[i]/2));
                pushMatrix();
                translate((x[i]+250)%width, (y[i]+250)%height, z[i]);
                box((myFFT.getBand(i)+myFFT.getFreq(i))*sizeScale/10);
                popMatrix();
            }
            else if (mode == 2){
                pushMatrix();
                translate(x[i], y[i], z[i]);
                box((myFFT.getBand(i)+myFFT.getFreq(i))*sizeScale/10+1);
                popMatrix();
            }
            else if (mode == 3){
                pushMatrix();
                translate(x[i], y[i], z[i]);
                sphere((myFFT.getBand(i)+myFFT.getFreq(i))*sizeScale/20+1);
                popMatrix();
            }
    }

    void transitionBetweenModes(int i){
        //calculate the positions of the cubes as we transition between modes
        //once the transition is done, we then set the transitioning to false
        if(transitioning){
            if(mode == 1){
                //sprocket rules
                yf[i] = yf[i] + myFFT.getBand(i)/1000;
                xf[i] = xf[i] + myFFT.getFreq(i)/1000;
                angle[i] = angle[i] + myFFT.getFreq(i)/10000*speed;
            }
            else if (mode == 2){
                //grid rules
                //for this rule set, we may not need to always update the position and only calculate it once
                if( i%(horizontalGridCubeSpacing) == 0){
                    gridVerticalIncrementer++;
                    if(gridVerticalIncrementer%(verticalGridCubeSpacing) == 0) gridVerticalIncrementer = 0;
                }
                xf[i] = i%(horizontalGridCubeSpacing)*(myWidth/horizontalGridCubeSpacing)-myWidth/2;
                yf[i] = gridVerticalIncrementer%(verticalGridCubeSpacing)*(myHeight/verticalGridCubeSpacing)-myHeight/2;
                zf[i] = 0;
            }
            else if (mode == 3){
                xf[i] = random(-myWidth/2,myWidth/2);
                yf[i] = random(-myHeight/2,myHeight/2);
                zf[i] = random(-100,100);
            }
            x[i] = lerp(x[i],xf[i],transitionalPositionIncrementer/totalTransitionIncrements);
            y[i] = lerp(y[i],yf[i],transitionalPositionIncrementer/totalTransitionIncrements);
            z[i] = lerp(z[i],zf[i],transitionalPositionIncrementer/totalTransitionIncrements);
        }
    }

    //transition between modes after each song, maybe we can detect when the song ends by the duration of no beats
    //so we need some counter that will keep track of how long automatically transition to another mode
    void setMode(int i){ 
        if(!transitioning){
            if(i>3)i=1;
            if (i != mode) {
                transitioning = true;
            }
            mode = i;
        }
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

    void modeTransitioner(){
        // println(bpm.getBPM());
        if(bpm.getBPM()<3.0){
            // println((millis() - modeTransitionTimer));
            if(millis() - modeTransitionTimer > modeTransitionTimerDuration){
                if(!transitioning) {
                    this.setMode(mode+1);
                }
                modeTransitionTimer = millis()+10000.0;
            }
        } else {
            modeTransitionTimer = millis();
        }
    }
}