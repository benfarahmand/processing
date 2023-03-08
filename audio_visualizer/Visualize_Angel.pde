//options for eyes: 
//https://github.com/adafruit/Uncanny_Eyes
//https://github.com/adafruit/Adafruit_Learning_System_Guides/tree/main/M4_Eyes


class Visualize_Angel {
    FFT myFFT;
    float[] angle, freq, band, wingAngles, wingFreq, wingBands;
    PImage wingLeft, wingRight;//, eye;
    // PShape eyeShape;
    int numberOfWings = 50;
    Eye myEyes[];
    int eyeCount = 20;
    // float angelEyesRadius = 20.0;

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
        myEyes = new Eye[eyeCount];
        for(int i = 0 ; i < myEyes.length ; i ++){
            myEyes[i] = new Eye(random(-150.0,150.0),random(-150.0,150.0),0.0,random(10.0,20.0));
        }
        spaceCircles();
    }

    void spaceCircles(){
        for(int i = 0 ; i < myEyes.length ; i ++){
            for(int j = 0 ; j < myEyes.length ;j++){
                if(i!=j){
                    float dx = - myEyes[i].x + myEyes[j].x;
                    float dy = - myEyes[i].y + myEyes[j].y;
                    float d = sqrt(dx * dx + dy * dy);
                    if(d<(myEyes[i].radius+myEyes[j].radius)*1.5){
                        myEyes[i].x=random(-150.0,150.0);
                        myEyes[i].y=random(-150.0,175.0);
                        // myEyes[j].x=myEyes[j].x-dx;
                        // myEyes[j].y=myEyes[j].y-dy;
                    }
                }
            }
        }
        boolean stillOverlapping = false;
        for(int i = 0 ; i < myEyes.length ; i ++){
            for(int j = 0 ; j < myEyes.length ;j++){
                if(i!=j){
                    float dx = - myEyes[i].x + myEyes[j].x;
                    float dy = - myEyes[i].y + myEyes[j].y;
                    float d = sqrt(dx * dx + dy * dy);
                    if(d<(myEyes[i].radius+myEyes[j].radius)){
                        stillOverlapping = true;
                    }
                }
            }
        }
        if(stillOverlapping) spaceCircles();
    }

    void draw(){
        noStroke();
        pushMatrix();
        cameraTracker();
        translate(width/2, height/2, 0);
        for (int i = 0; i < myFFT.specSize(); i++) {
            freq[i] = myFFT.getFreq(i);
            band[i] = myFFT.getBand(i);
            angle[i] = angle[i] + myFFT.getFreq(i)/100;
        }
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
            translate(-wingLeft.width*1.25,0,-10*numberOfWings+10*i);
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
            translate(wingRight.width*1.25,0,-10*numberOfWings+10*i);
            texture(wingRight);
            vertex(-wingRight.width/2, -wingRight.height/2, 0, 0);
            vertex( wingRight.width/2, -wingRight.height/2, 1, 0);
            vertex( wingRight.width/2,  wingRight.height/2, 1, 1);
            vertex(-wingRight.width/2,  wingRight.height/2, 0, 1);
            endShape();
            popMatrix();
        }
        for(int i = 0 ; i < myEyes.length ; i++){
            pushMatrix();
            translate(myEyes[i].x,myEyes[i].y,myEyes[i].z);
            myEyes[i].drawEye();
            popMatrix();
        }
        
        popMatrix();
    }

    void initMode(){
        //init not required, continue straight to draw
        //place holder in case we want to add some init animation
    }
}