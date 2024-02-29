class Template {
    float[] angle;
    float[] y, x, z;
    float[] centerColor;
    float myWidth, myHeight;
    FFT myFFT;
    

    Template(FFT _fft){
        myFFT = _fft;
        y = new float[myFFT.specSize()];
        x = new float[myFFT.specSize()];
        z = new float[myFFT.specSize()];
        angle = new float[myFFT.specSize()];
        myWidth = parseFloat(width);
        myHeight = parseFloat(height);
        centerColor = new float[3];
        centerColor[0] = 0.0;
        centerColor[1] = 15.0;
        centerColor[2] = 90.0;
    }

    void draw(){
    }


    void initMode(){
        
    }
}
