class Visualize_Angel {
    FFT myFFT;
    float[] angle, freq, band, wingAngles, wingFreq, wingBands;
    PImage wingLeft, wingRight, body;
    int numberOfWings = 50;
    float angelEyesRadius = 20.0;

    Visualize_Angel(FFT _fft){
        myFFT=_fft;
        angle = new float[myFFT.specSize()];
        freq = new float[myFFT.specSize()];
        band = new float[myFFT.specSize()];
        wingAngles = new float[numberOfWings];
        wingBands = new float[numberOfWings];
        wingFreq = new float[numberOfWings];
        wingLeft = loadImage("assets/angel_wing_left.png");
        wingRight = loadImage("assets/angel_wing_right.png");
        textureMode(NORMAL);
        textureWrap(CLAMP);
    }

    void draw(){
        noStroke();
        pushMatrix();
        cameraTracker();
        translate(width/2, height/2, 0);
        // float avgBand = 0.0;
        // float avgFreq = 0.0;
        for (int i = 0; i < myFFT.specSize(); i++) {
            // avgBand+=myFFT.getBand(i);
            // avgFreq+=myFFT.getFreq(i);
            freq[i] = myFFT.getFreq(i);
            band[i] = myFFT.getBand(i);
            angle[i] = angle[i] + myFFT.getFreq(i)/100;
        }
        // avgBand=avgBand/myFFT.specSize();
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

            fill(
                map(wingFreq[i]*speed, 0, 512, 0, 360),
                map(wingFreq[i], 0, 1024, 0, 100)+colorScale,
                100.0
            );
            pushMatrix();
            // translate(cos(wingAngles[i]-i*(PI)/numberOfWings)*100,sin(wingAngles[i]-i*(PI)/numberOfWings)*100,-angelEyesRadius*numberOfWings+10*i);
            translate(0,sin(wingAngles[i]-i*(PI)/numberOfWings)*300+100,-angelEyesRadius*numberOfWings+10*i);
            sphere(-angelEyesRadius/numberOfWings+10*i/numberOfWings+cos(wingAngles[i]-i*(PI)/numberOfWings)*10);
            popMatrix();
        }
        
        popMatrix();
    }

    void initMode(){
        //init not required, continue straight to draw
        //place holder in case we want to add some init animation
    }
}