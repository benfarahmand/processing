class Visualize_Particle_Rules {
    float[] y, x, z; //positions
    float[] vx, vy, vz; //velocities
    float[] centerColor;
    FFT myFFT;
    float myWidth, myHeight;
    float leftWall, rightWall, frontWall, backWall, topWall, bottomWall;
    int arraySize;
    boolean debug = false;
    
    Visualize_Particle_Rules(FFT _fft){
        myFFT = _fft;
        arraySize = myFFT.specSize();
        y = new float[arraySize];
        x = new float[arraySize];
        z = new float[arraySize];
        vy = new float[arraySize];
        vx = new float[arraySize];
        vz = new float[arraySize];
        myWidth = parseFloat(width);
        myHeight = parseFloat(height);
        centerColor = new float[3];
        centerColor[0] = 0.0;
        centerColor[1] = 15.0;
        centerColor[2] = 90.0;
        leftWall = -myWidth*0.4;
        rightWall = myWidth*0.4;
        frontWall = -10;
        backWall = 10;
        topWall = -myHeight*0.4;
        bottomWall = myHeight*0.4;
    }

    void draw(){
        pushMatrix();
        cameraTracker();
        translate(width/2, height/2, 0);
        for (int i = 0; i < arraySize; i++) {
            if(debug){
                if(i%4==0) fill(120,100,100);
                else if (i%4==1) fill(0,100,100);
                else if (i%4==2) fill(90,0,100);
                else if (i%4==3) fill(210,100,100);
            } else {
                // fill(this.colorChanger(i, true));
                stroke(this.colorChanger(i, true));
                strokeWeight(0.5);
            }
            this.calculatePosition(i);
            // noStroke();
            // this.moveCube(i);
        }
        popMatrix();
    }

    //interesting rules here: https://github.com/hunar4321/particle-life
    // void calculatePosition(int i){
    //     //curtain in the wind rules
    //     //or particles with connecting lines and instead color the lines and increase the line thickness
    //     //based on the volume and stuff
    //     float volumeAdjuster = myFFT.getBand(i)/10;
    //     float massAdjuster = myFFT.getFreq(i)/10;//map(mouseY,0,900,0,2000);// myFFT.getFreq(i)*2;
    //     float velocityDamp = 0.0;
    //     // float distanceAdjuster = map(mouseX,0,1440,0,800);//myFFT.getBand(i)*10;
    //     float strengthAdjuster = myFFT.getFreq(i)/myFFT.getBand(i);
    //     for(int j = 0 ; j < myFFT.specSize() ; j++){
    //         if(i!=j){
    //             if(i%4==0){  //creature zero
    //                 if(j%4==0){
    //                     // creatureRule(i,j,300,0.05,massAdjuster,-0.9);//i, j, dist, str, adj
    //                     atomRule(i,j,80,344,massAdjuster);
    //                 } else if (i%4==1) { 
    //                     // creatureRule(i,j,150,0.1,massAdjuster,1.0);//i, j, dist, str, adj
    //                     atomRule(i,j,80,200,massAdjuster);
    //                 } else if (i%4==2) {
    //                     // creatureRule(i,j,500,-0.001,massAdjuster,-2.0);//i, j, dist, str, adj
    //                     atomRule(i,j,80,200,massAdjuster);
    //                 } else if (i%4==3) {
    //                     // creatureRule(i,j,400,1.2,massAdjuster,1.0);//i, j, dist, str, adj
    //                     atomRule(i,j,80,200,massAdjuster);
    //                 }
    //             } else if (i%4==1) { //creature one
    //                 if(j%4==0){
    //                     // creatureRule(i,j,150,-0.01,massAdjuster,0.8);//i, j, dist, str, adj
    //                     atomRule(i,j,80,-0.01,massAdjuster);
    //                 } else if (i%4==1) { 
    //                     // creatureRule(i,j,200,0.2,massAdjuster,-0.8);//i, j, dist, str, adj
    //                     atomRule(i,j,80,strengthAdjuster,massAdjuster,-myFFT.getBand(j));//i, j, dist, str, adj
    //                 } else if (i%4==2) {
    //                     // creatureRule(i,j,500,0.1,massAdjuster,0.8);//i, j, dist, str, adj
    //                     atomRule(i,j,80,0.1,massAdjuster,0.8);//i, j, dist, str, adj
    //                 } else if (i%4==3) {
    //                     // creatureRule(i,j,150,0.01,massAdjuster,-1.0);//i, j, dist, str, adj
    //                     atomRule(i,j,80,0.01,massAdjuster,-myFFT.getBand(j));//i, j, dist, str, adj
    //                 }
    //             } else if (i%4==2) { //creature two
    //                 if(j%4==0){
    //                     // creatureRule(i,j,1000,0.01,massAdjuster,1.0);//i, j, dist, str, adj
    //                     atomRule(i,j,80,0.01,massAdjuster,myFFT.getFreq(i));
    //                 } else if (i%4==1) { 
    //                     // creatureRule(i,j,1000,0.01,massAdjuster,1.0);//i, j, dist, str, adj
    //                     atomRule(i,j,80,0.01,massAdjuster,myFFT.getFreq(i));
    //                 } else if (i%4==2) {
    //                     // creatureRule(i,j,1000,0.05,massAdjuster,-0.92);//i, j, dist, str, adj
    //                     atomRule(i,j,80,strengthAdjuster,massAdjuster,-myFFT.getBand(j));//i, j, dist, str, adj
    //                 } else if (i%4==3) {
    //                     // creatureRule(i,j,1000,0.01,massAdjuster,1.0);//i, j, dist, str, adj
    //                     atomRule(i,j,80,0.01,massAdjuster,myFFT.getFreq(i));
    //                 }
    //             } else if (i%4==3) { //creature three
    //                 if(j%4==0){
    //                     // creatureRule(i,j,500,1.0,massAdjuster,-0.5);//i, j, dist, str, adj
    //                     atomRule(i,j,80,1.0,massAdjuster,-myFFT.getBand(j));//i, j, dist, str, adj
    //                 } else if (i%4==1) {
    //                     // creatureRule(i,j,50,-0.01,massAdjuster,1.0);//i, j, dist, str, adj
    //                     atomRule(i,j,80,-0.01,massAdjuster,1.0);//i, j, dist, str, adj
    //                 } else if (i%4==2) {
    //                     // creatureRule(i,j,100,-0.0001,massAdjuster,1.0);//i, j, dist, str, adj
    //                     atomRule(i,j,80,-0.0001,massAdjuster,myFFT.getFreq(i));
    //                 } else if (i%4==3) {
    //                     // creatureRule(i,j,400,0.05,massAdjuster,-0.92);//i, j, dist, str, adj
    //                     atomRule(i,j,80,0.05,massAdjuster,-myFFT.getBand(j));//i, j, dist, str, adj
    //                 }
    //             }
    //         }
    //         drawLines(i,j,20);
    //     }
    //     x[i] = x[i] + vx[i]*volumeAdjuster;
    //     y[i] = y[i] + vy[i]*volumeAdjuster;
    //     z[i] = z[i] + vz[i]*volumeAdjuster;
    //     if(x[i]<leftWall){
    //         x[i]=random(leftWall,rightWall);
    //         vx[i]=vx[i]*velocityDamp;
    //     }
    //     else if(x[i]>rightWall){
    //         x[i]=random(leftWall,rightWall);
    //         vx[i]=vx[i]*velocityDamp;
    //     }
    //     if(y[i]<topWall){
    //         y[i]=random(topWall,bottomWall);;
    //         vy[i]=vy[i]*velocityDamp;
    //     }
    //     else if(y[i]>bottomWall){
    //         y[i]=random(topWall,bottomWall);;
    //         vy[i]=vy[i]*velocityDamp;
    //     }
    //     if(z[i]<frontWall){
    //         z[i]=random(frontWall,backWall);
    //         vz[i]=vz[i]*velocityDamp;
    //     }
    //     else if(z[i]>backWall){
    //         z[i]=random(frontWall,backWall);
    //         vz[i]=vz[i]*velocityDamp;
    //     }
    // }

    void calculatePosition(int i){
        //curtain in the wind rules
        //or particles with connecting lines and instead color the lines and increase the line thickness
        //based on the volume and stuff
        float volumeAdjuster = myFFT.getBand(i);
        float massAdjuster = myFFT.getFreq(i);//map(mouseY,0,900,0,2000);// myFFT.getFreq(i)*2;
        float velocityDamp = 0.5;
        // float distanceAdjuster = map(mouseX,0,1440,0,800);//myFFT.getBand(i)*10;
        // float strengthAdjuster = myFFT.getFreq(i)/myFFT.getBand(i);
        float fx = 0;
        float fy = 0;
        float fz = 0;
        for(int j = 0 ; j < myFFT.specSize() ; j++){
            if(i!=j){
                if(i%4==0){  //creature zero: green
                    if(j%4==0){
                        atomRule(i,j,344,16.5,massAdjuster,volumeAdjuster,fx,fy,fz,-50);
                    } //else if (j%4==1) { 
                        // atomRule(i,j,200,0,massAdjuster,volumeAdjuster,fx,fy,fz, 1);
                    // } else if (j%4==2) {
                        // atomRule(i,j,200,0,massAdjuster,volumeAdjuster,fx,fy,fz, 1);
                    // } else if (j%4==3) {
                        // atomRule(i,j,200,0,massAdjuster,volumeAdjuster,fx,fy,fz, 1);
                    // }
                } else if (i%4==1) { //creature one: red 
                    if(j%4==0){
                        atomRule(i,j,269.7,-20,massAdjuster,volumeAdjuster,fx,fy,fz, 1);
                    } else if (j%4==1) { 
                        atomRule(i,j,200,70.5,massAdjuster,volumeAdjuster,fx,fy,fz, -1);
                    } else if (j%4==2) {
                        // atomRule(i,j,200,0,massAdjuster,volumeAdjuster,fx,fy,fz, 1);
                    } else if (j%4==3) {
                        atomRule(i,j,241,31.5,massAdjuster,volumeAdjuster,fx,fy,fz, 1);
                    }
                } else if (i%4==2) { //creature two: white
                    if(j%4==0){
                        atomRule(i,j,316,14,massAdjuster,volumeAdjuster,fx,fy,fz, 1);
                    } else if (j%4==1) { 
                        atomRule(i,j,259,26,massAdjuster,volumeAdjuster,fx,fy,fz, -30);
                    } else if (j%4==2) {
                        atomRule(i,j,200,-46,massAdjuster,volumeAdjuster,fx,fy,fz, 1);
                    } //else if (j%4==3) {
                        // atomRule(i,j,200,0,massAdjuster,volumeAdjuster,fx,fy,fz, 1);
                    // }
                } else if (i%4==3) { //creature three: blue
                    if(j%4==0){
                        atomRule(i,j,230.5,15.5,massAdjuster,volumeAdjuster,fx,fy,fz, -20);
                    } else if (j%4==1) { 
                        atomRule(i,j,71,1.5,massAdjuster,volumeAdjuster,fx,fy,fz, -3);
                    } else if (j%4==2) {
                        atomRule(i,j,365,2.5,massAdjuster,volumeAdjuster,fx,fy,fz, -10);
                    } else if (j%4==3) {
                        atomRule(i,j,81,-13.5,massAdjuster,volumeAdjuster,fx,fy,fz, 1);
                    }
                }
            }
            if(!debug) drawLines(i,j,30);
        }
        x[i] = x[i] + vx[i];// * volumeAdjuster*100;
        y[i] = y[i] + vy[i];// * volumeAdjuster*100;
        z[i] = z[i] + vz[i];// * volumeAdjuster*100;
        if(x[i]<leftWall){
            x[i]=leftWall;//random(leftWall,rightWall);
            vx[i]=-vx[i]*velocityDamp;
        }
        else if(x[i]>rightWall){
            x[i]=rightWall;//random(leftWall,rightWall);
            vx[i]=-vx[i]*velocityDamp;
        }
        if(y[i]<topWall){
            y[i]=topWall;//random(topWall,bottomWall);;
            vy[i]=-vy[i]*velocityDamp;
        }
        else if(y[i]>bottomWall){
            y[i]=bottomWall;//random(topWall,bottomWall);;
            vy[i]=-vy[i]*velocityDamp;
        }
        if(z[i]<frontWall){
            z[i]=frontWall;//random(frontWall,backWall);
            vz[i]=-vz[i]*velocityDamp;
        }
        else if(z[i]>backWall){
            z[i]=backWall;//random(frontWall,backWall);
            vz[i]=-vz[i]*velocityDamp;
        }
    }

    void atomRule(int i, int j, float distance, float strength, float massAdjuster, float volumeAdjuster, float fx, float fy, float fz, float reverse){
        float dx = x[j] - x[i];
        float dy = y[j] - y[i];
        float dz = z[j] - z[i];
        float d = sqrt(dx * dx + dy * dy + dz * dz);
        float r = reverse*volumeAdjuster*50;
        if(d<distance){
            float force = ((strength) / (distance * massAdjuster));
            fx = fx + force * dx;
            fy = fy + force * dy;
            fz = fz + force * dz;
            if(reverse!=1){
                if(d<distance/10){
                    fx = fx * r;
                    fy = fy * r;
                    fz = fz * r;
                    // vx[i] = vx[i]*damp;
                    // vy[i] = vy[i]*damp;
                    // vz[i] = vz[i]*damp;
                }
            }
            vx[i] = (vx[i] + fx)*0.85;
            vy[i] = (vy[i] + fy)*0.85;
            vz[i] = (vz[i] + fz)*0.85;
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
        pushMatrix();
        translate(x[i], y[i], z[i]);
        sphere((myFFT.getBand(i)+myFFT.getFreq(i))*sizeScale/50+0.5);
        popMatrix();
    }

    void drawLines(int i, int j, float distance){
        if(dist(x[i],y[i],z[i],x[j],y[j],z[j])<distance){
            line(x[i],y[i],z[i],x[j],y[j],z[j]);
        }
    }

    void initMode(){
        for(var i = 0 ; i < myFFT.specSize() ; i++){
            x[i] = random(leftWall/2,rightWall/2);
            y[i] = random(topWall/2,bottomWall/2);
            z[i] = random(frontWall/4,backWall/4);
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
}
