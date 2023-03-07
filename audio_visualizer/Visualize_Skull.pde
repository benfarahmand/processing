class Visualize_Skull {
    float[] centerColor;
    FFT myFFT;
    float myWidth, myHeight;
    PImage skullTop, skullBottom;
    float mouthY = 0.0, lastMouthY = 0.0, mouthIncrementer = 0.0, mouthTotalIncrements = 5.0, skullAngle=0.0;
    float skullRotateTimer = 0.0, skullRotateStayStillDuration = 2000.0, rotateDirection = 1.0;
    boolean isSkullRotating = false;
    float skullEyesRadius = 20.0;

    Visualize_Skull(FFT _fft){
        myFFT = _fft;
        myWidth = parseFloat(width);
        myHeight = parseFloat(height);
        centerColor = new float[3];
        centerColor[0] = 0.0;
        centerColor[1] = 15.0;
        centerColor[2] = 90.0;
        skullBottom = loadImage("assets/skull_bottom_cropped_3.png");
        skullTop = loadImage("assets/skull_top_cropped_3.png");
        textureMode(NORMAL);
        textureWrap(CLAMP);
        skullRotateTimer=millis();
    }

    void draw(){
        noStroke();
        pushMatrix();
        cameraTracker();
        translate(width/2, height/2, 0);
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
        popMatrix();
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
        //init not required, continue straight to draw
        //place holder in case we want to add some init animation
    }
}
