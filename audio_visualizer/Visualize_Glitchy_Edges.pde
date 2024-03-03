class Visualize_Glitchy_Edges implements Visualizer {
    String NAME = "Glitchy Edges";
    FFT myFFT;
    color targetColor = color(255, 255); // white color (you can change this to your desired color)
    ArrayList<PVector> attractors;
    int maxAttractors = 3000;
    int maxSkips = 5;
    float[] y, x, z; //positions
    float[] vx, vy, vz; //velocities
    float[] centerColor;
    float myWidth, myHeight;
    float leftWall, rightWall, frontWall, backWall, topWall, bottomWall;
    int arraySize;
    boolean debug = false;
    
    Visualize_Glitchy_Edges(FFT _fft) {
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
        leftWall = -myWidth*0.5;
        rightWall = myWidth*0.5;
        frontWall = -10;
        backWall = 10;
        topWall = -myHeight*0.5;
        bottomWall = myHeight*0.5;
    }
    
    @Override
    void draw() {
        processEdges();
        pushMatrix();
        cameraTracker();
        translate(width/2, height/2, 0);
        drawAttractors();
        popMatrix();
    }

    void drawAttractors(){
        noStroke();
        fill(0,100,100);
        for(int i = 0 ; i < attractors.size() ; i++){
            PVector p = attractors.get(i);
            for(int j = 0 ; j < attractors.size() ; j++){
                if(i!=j){
                    PVector q = attractors.get(j);
                    if(dist(p.x,p.y,p.z,q.x,q.y,q.z)<30){
                        int index = (int) map(i,0,attractors.size(),0,arraySize);
                        stroke(this.colorChanger(index, true));
                        strokeWeight(0.5);
                        // strokeWeight(map(myFFT.getBand(index) * speed, 0, 512, 0.5, 5.0));
                        line(p.x,p.y,p.z+map(myFFT.getFreq(index) * speed, 0, 512, 0, 50),q.x,q.y,q.z);//-map(myFFT.getBand(index) * speed, 0, 512, 0, 100));
                    }
                }
            }
        }
        attractors.clear();
    }
    
    void processEdges() {
        opencv.loadImage(video);
        opencv.gray(); // Convert to grayscale
        // opencv.findCannyEdges(int(map(bpm.getBPM(), 1.0, 10.0, 20.0, 200.0)), 250);
        opencv.findCannyEdges(100, 250);
        generateAttractors(opencv.getOutput(),targetColor);
        // image(opencv.getOutput(),0,0);
    }
    
    void generateAttractors(PImage img, color target) {
        int imgWidth = img.width;
        int imgHeight = img.height;
        int pixelSkipCount = 0;
        img.loadPixels();
        for (int i = 0; i < img.pixels.length; i++) {
            if (img.pixels[i] == target) {
                if(pixelSkipCount==0){
                    int x = i % imgWidth;  // Calculate x coordinate
                    int y = i / imgWidth; // Calculate y coordinate
                    if(attractors.size()<maxAttractors) attractors.add(new PVector(map(imgWidth-x-1,0,imgWidth,leftWall,rightWall),map(y,0,imgHeight,topWall,bottomWall),0));
                } else {
                    if(pixelSkipCount>=maxSkips)pixelSkipCount=-1;
                }
                pixelSkipCount++;
            }
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

    @Override
    void initMode() {
        println("Starting Glitchy Edges");
        video.start();
        image(video,0,0);
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
        