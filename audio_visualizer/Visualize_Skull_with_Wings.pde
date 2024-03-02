class Visualize_Skull_with_Wings implements Visualizer {
    String NAME = "Skull with Wings";
    FFT myFFT;
    float myWidth, myHeight;
    float[] angle, freq, band, wingAngles, wingFreq, wingBands;
    PImage wingLeft, wingRight, body, eye, eyeLidTop;
    PShape eyeShape, eyeLid;
    int numberOfWings = 6;
    float angelEyesRadius = 20.0;

    PImage skullTop, skullBottom;
    float mouthY = 0.0, lastMouthY = 0.0, mouthIncrementer = 0.0, mouthTotalIncrements = 5.0, skullAngle=0.0;
    float skullRotateTimer = 0.0, skullRotateStayStillDuration = 2000.0, rotateDirection = 1.0;
    boolean isSkullRotating = false;
    float skullEyesRadius = 20.0;

    Visualize_Skull_with_Wings(FFT _fft){
        myFFT=_fft;
        myWidth = parseFloat(width);
        myHeight = parseFloat(height);
        angle = new float[myFFT.specSize()];
        freq = new float[myFFT.specSize()];
        band = new float[myFFT.specSize()];
        wingAngles = new float[numberOfWings];
        wingBands = new float[numberOfWings];
        wingFreq = new float[numberOfWings];
        wingLeft = loadImage("assets/skeleton_wing_left.png");
        wingRight = loadImage("assets/skeleton_wing_right.png");
        eye = loadImage("assets/eye_white_2.jpg");
        eyeLidTop = loadImage("assets/lid-upper-symmetrical.png");
        eyeShape = createShape(SPHERE,100); //http://processing.github.io/processing-javadocs/core/
        eyeShape.setStroke(false);
        eyeShape.rotateY(PI/2);
        eyeShape.setTexture(eye);
        eyeLid = createShape(SPHERE,100);
        eyeLid.setStroke(false);
        // eyeLid.rotateY(PI/2);
        // eyeLid.setTexture(eyeLidTop);
        eyeLid.scale(3,1,1);
        skullBottom = loadImage("assets/skull_bottom_cropped_3.png");
        skullTop = loadImage("assets/skull_top_cropped_3.png");
        skullRotateTimer=millis();
        textureMode(NORMAL);
        textureWrap(CLAMP);
    }

    @Override
    void draw(){
        noStroke();
        pushMatrix();
        cameraTracker();
        translate(width/2, height/2, 0);
        // float avgBand = 0.0;
        float avgEyeRot = 0.0;
        for (int i = 0; i < myFFT.specSize(); i++) {
            // avgBand+=myFFT.getBand(i);
            avgEyeRot+=myFFT.getFreq(i);
            freq[i] = myFFT.getFreq(i);
            band[i] = myFFT.getBand(i);
            angle[i] = angle[i] + myFFT.getFreq(i)/100;
        }
        avgEyeRot=avgEyeRot/myFFT.specSize();
        // println(avgBand);
        // avgFreq=avgFreq/myFFT.specSize();
        for(int i = 0 ; i < numberOfWings ; i++){
            float avgFreq = 0.0;
            float avgBand = 0.0;
            float avgAngle = 0.0;
            for(int j = i*myFFT.specSize()/numberOfWings ; j < (i+1)*myFFT.specSize()/numberOfWings ; j++){
                avgFreq = avgFreq + freq[i];
                avgBand = avgBand + band[i];
                avgAngle = avgAngle + angle[i];
            }
            wingFreq[i]=avgFreq/(myFFT.specSize()/numberOfWings);
            wingBands[i]=avgBand/(myFFT.specSize()/numberOfWings);
            wingAngles[i]=avgAngle/(myFFT.specSize()/numberOfWings);
        }

        for(int i = 0 ; i < numberOfWings ; i++){
            tint(
                map(wingFreq[i]*speed, 0, 512, 0, 360),
                map(wingFreq[i], 0, 1024, 0, 100)+colorScale,
                100.0
            );

            pushMatrix();
            if(i>numberOfWings-4) scale(1,-1,1);
            beginShape();
            rotate(sin(wingAngles[i]+i*(PI)/numberOfWings));
            translate(-wingLeft.width,0,-10*numberOfWings+10*i);
            texture(wingLeft);
            vertex(-wingLeft.width/2, -wingLeft.height/2, 0, 0);
            vertex( wingLeft.width/2, -wingLeft.height/2, 1, 0);
            vertex( wingLeft.width/2,  wingLeft.height/2, 1, 1);
            vertex(-wingLeft.width/2,  wingLeft.height/2, 0, 1);
            endShape();
            popMatrix();

            pushMatrix();
            if(i>numberOfWings-4) scale(1,-1,1);
            beginShape();
            rotate(sin(-wingAngles[i]-i*(PI)/numberOfWings));
            translate(wingRight.width,0,-10*numberOfWings+10*i);
            texture(wingRight);
            vertex(-wingRight.width/2, -wingRight.height/2, 0, 0);
            vertex( wingRight.width/2, -wingRight.height/2, 1, 0);
            vertex( wingRight.width/2,  wingRight.height/2, 1, 1);
            vertex(-wingRight.width/2,  wingRight.height/2, 0, 1);
            endShape();
            popMatrix();

            // fill(
            //     map(wingFreq[i]*speed, 0, 512, 0, 360),
            //     map(wingFreq[i], 0, 1024, 0, 100)+colorScale,
            //     100.0
            // );
            // pushMatrix();
            // translate(cos(wingAngles[i]-i*(PI)/numberOfWings)*100,sin(wingAngles[i]-i*(PI)/numberOfWings)*100,-angelEyesRadius*numberOfWings+10*i);
            // translate(0,sin(wingAngles[i]-i*(PI)/numberOfWings)*300+100,-angelEyesRadius*numberOfWings+10*i);
            // scale(3,1,1);
            // sphere(-angelEyesRadius/numberOfWings+10*i/numberOfWings+cos(wingAngles[i]-i*(PI)/numberOfWings)*10);
            // popMatrix();
        }
        // beginShape();
        // texture(eye);
        // vertex(-eye.width/2, -eye.height/2, 0, 0);
        // vertex( eye.width/2, -eye.height/2, 1, 0);
        // vertex( eye.width/2,  eye.height/2, 1, 1);
        // vertex(-eye.width/2,  eye.height/2, 0, 1);
        // endShape();
        translate(0,0,-numberOfWings*30*10);
        drawSkull();
        // pushMatrix();
        // rotateX(sin(avgEyeRot));
        // rotateY(cos(avgEyeRot));
        // shape(eyeShape,0,0);
        // popMatrix();

        // pushMatrix();
        // translate(0,-100+mouseY,0);
        // fill(color(0,0,0));
        // scale(1,1,1);
        // sphere(110);
        // popMatrix();

        // pushMatrix();
        // translate(0,100-mouseY,0);
        // fill(color(0,0,0));
        // scale(1,1,1);
        // sphere(100);
        // popMatrix();
        
        popMatrix();
    }

    @Override
    void initMode(){
        //init not required, continue straight to draw
        //place holder in case we want to add some init animation
    }

    @Override
    void endMode() {}   

    @Override
    String getName(){
        return NAME;
    }

    void drawSkull(){
        pushMatrix();
        float avgBand = 0.0;
        float avgFreq = 0.0;
        for (int i = 0; i < myFFT.specSize(); i++) {
            avgBand+=myFFT.getBand(i);
            avgFreq+=myFFT.getFreq(i);
        }
        avgBand=avgBand/myFFT.specSize();
        // println(avgBand);
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
}