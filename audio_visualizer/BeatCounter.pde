class BeatCounter {
  float beatCheckInterval = 500.0; //in millis
  float timer = 0.0;
  int numberOfBeatsDetected = 0;
  BeatDetect beat;
  BeatListener bl;
  float lastBPM = 1.0, currentBPM = 1.0;

  BeatCounter() {
    beat = new BeatDetect(in.bufferSize(), in.sampleRate());
    beat.detectMode(BeatDetect.FREQ_ENERGY);
    bl = new BeatListener(beat, in);
    beat.setSensitivity(10);
    timer = millis();
  }

  void run() {
    if ( beat.isHat() || beat.isSnare() || beat.isKick()) {// || beat.isOnset()) {
      numberOfBeatsDetected++;
    }
    if (millis() - timer > beatCheckInterval) {
      if (currentBPM < lastBPM) lastBPM=lastBPM-1.0;
      else if (currentBPM >= lastBPM) lastBPM = currentBPM;
      currentBPM = numberOfBeatsDetected;
      numberOfBeatsDetected = 0;
      timer = millis();
    }
  }

  float getBPM() {
    return lastBPM;
  }
}