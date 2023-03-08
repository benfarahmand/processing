PImage input;
PGraphics output;

void setup(){
  colorMode(HSB,360,100,100,100);
  input = loadImage("image.png");
  switchColor(input, color(0,0,100,0), color(0,0,0,100));
  output = createGraphics(input.width,input.height);
  output.beginDraw();
  output.background(0,0,0,100);
  output.image(input,0,0);
  output.endDraw();
  output.save("output_image.png");
  println("Done");
  exit();
}

void switchColor(PImage img, color c1, color c2){
    for(int x = 0 ; x < img.width ; x++){
        for(int y = 0 ; y < img.height ; y++){
            //if(red(img.get(x,y)) == red(c1) && blue(img.get(x,y)) == blue(c1) && green(img.get(x,y)) == green(c1)){
            if(brightness(img.get(x,y)) == brightness(c1)){
              img.set(x,y,c2);
            }
        }
    }
}
