class Eye {
    PShape eyeShape;
    PImage eyeTexture;
    float x, y, z, radius;
    boolean isBlinking = false; //track whether the eye is blinking
    float blinkDirection = -1.0;//positive 1 for closing, negative 1 for opening eye lid
    float blinkTimer = 0.0;
    float eyesOpenDuration = 0.0;
    float blinkTracker = 500.0;
    float lookX, lookY;

    Eye(float _x, float _y, float _z, float _radius){
        x=_x;
        y=_y;
        z=_z;
        radius=_radius;
        eyeTexture = loadImage("assets/eye_white_2.jpg");
        eyeShape = createShape(SPHERE,radius); //http://processing.github.io/processing-javadocs/core/
        eyeShape.setStroke(false);
        eyeShape.rotateY(PI/2);
        eyeShape.setTexture(eyeTexture);
        textureMode(NORMAL);
        textureWrap(CLAMP);
        eyesOpenDuration = random(3500.0,7000.0);
        blinkTimer = millis();
    }

    void drawEye(){
        lookX = mouseX-x;
        lookY = mouseY-y;
        if((millis() - blinkTimer > eyesOpenDuration) && !isBlinking){
            isBlinking = true;
            blinkDirection = -1.0;
            blinkTracker = 500.0;
        }
        if(isBlinking){
            if(blinkTracker > 500) {
                isBlinking = false;
                blinkTimer = millis();
                eyesOpenDuration = random(3500.0,7000.0);
            }
            if(blinkTracker <= 0){
                blinkDirection=blinkDirection*-1.0;
            }
            blinkTracker=blinkTracker + (50.0*blinkDirection);
        }
        pushMatrix();
        rotateX(map(lookY,0,900,PI/2,-PI/2));
        rotateY(map(lookX,0,1400,-PI/2,PI/2));
        shape(eyeShape,0,0);
        popMatrix();
        if(isBlinking){
            pushMatrix();
            translate(0,-radius+map(blinkTracker,0,500,radius/2,0),radius/2);
            fill(color(0,0,0));
            scale(6-map(blinkTracker,0,500,0,6),2-map(blinkTracker,0,500,0,2),4-map(blinkTracker,0,500,0,4));
            box(radius/2);
            popMatrix();

            pushMatrix();
            translate(0,radius-map(blinkTracker,0,500,radius/2,0),radius/2);
            fill(color(0,0,0));
            scale(6-map(blinkTracker,0,500,0,6),2-map(blinkTracker,0,500,0,2),4-map(blinkTracker,0,500,0,4));
            box(radius/2);
            popMatrix();
        }
    }
}