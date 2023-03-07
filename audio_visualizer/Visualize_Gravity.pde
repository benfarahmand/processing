class Visualize_Gravity {
    float[] angle;
    float[] y, x, z, xf,yf,zf; //two sets of position arrays for transitioning between certain modes
    float[] vx, vy, vz; //velocities for gravity mode
    float[] centerColor;
    FFT myFFT;
    float myWidth, myHeight;
    float leftWall, rightWall, frontWall, backWall, topWall, bottomWall;

    Visualize_Gravity(FFT _fft){
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
        centerColor = new float[3];
        centerColor[0] = 0.0;
        centerColor[1] = 15.0;
        centerColor[2] = 90.0;
        leftWall = -myWidth/2;
        rightWall = myWidth/2;
        frontWall = -20;
        backWall = 20;
        topWall = -myHeight/2;
        bottomWall = myHeight/2;
    }

    void draw(){
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
    }

    void calculatePosition(int i){
        float volumeAdjuster = myFFT.getBand(i)/10;
        float massAdjuster = myFFT.getFreq(i);
        float velocityDamp = 0.1;
        float fx = 0;
        float fy = 0;
        float fz = 0;
        for(int j = 0 ; j < myFFT.specSize() ; j++){
            if(i!=j){
                float dx = x[j] - x[i];
                float dy = y[j] - y[i];
                float dz = z[j] - z[i];
                float d = sqrt(dx * dx + dy * dy + dz * dz);
                if(d<200){
                    float force = ((1) / (d * massAdjuster));
                    fx = fx + force * dx;
                    fy = fy + force * dy;
                    fz = fz + force * dz;
                    vx[i] = (vx[i] + fx)*0.8;//*.00001*massAdjuster;
                    vy[i] = (vy[i] + fy)*0.8;//*.00001*massAdjuster;
                    vz[i] = (vz[i] + fz)*0.8;//*.00001*massAdjuster;
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
        x[i] = x[i] + vx[i];//*volumeAdjuster;
        y[i] = y[i] + vy[i];//*volumeAdjuster;
        z[i] = z[i] + vz[i];//*volumeAdjuster;
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

    void moveCube(int i){
        pushMatrix();
        translate(x[i], y[i], z[i]);
        sphere((myFFT.getBand(i)+myFFT.getFreq(i))*sizeScale/20+1);
        popMatrix();
    }

    void initMode(){
        for(var i = 0 ; i < myFFT.specSize() ; i++){
            x[i] = random(leftWall,rightWall);
            y[i] = random(topWall,bottomWall);
            z[i] = random(frontWall,backWall);
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
