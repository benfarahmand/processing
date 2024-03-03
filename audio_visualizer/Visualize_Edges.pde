class Visualize_Edges implements Visualizer {
    String NAME = "Edges";
    FFT myFFT;
    ArrayList<PImage> pastImages;
    int totalHistory = 25;
    int minHistory = 10;
    int maxHistory = 50;
    int historyTracker;
    color targetColor = color(0, 0, 0); // Black color (you can change this to your desired color)
    
    
    Visualize_Edges(FFT _fft) {
        myFFT = _fft;
        pastImages = new ArrayList<PImage>();
        // for (int i = 0; i < totalHistory; i++) {
        //     pastImages.add(createImage(640, 480, ARGB));
        // }
    }
    
    @Override
    void draw() {
        drawPast();
        processEdges();
        storeHistory();
    }
    
    void drawPast() {
        for (int i = 0; i < pastImages.size() ; i++) {
            image(pastImages.get(i), 0, 0, width, height);
        }
    }
    
    void processEdges() {
        opencv.loadImage(video);
        opencv.gray(); // Convert to grayscale
        opencv.findCannyEdges(190, 250);
        //image(opencv.getOutput(), 0, 0, width, height);
    }
    
    void storeHistory() {
        modifyHistoryLength();
        // pastImages[historyTracker] = createMask(opencv.getOutput(), targetColor);
        pastImages.add(applyMaskAndReplaceColorAndFlip(opencv.getOutput(), targetColor, this.colorChanger((int) map(historyTracker,0,totalHistory,0,myFFT.specSize()), true)));
        historyTracker++;
        // println(pastImages.size());
        if (historyTracker >=  totalHistory) {
            historyTracker = 0;
        }
        if(pastImages.size()>=totalHistory){
            pastImages.remove(0);
        }
    }

    void modifyHistoryLength(){
        // int currentHistory = (int) map(bpm.getBPM(), 2.0, 10.0, minHistory, maxHistory);
        int currentHistory = (int) map(bpm.getBPM(), 2.0, 10.0, maxHistory, minHistory);
        // println(currentHistory);
        if(currentHistory > totalHistory) {
            totalHistory++;
            if(totalHistory>maxHistory) totalHistory=maxHistory;
        }
        else {
            totalHistory--;
            if(totalHistory<minHistory) totalHistory=minHistory;
        }
    }
    
    PImage createMask(PImage img, color target) {
        PImage mask = createImage(img.width, img.height, ALPHA);
        img.loadPixels();
        mask.loadPixels();
        for (int i = 0; i < img.pixels.length; i++) {
            if (img.pixels[i] == target) {
                mask.pixels[i] = color(0, 0); // Make the pixel transparent
            } else {
                mask.pixels[i] = color(255, 255); // Make the pixel opaque
            }
        }
        mask.updatePixels();
        return mask;
    }
    
    PImage applyMaskAndReplaceColor(PImage inputImg, color targetColor, color replacementColor) {
        PImage result = createImage(inputImg.width, inputImg.height, ARGB);
        inputImg.loadPixels();
        result.loadPixels();
        for (int i = 0; i < inputImg.pixels.length; i++) {
            if (inputImg.pixels[i] == targetColor) {
                result.pixels[i] = color(0, 0); // Make the pixel transparent
        } else {
                result.pixels[i] = replacementColor; // Replace non-black pixels with the replacement color
            }
        }
        result.updatePixels();
        return result;
    }

    PImage applyMaskAndReplaceColorAndFlip(PImage inputImg, color targetColor, color replacementColor) {
        PImage result = createImage(inputImg.width, inputImg.height, ARGB);
        inputImg.loadPixels();
        result.loadPixels();
        for (int y = 0; y < inputImg.height; y++) {
            for (int x = 0; x < inputImg.width; x++) {
                int i = y * inputImg.width + x;
                if (inputImg.pixels[i] == targetColor) {
                    result.pixels[y * inputImg.width + inputImg.width - x - 1]=color(0,0);
                } else {
                    result.pixels[y * inputImg.width + inputImg.width - x - 1]=replacementColor;
                }
            }
        }
        result.updatePixels();
        return result;
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
        println("Starting Edges");
        historyTracker = 0;
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
        