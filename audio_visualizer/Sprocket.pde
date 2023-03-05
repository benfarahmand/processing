class Sprocket {
    float[] angle;
    float[] y, x, z, xf,yf,zf; //two sets of position arrays for transitioning between certain modes
    float[] vx, vy, vz; //velocities for gravity mode
    int mode = 5, lastMode = 5;
    float[] centerColor;
    FFT myFFT;
    boolean transitioning = false;
    float transitionalPositionIncrementer = 0.0, totalTransitionIncrements = 40.0;
    float myWidth, myHeight;
    float horizontalGridCubeSpacing, verticalGridCubeSpacing, gridVerticalIncrementer;
    float modeTransitionTimer = 0.0, modeTransitionTimerDuration = 2000.0; //if the beats are low for more than 3 seconds, switch the mode
    //boundary condition for the gravity mode
    float leftWall, rightWall, frontWall, backWall, topWall, bottomWall;
    PImage skullTop, skullBottom;
    float mouthY = 0.0, lastMouthY = 0.0, mouthIncrementer = 0.0, mouthTotalIncrements = 5.0, skullAngle=0.0;
    float skullRotateTimer = 0.0, skullRotateStayStillDuration = 2000.0, rotateDirection = 1.0;
    boolean isSkullRotating = false;
    float skullEyesRadius = 20.0;

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
        leftWall = -myWidth/2;
        rightWall = myWidth/2;
        frontWall = -250;
        backWall = 250;
        topWall = -myHeight/2;
        bottomWall = myHeight/2;
        skullBottom = loadImage("assets/skull_bottom_cropped_3.png");
        skullTop = loadImage("assets/skull_top_cropped_3.png");
        textureMode(NORMAL);
        textureWrap(CLAMP);
        skullRotateTimer=millis();
    }

    void draw(){
        // this.modeTransitioner();
        noStroke();
        pushMatrix();
        cameraTracker();
        translate(width/2, height/2, 0);
        if(mode < 5 ){
            for (int i = 0; i < myFFT.specSize(); i++) {
                // if(i%4==0) fill(360,100,100);
                // else if (i%4==1) fill(180,100,100);
                // else if (i%4==2) fill(90,100,100);
                // else if (i%4==3) fill(270,100,100);
                fill(this.colorChanger(i, true));
                this.calculatePosition(i);
                this.moveCube(i);
            }
        } else {
            if (mode == 5){
                float avgBand = 0.0;
                float avgFreq = 0.0;
                for (int i = 0; i < myFFT.specSize(); i++) {
                    avgBand+=myFFT.getBand(i);
                    avgFreq+=myFFT.getFreq(i);
                }
                avgBand=avgBand/myFFT.specSize();
                avgFreq=avgFreq/myFFT.specSize();
                tint(
                    map(avgFreq*speed, 0, 512, 0, 360),
                    map(avgFreq, 0, 1024, 0, 100)+colorScale,
                    100.0
                );
                translate(0,-myWidth/10,bpm.getBPM()*10);
                pushMatrix();
                translate(0,skullTop.height/4+lerp(lastMouthY,mouthY,mouthIncrementer/mouthTotalIncrements),-100);
                beginShape();
                texture(skullBottom);
                vertex(-skullBottom.width/4, -skullBottom.height/4, 0, 0);
                vertex( skullBottom.width/4, -skullBottom.height/4, 1, 0);
                vertex( skullBottom.width/4,  skullBottom.height/4, 1, 1);
                vertex(-skullBottom.width/4,  skullBottom.height/4, 0, 1);
                endShape();
                popMatrix();
                rotate(skullAngle);
                // println(skullAngle % (2*PI));
                if((abs(skullAngle) % (2*PI)) < (PI/16) || (abs(skullAngle) % (2*PI) > (PI*31/16))){
                    if(isSkullRotating) {
                        skullRotateTimer = millis();
                        skullRotateStayStillDuration = random(10000.0,20000.0);
                        isSkullRotating = false;
                        rotateDirection=random(-4.0,4.0);
                        skullAngle = 0.0;
                    }
                } else {
                    isSkullRotating = true;
                }
                if(millis() - skullRotateTimer > skullRotateStayStillDuration) {
                    skullAngle = skullAngle + rotateDirection*avgBand;
                }
                if((millis() - skullRotateTimer > skullRotateStayStillDuration*.1) && (millis() - skullRotateTimer < skullRotateStayStillDuration*.9)){
                    fill(
                        map(avgFreq*speed, 0, 512, 360, 0),
                        map(avgFreq, 0, 1024, 100, 0),
                        map(avgBand, 0, 512, 100, 0)
                    );
                    pushMatrix();
                    translate(-skullTop.width/9+skullEyesRadius*.9,skullEyesRadius*1.5,skullEyesRadius+bpm.getBPM()*10);
                    sphere(avgFreq*sizeScale);
                    popMatrix();
                    pushMatrix();
                    translate(skullTop.width/9-skullEyesRadius*.9,skullEyesRadius*1.5,skullEyesRadius+bpm.getBPM()*10);
                    sphere(avgFreq*sizeScale);
                    popMatrix();
                }
                beginShape();
                texture(skullTop);
                vertex(-skullTop.width/4, -skullTop.height/4, 0, 0);
                vertex( skullTop.width/4, -skullTop.height/4, 1, 0);
                vertex( skullTop.width/4,  skullTop.height/4, 1, 1);
                vertex(-skullTop.width/4,  skullTop.height/4, 0, 1);
                endShape();
                if(mouthIncrementer>=mouthTotalIncrements){
                    mouthIncrementer=0.0;
                    lastMouthY = mouthY;
                    mouthY=avgFreq*8;
                } else mouthIncrementer++;
            }
        }
        popMatrix();
        this.modeTransitionTracker();
    }

    void switchColor(PImage img, color c){
        for(int x = 0 ; x < img.width ; x++){
            for(int y = 0 ; y < img.height ; y++){
                // println(brightness(img.get(x,y)));
                if(brightness(img.get(x,y))>1.0) {
                    img.set(x,y,c);
                }
            }
        }
    }

    void modeTransitionTracker(){
        if(transitioning){
            transitionalPositionIncrementer++;
            if(transitionalPositionIncrementer>=totalTransitionIncrements){
                yf = new float[myFFT.specSize()];
                xf = new float[myFFT.specSize()];
                zf = new float[myFFT.specSize()];
                vy = new float[myFFT.specSize()];
                vx = new float[myFFT.specSize()];
                vz = new float[myFFT.specSize()];
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
                float velocityDamp = 0.1;
                for(int j = 0 ; j < myFFT.specSize() ; j++){
                    if(i!=j){
                        if(dist(x[i],y[i],z[i],x[j],y[j],z[j])<200){
                            vx[i] = vx[i] + (x[j] - x[i])*.00001*massAdjuster;
                            vy[i] = vy[i] + (y[j] - y[i])*.00001*massAdjuster;
                            vz[i] = vz[i] + (z[j] - z[i])*.00001*massAdjuster;
                            // if(dist(x[i],y[i],z[i],x[j],y[j],z[j])<20){
                            //     vx[i] = vx[i]*velocityDamp + (x[j] - x[i])*-.0001;
                            //     vy[i] = vy[i]*velocityDamp + (y[j] - y[i])*-.0001;
                            //     vz[i] = vz[i]*velocityDamp + (z[j] - z[i])*-.0001;
                            //     if(dist(x[i],y[i],z[i],x[j],y[j],z[j])<15){
                            //         vx[i] = vx[i] + (x[j] - x[i])*-1.1;
                            //         vy[i] = vy[i] + (y[j] - y[i])*-1.1;
                            //         vz[i] = vz[i] + (z[j] - z[i])*-1.1;
                            //     }
                            // }
                        }
                    }
                }
                x[i] = x[i] + vx[i]*volumeAdjuster;
                y[i] = y[i] + vy[i]*volumeAdjuster;
                z[i] = z[i] + vz[i]*volumeAdjuster;
                if(x[i]<leftWall){
                    x[i]=leftWall;
                    vx[i]=-vx[i]*velocityDamp;
                }
                else if(x[i]>rightWall){
                    x[i]=rightWall;
                    vx[i]=-vx[i]*velocityDamp;
                }
                if(y[i]<topWall){
                    y[i]=topWall;
                    vy[i]=-vy[i]*velocityDamp;
                }
                else if(y[i]>bottomWall){
                    y[i]=bottomWall;
                    vy[i]=-vy[i]*velocityDamp;
                }
                if(z[i]<frontWall){
                    z[i]=frontWall;
                    vz[i]=-vz[i]*velocityDamp;
                }
                else if(z[i]>backWall){
                    z[i]=backWall;
                    vz[i]=-vz[i]*velocityDamp;
                }
            }
            else if (mode == 4){
                //curtain in the wind rules
                //or particles with connecting lines and instead color the lines and increase the line thickness
                //based on the volume and stuff
                float volumeAdjuster = myFFT.getBand(i)/10;
                float massAdjuster = myFFT.getFreq(i)*2;
                float velocityDamp = 0.0;
                for(int j = 0 ; j < myFFT.specSize() ; j++){
                    if(i!=j){
                        if(i%4==0){  //creature zero
                            if(j%4==0){
                                creatureRule(i,j,300,0.05,massAdjuster,-0.9);//i, j, dist, str, adj
                            } else if (i%4==1) { 
                                creatureRule(i,j,150,0.1,massAdjuster,1.0);//i, j, dist, str, adj
                            } else if (i%4==2) {
                                creatureRule(i,j,500,-0.001,massAdjuster,-2.0);//i, j, dist, str, adj
                            } else if (i%4==3) {
                                creatureRule(i,j,400,1.2,massAdjuster,1.0);//i, j, dist, str, adj
                            }
                        } else if (i%4==1) { //creature one
                            if(j%4==0){
                                creatureRule(i,j,150,-0.01,massAdjuster,0.8);//i, j, dist, str, adj
                            } else if (i%4==1) { 
                                creatureRule(i,j,200,0.2,massAdjuster,-0.8);//i, j, dist, str, adj
                            } else if (i%4==2) {
                                creatureRule(i,j,500,0.1,massAdjuster,0.8);//i, j, dist, str, adj
                            } else if (i%4==3) {
                                creatureRule(i,j,150,0.01,massAdjuster,-1.0);//i, j, dist, str, adj
                            }
                        } else if (i%4==2) { //creature two
                            if(j%4==0){
                                creatureRule(i,j,1000,0.01,massAdjuster,1.0);//i, j, dist, str, adj
                            } else if (i%4==1) { 
                                creatureRule(i,j,1000,0.01,massAdjuster,1.0);//i, j, dist, str, adj
                            } else if (i%4==2) {
                                creatureRule(i,j,1000,0.05,massAdjuster,-0.92);//i, j, dist, str, adj
                            } else if (i%4==3) {
                                creatureRule(i,j,1000,0.01,massAdjuster,1.0);//i, j, dist, str, adj
                            }
                        } else if (i%4==3) { //creature three
                            if(j%4==0){
                                creatureRule(i,j,500,1.0,massAdjuster,-0.5);//i, j, dist, str, adj
                            } else if (i%4==1) {
                                creatureRule(i,j,50,-0.01,massAdjuster,1.0);//i, j, dist, str, adj
                            } else if (i%4==2) {
                                creatureRule(i,j,100,-0.0001,massAdjuster,1.0);//i, j, dist, str, adj
                            } else if (i%4==3) {
                                creatureRule(i,j,400,0.05,massAdjuster,-0.92);//i, j, dist, str, adj
                            }
                        }
                    }
                }
                x[i] = x[i] + vx[i]*volumeAdjuster;
                y[i] = y[i] + vy[i]*volumeAdjuster;
                z[i] = z[i] + vz[i]*volumeAdjuster;
                if(x[i]<leftWall){
                    x[i]=random(leftWall,rightWall);
                    vx[i]=vx[i]*velocityDamp;
                }
                else if(x[i]>rightWall){
                    x[i]=random(leftWall,rightWall);
                    vx[i]=vx[i]*velocityDamp;
                }
                if(y[i]<topWall){
                    y[i]=random(topWall,bottomWall);;
                    vy[i]=vy[i]*velocityDamp;
                }
                else if(y[i]>bottomWall){
                    y[i]=random(topWall,bottomWall);;
                    vy[i]=vy[i]*velocityDamp;
                }
                if(z[i]<frontWall){
                    z[i]=random(frontWall,backWall);
                    vz[i]=vz[i]*velocityDamp;
                }
                else if(z[i]>backWall){
                    z[i]=random(frontWall,backWall);
                    vz[i]=vz[i]*velocityDamp;
                }
            }
        }
    }

    void creatureRule(int i, int j, float distance, float strength, float massAdjuster, float damp){
        if(dist(x[i],y[i],z[i],x[j],y[j],z[j])<distance){
            vx[i] = vx[i] + (x[j] - x[i])*strength*massAdjuster;
            vy[i] = vy[i] + (y[j] - y[i])*strength*massAdjuster;
            vz[i] = vz[i] + (z[j] - z[i])*strength*massAdjuster;
            if(dist(x[i],y[i],z[i],x[j],y[j],z[j])<distance/10){
                vx[i] = vx[i]*damp;
                vy[i] = vy[i]*damp;
                vz[i] = vz[i]*damp;
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
                box((myFFT.getBand(i)+myFFT.getFreq(i))*sizeScale/40);
                popMatrix();
            }
            else if (mode == 3){
                pushMatrix();
                translate(x[i], y[i], z[i]);
                sphere((myFFT.getBand(i)+myFFT.getFreq(i))*sizeScale/20+1);
                popMatrix();
            }
            else if (mode == 4){
                pushMatrix();
                translate(x[i], y[i], z[i]);
                sphere((myFFT.getBand(i)+myFFT.getFreq(i))*sizeScale/50+0.5);
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
                xf[i] = random(leftWall,rightWall);
                yf[i] = random(topWall,bottomWall);
                zf[i] = random(frontWall/2,backWall/2);
            }
            else if (mode == 4){
                xf[i] = random(leftWall/2,rightWall/2);
                yf[i] = random(topWall/2,bottomWall/2);
                zf[i] = random(frontWall/4,backWall/4);
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
            if(i>5)i=1;
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
