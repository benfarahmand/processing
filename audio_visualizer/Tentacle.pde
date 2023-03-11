class Tentacle {

    float segLength = 5;
    int totalSegments;
    Segment end;
    Segment start;
    PVector base;

    Tentacle(int numberOfTentacleSegments, float baseX, float baseY){
        totalSegments = numberOfTentacleSegments;
        start = new Segment(width/2, height/2, segLength, 0);
        Segment current = start;

        for (int i = 0; i < totalSegments; i++) {
            Segment next = new Segment(current, segLength, i);
            current.child = next;
            current = next;
        }
        end = current;
        base = new PVector(baseX, baseY);
    }

    void drawTentacle(float endX, float endY, int[][] myColors){
        end.follow(endX, endY);
        end.update();

        Segment next = end.parent;
        while (next != null) {
            next.follow();
            next.update();
            next = next.parent;
        }


        start.setA(base);
        start.calculateB();
        next = start.child;
        while (next != null) {
            next.attachA();
            next.calculateB();
            next = next.child;
        }

        int strokeW = 1;
        int colorIndex = 0;

        end.show(strokeW, 
            color(
                myColors[colorIndex][0],
                myColors[colorIndex][1],
                myColors[colorIndex][2]
                )
            );

        next = end.parent;
        while (next != null) {
            strokeW++;
            next.show(strokeW, 
                color(
                    myColors[colorIndex][0],
                    myColors[colorIndex][1],
                    myColors[colorIndex][2]
                    )
                );
            colorIndex++;
            next = next.parent;
        }
    }
}