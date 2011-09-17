#include <GroveSoundRecorder.h> // include our sound recorder library

// define sensor pins
#define SOUNDRECSEL1 2 // Grove pin 2 for sound recorder
#define PIR 10         // pin 10 for PIR signal
#define PIRIND 11      // recycle N/C pin from PIR to led test indicator

// initialize a recorder
GroveSoundRecorder recorder(SOUNDRECSEL1);

// keep states
boolean isMoveDetected; // if PIR triggered

void setup() {
     // initialize the sound recorder
     recorder.initialize();
     // initialize motion sensor pin
     isMoveDetected = false;
     pinMode(PIR, INPUT);
     pinMode(PIRIND, OUTPUT);
}

void loop() {
     if(digitalRead(PIR) && !isMoveDetected) {
          //Serial.println("Something moved");
          digitalWrite(PIRIND,HIGH);
          if(!isMoveDetected) {
               recorder.beginPlaybackLoop(TRACK2);
               isMoveDetected = true;
          }
     }
}

