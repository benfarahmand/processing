class Mode_Tracker {
    
    boolean transitioning = false;
    float transitionalPositionIncrementer = 0.0, totalTransitionIncrements = 40.0;
    int mode, lastMode;
    float modeTransitionTimer = 0.0, modeTransitionTimerDuration = 2000.0; //if the beats are low for more than 3 seconds, switch the mode

    Mode_Tracker(int i){
        mode = i;
        lastMode = i;
        modeTransitionTimer = millis()+10000.0;
    }

    void draw(){
        if(mode == 1) vSprock.draw();
        else if(mode == 2) vWall.draw();
        else if(mode == 3) vGrav.draw();
        else if(mode == 4) vPartRule.draw();
        else if(mode == 5) vSkull.draw();
        else if(mode == 6) vAngel.draw();
    }

    //transition between modes after each song, maybe we can detect when the song ends by the duration of no beats
    //so we need some counter that will keep track of how long automatically transition to another mode
    void setMode(int i){ 
        if(i>6)i=1;
        mode = i;
        if(mode == 1) vSprock.initMode();
        else if(mode == 2) vWall.initMode();
        else if(mode == 3) vGrav.initMode();
        else if(mode == 4) vPartRule.initMode();
        else if(mode == 5) vSkull.initMode();
        else if(mode == 6) vAngel.initMode();
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

    // void modeTransitionTracker(){
    //     if(transitioning){
    //         transitionalPositionIncrementer++;
    //         if(transitionalPositionIncrementer>=totalTransitionIncrements){
    //             yf = new float[myFFT.specSize()];
    //             xf = new float[myFFT.specSize()];
    //             zf = new float[myFFT.specSize()];
    //             vy = new float[myFFT.specSize()];
    //             vx = new float[myFFT.specSize()];
    //             vz = new float[myFFT.specSize()];
    //             transitionalPositionIncrementer = 0.0;
    //             transitioning = false;
    //         }
    //     }
    // }

    // void transitionBetweenModes(int i){
    //     //calculate the positions of the cubes as we transition between modes
    //     //once the transition is done, we then set the transitioning to false
    //     if(transitioning){
    //         if(mode == 1){
    //             //sprocket rules
    //             yf[i] = yf[i] + myFFT.getBand(i)/1000;
    //             xf[i] = xf[i] + myFFT.getFreq(i)/1000;
    //             angle[i] = angle[i] + myFFT.getFreq(i)/10000*speed;
    //         }
    //         else if (mode == 2){
    //             //grid rules
    //             //for this rule set, we may not need to always update the position and only calculate it once
    //             if( i%(horizontalGridCubeSpacing) == 0){
    //                 gridVerticalIncrementer++;
    //                 if(gridVerticalIncrementer%(verticalGridCubeSpacing) == 0) gridVerticalIncrementer = 0;
    //             }
    //             xf[i] = i%(horizontalGridCubeSpacing)*(myWidth/horizontalGridCubeSpacing)-myWidth/2;
    //             yf[i] = gridVerticalIncrementer%(verticalGridCubeSpacing)*(myHeight/verticalGridCubeSpacing)-myHeight/2;
    //             zf[i] = 0;
    //         }
    //         else if (mode == 3){
    //             xf[i] = random(leftWall,rightWall);
    //             yf[i] = random(topWall,bottomWall);
    //             zf[i] = random(frontWall/2,backWall/2);
    //         }
    //         else if (mode == 4){
    //             xf[i] = random(leftWall/2,rightWall/2);
    //             yf[i] = random(topWall/2,bottomWall/2);
    //             zf[i] = random(frontWall/4,backWall/4);
    //         } 
    //         x[i] = lerp(x[i],xf[i],transitionalPositionIncrementer/totalTransitionIncrements);
    //         y[i] = lerp(y[i],yf[i],transitionalPositionIncrementer/totalTransitionIncrements);
    //         z[i] = lerp(z[i],zf[i],transitionalPositionIncrementer/totalTransitionIncrements);
    //     }
    // }
}