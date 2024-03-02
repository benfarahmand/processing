public class Second_Screen extends PApplet {
    int id;
    ControlP5 cp5;
    // ControlFont cf;

    Second_Screen(){
        super();
        PApplet.runSketch(new String[] { this.getClass().getName() }, this);
    }

    void settings() {
        size(200,400);
    }

    void setup() {
        cp5 = new ControlP5(this);
        // cf = new ControlFont(createFont("Arial",42,true),42);
        gui();
    }

    void draw() {
        background(0);
        cp5.draw();
    }

    void gui(){
    RadioButton r = cp5.addRadioButton("radio")
        .setPosition(10,20)
        .setItemWidth(20)
        .setItemHeight(25)
        .setColorLabel(color(255))
        .activate(0)
        ;
    for (int i = 0; i < mt.getCountOfVisualizers(); i++) {
        println(i + " : " + mt.getNameOfVisualizer(i));
        r.addItem(mt.getNameOfVisualizer(i), i);
    }
    // r.setFont(cf);
    }

    public void radio(int theC) {
        mt.setMode(theC);
    } 
}