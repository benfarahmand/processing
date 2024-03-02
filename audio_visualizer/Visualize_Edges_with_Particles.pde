class Visualize_Edges_with_Particles implements Visualizer {
    String NAME = "To Do";
    FFT myFFT;
    color targetColor = color(255, 255); // white color (you can change this to your desired color)
    ArrayList<PVector> attractors;
    int maxAttractors = 200;
    int maxSkips = 10;
    float[] y, x, z; //positions
    float[] vx, vy, vz; //velocities
    float[] centerColor;
    float myWidth, myHeight;
    float leftWall, rightWall, frontWall, backWall, topWall, bottomWall;
    int arraySize;
    boolean debug = false;
    
    Visualize_Edges_with_Particles(FFT _fft) {
        myFFT = _fft;
        attractors = new ArrayList<PVector>();
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
    
    @Override
    void draw() {
        processEdges();
        pushMatrix();
        cameraTracker();
        translate(width/2, height/2, 0);
        drawAttractors();
        drawParticles();
        
        // calculateAttractorForces();
        popMatrix();
    }

    void drawParticles(){
        
        for (int i = 0; i < arraySize; i++) {
            for(int k = 0 ; k < attractors.size() ; k ++){
                PVector p = attractors.get(k);
                float fx = 0;
                float fy = 0;
                float fz = 0;
                attractorRule(p , i, 500, 2000, 1, 1, fx, fy, fz, 1);
                stroke(this.colorChanger(i, true));
                strokeWeight(0.5);
                drawAttractorLines(p,i,30);
                // stroke(0,0,100);
                // strokeWeight(10);
                // point(p.x,p.y,p.z);
            }
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
            // this.calculatePositionSimple(i);
            this.calculatePosition(i);
        }
        attractors.clear();
        
    }

    void drawAttractors(){
        noStroke();
        fill(0,100,100);
        for(int i = 0 ; i < attractors.size() ; i++){
            PVector p = attractors.get(i);
            for(int j = 0 ; j < attractors.size() ; j++){
                PVector q = attractors.get(j);
                if(dist(p.x,p.y,p.z,q.x,q.y,q.z)<30){
                    stroke(this.colorChanger((int) map(i,0,attractors.size(),0,arraySize), true));
                    strokeWeight(0.5);
                    line(p.x,p.y,p.z,q.x,q.y,q.z);
                }
            }
        }
    }
    
    void processEdges() {
        opencv.loadImage(video);
        Rectangle[] faces = opencv.detect();
        if(faces.length > 0){
            opencv.gray(); // Convert to grayscale
            opencv.findCannyEdges(150, 250);
            PImage face = createImage(faces[0].width, faces[0].height,RGB);
            face.copy(opencv.getOutput(),faces[0].x, faces[0].y, faces[0].width, faces[0].height, 0, 0, faces[0].width, faces[0].height);
            generateAttractors(face,targetColor,map(faces[0].x,0,opencv.getOutput().width,leftWall,rightWall), map(faces[0].y,0,opencv.getOutput().height,topWall,bottomWall));
            // image(face, 0, 0);
        }
    }
    
    void generateAttractors(PImage img, color target, float px, float py) {
        int imgWidth = img.width;
        int pixelSkipCount = 0;
        img.loadPixels();
        for (int i = 0; i < img.pixels.length; i++) {
            if (img.pixels[i] == target) {
                if(pixelSkipCount==0){
                    int x = i % imgWidth;  // Calculate x coordinate
                    int y = i / imgWidth; // Calculate y coordinate
                    if(attractors.size()<maxAttractors) attractors.add(new PVector((x+px),y+py,0));
                } else {
                    if(pixelSkipCount>=maxSkips)pixelSkipCount=-1;
                }
                pixelSkipCount++;
            }
        }
    }

    void calculateAttractorForces(){
        for(int i = 0 ; i < attractors.size() ; i ++){
            PVector p = attractors.get(i);
            for(int j = 0 ; j < arraySize ; j++){
                // if(dist(p.x,p.y,p.z,x[j],y[j],z[j])<150){
                    // line(p.x,p.y,p.z,x[j],y[j],z[j]);
                    float fx = 0;
                    float fy = 0;
                    float fz = 0;
                    // float massAdjuster = myFFT.getFreq(j);
                    // float volumeAdjuster = myFFT.getBand(j);
                    // attractorRule(p , j, 100, 20, massAdjuster, volumeAdjuster, fx, fy, fz, 1);
                    attractorRule(p , j, 100, 2000, 1, 1, fx, fy, fz, 1);
                // }
            }
            stroke(0,0,100);
            strokeWeight(10);
            point(p.x,p.y,p.z);
            // for(int j = 0 ; j < attractors.size() ; j++){
            //     if(i!=j){
            //         PVector q = attractors.get(j);
            //         if(dist(p.x,p.y,p.z,q.x,q.y,q.z)<50){
            //             stroke(0,100,100);
            //             strokeWeight(0.5);
            //             line(p.x,p.y,p.z,q.x,q.y,q.z);
            //         }
            //     }
            // }
        }
        attractors.clear();
    }

    void calculatePositionSimple(int i){
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
                atomRule(i,j,50,10,massAdjuster,volumeAdjuster,fx,fy,fz,-50);    
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
        float r = reverse*volumeAdjuster*25;
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

    void attractorRule(PVector p , int j, float distance, float strength, float massAdjuster, float volumeAdjuster, float fx, float fy, float fz, float reverse){
        float dx = p.x - x[j];
        float dy = p.y - y[j];
        float dz = p.z - z[j];
        float d = sqrt(dx * dx + dy * dy + dz * dz);
        float r = reverse*volumeAdjuster*25;
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
            vx[j] = (vx[j] + fx)*0.85;
            vy[j] = (vy[j] + fy)*0.85;
            vz[j] = (vz[j] + fz)*0.85;
        }
    }
        
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
    
    void drawLines(int i, int j, float distance){
        if(dist(x[i],y[i],z[i],x[j],y[j],z[j])<distance){
            line(x[i],y[i],z[i],x[j],y[j],z[j]);
        }
    }

    void drawAttractorLines(PVector p, int j, float distance){
        if(dist(p.x,p.y,p.z,x[j],y[j],z[j])<distance){
            line(p.x,p.y,p.z,x[j],y[j],z[j]);
        }
    }


    @Override
    void initMode() {
        for(var i = 0 ; i < myFFT.specSize() ; i++){
            x[i] = random(leftWall/2,rightWall/2);
            y[i] = random(topWall/2,bottomWall/2);
            z[i] = random(frontWall/4,backWall/4);
        }
        opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
        video.start();
        image(video,0,0);
    }
    
    @Override
    void endMode() {
        video.stop();
    }   

    @Override
    String getName(){
        return NAME;
    }
}
        