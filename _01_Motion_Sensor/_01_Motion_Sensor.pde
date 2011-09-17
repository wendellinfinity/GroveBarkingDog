#define PIR 10         // pin 10 for PIR signal
#define PIRIND 11      // recycle N/C pin from PIR to led test indicator

// keep states
boolean isMoveDetected; // if PIR triggered

void setup() {
     // initialize motion sensor pin
     isMoveDetected = false;
     pinMode(PIR, INPUT);
     pinMode(PIRIND, OUTPUT);
}

void loop() {
     if(digitalRead(PIR) && !isMoveDetected) {
          digitalWrite(PIRIND,HIGH);
          if(!isMoveDetected) {
               isMoveDetected = true;
          }
     }
}

