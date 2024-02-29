class Visualize_Edges {
    FFT myFFT;
    PImage[] pastImages;
    int totalHistory = 50;
    int historyTracker;
    color targetColor = color(0, 0, 0); // Black color (you can change this to your desired color)
    
    
    Visualize_Edges(FFT _fft) {
        myFFT = _fft;
        pastImages = new PImage[totalHistory];
        for (int i = 0; i < pastImages.length; i++) {
            pastImages[i] = createImage(640, 480, ARGB);
        }
    }
    
    void draw() {
        drawPast();
        processEdges();
        storeHistory();
    }
    
    void drawPast() {
        for (int i = 0; i < pastImages.length; i++) {
            image(pastImages[i], 0, 0, width, height);
        }
    }
    
    void processEdges() {
        opencv.loadImage(video);
        opencv.gray(); // Convert to grayscale
        opencv.findCannyEdges(110, 250);
        //image(opencv.getOutput(), 0, 0, width, height);
    }
    
    void storeHistory() {
        // pastImages[historyTracker] = createMask(opencv.getOutput(), targetColor);
        pastImages[historyTracker] = applyMaskAndReplaceColor(opencv.getOutput(), targetColor, this.colorChanger((int) map(historyTracker,0,totalHistory,0,myFFT.specSize()), true));
        historyTracker++;
        if (historyTracker >=  pastImages.length)historyTracker = 0;
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
        
        color colorChanger(int i, boolean b) {
            if (b) return color(
                map(myFFT.getFreq(i) * speed, 0, 512, 0, 255),
                map(myFFT.getBand(i), 0, 512, 100, 0),
                100.0
               );
            else return color(
                map(myFFT.getFreq(i) * speed, 0, 512, 360, 0),
                map(myFFT.getFreq(i), 0, 1024, 100, 0),
                map(myFFT.getBand(i), 0, 512, 100, 0)
               );
        }
        
        
        void initMode() {
            historyTracker = 0;
            video.start();
            image(video,0,0);
        }
        
        void endMode() {
            video.stop();
        }   
    }
        