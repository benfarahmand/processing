// inspired by Daniel Shiffman's inverse kinematics: https://github.com/CodingTrain/website-archive/tree/main/CodingChallenges

class Visualize_Tentacles implements Visualizer {
    String NAME = "Tentacles";
    float[] angle;
    float[] y, x, z, vx, vy, vz;
    float[] centerColor;
    float[] freq;
    float myWidth, myHeight;
    FFT myFFT;
    Eye myEye;
    float eyeDiameter = 100;
    int numberOfTentacles = 20;
    int numberOfTentacleSegments = 130;
    Tentacle tentacles[];
    int[][] myColors;
    float leftWall, rightWall, frontWall, backWall, topWall, bottomWall;
    boolean repel = false;
    

    Visualize_Tentacles(FFT _fft){
        myFFT = _fft;
        freq = new float[myFFT.specSize()];
        y = new float[numberOfTentacles];
        x = new float[numberOfTentacles];
        z = new float[numberOfTentacles];
        angle = new float[numberOfTentacles];
        myWidth = parseFloat(width);
        myHeight = parseFloat(height);
        centerColor = new float[3];
        centerColor[0] = 0.0;
        centerColor[1] = 15.0;
        centerColor[2] = 90.0;

        myColors = new int[numberOfTentacleSegments][3];
        tentacles = new Tentacle[numberOfTentacles];
        for( int i = 0 ; i < tentacles.length ; i ++){
            float x = width/2;//eyeDiameter*cos(i/tentacles.length)+width/2;
            float y = height/2;//eyeDiameter*sin(i/tentacles.length)+height/2;
            tentacles[i] = new Tentacle(numberOfTentacleSegments,x,y);
        }

        myEye = new Eye(width/2,height/2,0,eyeDiameter,false);

        vy = new float[numberOfTentacles];
        vx = new float[numberOfTentacles];
        vz = new float[numberOfTentacles];
        leftWall = 0;
        rightWall = myWidth;
        frontWall = -20;
        backWall = 20;
        topWall = 0;
        bottomWall = myHeight;
    }

    @Override
    void draw(){
        //calculate the tentacle colors
        // for(int i = 0 ; i < tentacles.length ; i ++){
        //     float avgFreq = 0.0;
        //     for(int j = i * myFFT.specSize()/tentacles.length ; j < (i+1)*(myFFT.specSize()/tentacles.length) ; j++){
        //         freq[i] = freq[i] + myFFT.getFreq(i)/10000;
        //         avgFreq = avgFreq + freq[i];
        //     }
        //     avgFreq = avgFreq / (myFFT.specSize()/tentacles.length);
        //     // println(i);
        //     x[i] = eyeDiameter*2 * cos(avgFreq+i*2*(PI)/numberOfTentacles)+random(10,50) + width*i/tentacles.length;
        //     y[i] = eyeDiameter*2 * sin(avgFreq+i*2*(PI)/numberOfTentacles)+random(10,50) + height*i/tentacles.length;
        // }

        
        float soundAffect = 0.0;
        for(int i = 0 ; i <  numberOfTentacleSegments; i++){
            float avgFreq = 0.0;
            for(int j = i * myFFT.specSize()/numberOfTentacleSegments ; j < (i+1)*(myFFT.specSize()/numberOfTentacleSegments) ; j++){
                avgFreq = avgFreq + myFFT.getFreq(i);
            }
            myColors[i][0] = int(map(avgFreq, 0, 200, 0, 360)+5);
            myColors[i][1] = int(map(avgFreq, 0, 1024, 0, 100)+50);
            myColors[i][2] = 100;
            avgFreq=avgFreq/(myFFT.specSize()/numberOfTentacleSegments);
            if(avgFreq>soundAffect)soundAffect=avgFreq;
        }

        float[] look = calculatePosition(soundAffect);
        
        // noStroke();
        for(int i = 0 ; i < tentacles.length ; i++){
            pushMatrix();
            tentacles[i].drawTentacle(x[i], y[i], myColors);
            popMatrix();
        }

        pushMatrix();
        translate(width/2,height/2);
        fill(color(myColors[0][0],myColors[0][1],100));
        sphere(eyeDiameter/10);
        // translate(myEye.x,myEye.y);
        // myEye.lookAtXY(look[0],look[1]);
        // // rotateY(PI/2);
        // myEye.setTint(color(myColors[0][0],myColors[0][1],100));
        // myEye.drawEye();
        popMatrix();
    }

    
    @Override
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

    @Override
    void initMode(){
        //no init for this mode, can go straight to drawing
        for(var i = 0 ; i < numberOfTentacles ; i++){
            x[i] = random(leftWall,rightWall);
            y[i] = random(topWall,bottomWall);
            z[i] = random(frontWall,backWall);
        }
    }

    @Override
    void endMode() {}   

    @Override
    String getName(){
        return NAME;
    }

    float[] calculatePosition(float soundAffect){
        float velocityDamp = 0.8;
        float avgX = myWidth/2.0;
        float avgY = myHeight/2.0;
        // int repelCount = 0;
        for(int i = 0 ; i < numberOfTentacles; i ++){
            float fx = 0;
            float fy = 0;
            float fz = 0;
            for(int j = 0 ; j < numberOfTentacles; j++){
                if(i!=j){
                    float dx = x[j] - x[i];
                    float dy = y[j] - y[i];
                    float dz = z[j] - z[i];
                    float d = sqrt(dx * dx + dy * dy + dz * dz);
                    if(d<1000){
                        float force = (1) / (d * soundAffect * 10000);
                        // if(repel) force=force*-1;
                        // if(j==numberOfTentacles){
                        //     force = force * numberOfTentacles;
                        // }
                        fx = fx + force * dx;
                        fy = fy + force * dy;
                        fz = fz + force * dz;
                        // if(d<100){
                        //     // repelCount++;
                        //     float r = -1;
                        //     fx = fx * r * 5;
                        //     fy = fy * r * 5;
                        //     fz = fz * r * 5;
                        // } 
                        vx[i] = (vx[i] + fx);
                        vy[i] = (vy[i] + fy);
                        vz[i] = (vz[i] + fz);
                    }
                }
            }
            // if(i == numberOfTentacles) {
            //     x[i] = width/2;
            //     y[i] = height/2;
            //     z[i] = 0;
            // } else {
                x[i] = x[i] + vx[i];//*volumeAdjuster;
                y[i] = y[i] + vy[i];//*volumeAdjuster;
                z[i] = z[i] + vz[i];//*volumeAdjuster;
                avgX = avgX + x[i];
                avgY = avgY + y[i];
            // }
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
        float[] r = new float[2];
        r[0] = avgX/float(numberOfTentacles)*1.25;
        r[1] = avgY/float(numberOfTentacles)*1.25;
        // println("X: "+avgX + " Y: "+avgY);
        return r;
    }
    
}
