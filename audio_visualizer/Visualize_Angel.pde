//options for eyes: 
//https://github.com/adafruit/Uncanny_Eyes
//https://github.com/adafruit/Adafruit_Learning_System_Guides/tree/main/M4_Eyes


class Visualize_Angel implements Visualizer {
    String NAME = "Angel";
    FFT myFFT;
    float[] angle, freq, band, wingAngles, wingFreq, wingBands;
    float[] eyeLookX, eyeLookY;
    PImage wingLeft, wingRight;
    int numberOfWings = 6;
    Eye myEyes[];
    int eyeCount = 40;
    float innerCircleRadius = 500.0;
    int spaceCounter = 100;

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
            float x = random(-innerCircleRadius/5.0,innerCircleRadius/5.0);
            float y = random(-innerCircleRadius/5.0,innerCircleRadius/5.0);
            if(i==0) myEyes[i] = new Eye(0,0,0,50, true);
            else myEyes[i] = new Eye(x,y,0.0,random(10.0,20.0), true);
        }
        eyeLookX = new float[myEyes.length];
        eyeLookY = new float[myEyes.length];
        spaceCircles(spaceCounter);
    }

    void spaceCircles(int spaceCounter){
        for(int i = 0 ; i < myEyes.length ; i ++){
            for(int j = 0 ; j < myEyes.length ;j++){
                if(i!=j && i!=0){
                    float dx = - myEyes[i].x + myEyes[j].x;
                    float dy = - myEyes[i].y + myEyes[j].y;
                    float d = sqrt(dx * dx + dy * dy);
                    if(d<(myEyes[i].radius+myEyes[j].radius*1.1)){
                        if(i%3==0){
                            myEyes[i].x=random(-innerCircleRadius*0.1,innerCircleRadius*0.1);
                            myEyes[i].y=random(-innerCircleRadius*0.85,innerCircleRadius*0.85);
                        } else if (i%3==1){
                            myEyes[i].x=random(-innerCircleRadius*0.6,innerCircleRadius*0.6);
                            myEyes[i].y=random(-innerCircleRadius*0.2,innerCircleRadius*0.2);
                        } else {
                            myEyes[i].x=random(-innerCircleRadius*0.4,innerCircleRadius*0.4);
                            myEyes[i].y=random(-innerCircleRadius*0.4,innerCircleRadius*0.4);
                        }
                        
                    }
                }
            }
        }
        boolean stillOverlapping = false;
        for(int i = 0 ; i < myEyes.length ; i ++){
            // float circleD = sqrt(myEyes[i].x*myEyes[i].x + myEyes[i].y*myEyes[i].y);
            for(int j = 0 ; j < myEyes.length ;j++){
                if(i!=j){
                    float dx = - myEyes[i].x + myEyes[j].x;
                    float dy = - myEyes[i].y + myEyes[j].y;
                    float d = sqrt(dx * dx + dy * dy);
                    if(d<(myEyes[i].radius+myEyes[j].radius)*1.1){
                        stillOverlapping = true;
                    }
                }
            }
        }
        spaceCounter--;
        if(stillOverlapping && spaceCounter>0) spaceCircles(spaceCounter); //this shouldn't take more than a second or two
    }

    @Override
    void draw(){
        noStroke();
        pushMatrix();
        cameraTracker();
        translate(width/2, height/2, 0);
        float bounce = 0.0;
        for (int i = 0; i < myFFT.specSize(); i++) {
            bounce = bounce + myFFT.getFreq(i);
            freq[i] = myFFT.getFreq(i);
            band[i] = myFFT.getBand(i);
            angle[i] = angle[i] + myFFT.getFreq(i)/100;
        }
        bounce = bounce / myFFT.specSize();
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
            if(i>numberOfWings-4) scale(1,-1,1);
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
            float avgLookX = 0.0;
            float avgLookY = 0.0;
            for(int j = i*myFFT.specSize()/myEyes.length ; j < (i+1)*myFFT.specSize()/myEyes.length ; j++){
                avgLookX = avgLookX + freq[i];
                avgLookY = avgLookY + band[i];
            }
            eyeLookX[i] = eyeLookX[i] + (avgLookX/(myFFT.specSize()/myEyes.length))/100;
            eyeLookY[i] = eyeLookY[i] + (avgLookY/(myFFT.specSize()/myEyes.length))/100;
        }

        //the zero-th eye is the big center eye, skip that and then calculate distances from the others
        for(int i = 0 ; i < myEyes.length ; i++){ 
            float dx = 0.0;
            float dy = 0.0;
            if(i!=0){
                dx = (myEyes[i].x - myEyes[0].x)*bounce/100;
                dy = (myEyes[i].y - myEyes[0].y)*bounce/100;
            }
            pushMatrix();
            translate(myEyes[i].x+dx,myEyes[i].y+dy,myEyes[i].z);
            myEyes[i].lookAtXY(
                width/4 * max(map(bpm.getBPM(), 1.0, 8.0, 1.0, 0.0),0.0) * sin(eyeLookX[i]) + width/2,
                height/4 * max(map(bpm.getBPM(), 1.0, 8.0, 1.0, 0.0),0.0) * cos(eyeLookY[i]) + height/2
                );
            // if(bpm.getBPM()>7) myEyes[i].lookAtXY(width/4*sin(eyeLookX[i])+width/2,height/4*cos(eyeLookY[i])+height/2);
            // else myEyes[i].lookAtXY(width/2,height/2);
            myEyes[i].drawEye();
            popMatrix();
        }
        
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

    @Override
    color colorChanger(int i, boolean b) {
        if (b) return color(
            map(myFFT.getFreq(i) * speed, 0, 512, 0, 360),
            map(myFFT.getFreq(i), 0, 1024, 0, 100)+colorScale,
            map(myFFT.getBand(i), 0, 512, 100, 0)
            );
        else return color(
            map(myFFT.getFreq(i) * speed, 0, 512, 360, 0),
            map(myFFT.getFreq(i), 0, 1024, 100, 0),
            map(myFFT.getBand(i), 0, 512, 100, 0)
            );
    }
}