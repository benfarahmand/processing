class Timer {//This is a modified version of Kyle's timer class, I just added isDone()
  
  int ms; int prevms; int inter;
  boolean done = false;
  boolean firstframe = true;
  
  Timer(){
  }
  
  void run(int interval){
    inter = interval;
    if(firstframe == true && done == false){
      prevms = millis();
      firstframe = false;
    }
    
    if(prevms + interval < millis() ){
      done = true;
    }
  }
  
  int getCurrentTime(){
    return millis()-prevms;
  }
  
  boolean isDone(){
    return done;
  }
  
  void reset(){
    firstframe = true;
    done = false;
  }
  
  float getPercent(){
    return prevms/inter;
  }
  
}
