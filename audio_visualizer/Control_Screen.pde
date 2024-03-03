public class Control_Screen extends PApplet {
    int id;
    ControlP5 cp5;
    ControlFont font;
    int myWidth, myHeight;
    int guiTop = 20, guiLeft = 10;

    Control_Screen(){
        super();
        PApplet.runSketch(new String[] { this.getClass().getName() }, this);
    }

    void settings() {
        myWidth = 400;
        myHeight = 400;
        size(myWidth,myHeight);
    }

    void setup() {
        cp5 = new ControlP5(this);
        font = new ControlFont(createFont("Arial",42,true),241);
        gui();
    }

    void draw() {
        background(0);
        cp5.draw();
    }

    void gui(){
        //Controllers for Switching Between the Visualizers
        //Labels Java Doc: https://www.sojamo.de/libraries/controlP5/reference/controlP5/Label.html
        //Radio Button Java Doc: https://www.sojamo.de/libraries/controlP5/reference/index.html
        //Eventually we can use images to represent these radio buttons with .setImage(PImage img)
        RadioButton r = cp5.addRadioButton("radio")
            .setCaptionLabel("Visualizers")
            .setPosition(guiLeft,guiTop)
            .setItemWidth(25)
            .setItemHeight(25)
            .setColorLabel(color(255))
            .activate(0)
            ;
        for (int i = 0; i < mt.getCountOfVisualizers(); i++) {
            r.addItem(mt.getNameOfVisualizer(i), i);
            r.getItem(i).getCaptionLabel().setFont(font).setSize(20).setPaddingX(-10);
        }

        //Controller for manipulating the color range
        

        //Controller for toggling background refresh
        cp5.addToggle("toggleBackgroundRefresh")
            .setPosition(myWidth/2,guiTop)
            .setCaptionLabel("Toggle Background Refresh")
            .setSize(50,20);
        
        cp5.getController("toggleBackgroundRefresh")
            .getCaptionLabel().setFont(font).setSize(20).setPaddingY(-10);
    }

    public void radio(int theC) {
        if(theC>=0) mt.setMode(theC);
    }

    public void toggleBackgroundRefresh(boolean b){
        backgroundReset = b;
    }
}