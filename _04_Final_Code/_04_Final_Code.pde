#include <Wire.h> // include I2C library
#include <GroveMultiTouch.h> // include our Grove I2C touch sensor library
#include <GroveSoundRecorder.h> // include our sound recorder library

// define sensor pins
#define SOUNDRECSEL1 2 // Grove pin 2 for sound recorder
#define TOUCHINT 7     // arduino pin 7 for I2C touch interrupt
#define BUZZER 8       // Grove pin 8 for buzzer signal
#define PIR 10         // pin 10 for PIR signal
#define PIRIND 11      // recycle N/C pin from PIR to led test indicator
#define PASSCODELEN 5  // length of passcode

// initialize a recorder
GroveSoundRecorder recorder(SOUNDRECSEL1);
// initialize the Grove I2C touch sensor
GroveMultiTouch feelers(TOUCHINT);
// keep track of 4 pads' states
boolean padTouched[4];

// keep states
boolean isMoveDetected; // if PIR triggered
boolean isCodeCorrect; // if code is good
byte inputcode[PASSCODELEN]; // user input code
byte password[PASSCODELEN] = { // 
     3,1,2,1,3};
int inputcounter;

void setup() {
     Wire.begin(); // needed by the GroveMultiTouch lib
     // initialize the containers
     for(int i=0; i<=3; i++) {
          padTouched[i]=false;
     }
     // initialize the touch sensors
     feelers.initialize();
     inputcounter=0;
     for(int i=0; i<PASSCODELEN; i++) {
          inputcode[i]=0;
     }
     isCodeCorrect=false;
     // initialize the sound recorder
     recorder.initialize();
     // initialize buzzer pin
     pinMode(BUZZER,OUTPUT);
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
     if(isMoveDetected) {
          feelers.readTouchInputs(); // test read the touch sensors
          // loop through our touch sensors 1 to 4
          for(int i=0; i<=3; i++) {
               // get the touch state based on pin #
               if(feelers.getTouchState(i)) {
                    if(!padTouched[i]) {
                         // sound the buzzer
                         digitalWrite(BUZZER,HIGH);
                    }
                    // flag the touch sensor state
                    padTouched[i]=true;
               } 
               else {
                    if(padTouched[i]) {
                         // turn buzzer off
                         digitalWrite(BUZZER,LOW);
                         if(inputcounter==PASSCODELEN) {
                              inputcounter=0;
                         }
                         switch(i) {
                         case 0:
                              inputcode[inputcounter]=1;
                              inputcounter++;
                              break;
                         case 1:
                              inputcode[inputcounter]=2;
                              inputcounter++;
                              break;
                         case 2:
                              inputcode[inputcounter]=3;
                              inputcounter++;
                              break;
                         case 3:
                              delay(500);
                              // check if input code is good
                              isCodeCorrect=true;
                              for(int i=0; i<PASSCODELEN; i++) {
                                   if(inputcode[i]==password[i]) {
                                        isCodeCorrect=true;
                                   }
                              }                              
                              // check if shutdown code is correct
                              if(isCodeCorrect) {
                                   // turn off alarm
                                   isMoveDetected = false;
                                   digitalWrite(PIRIND,LOW);
                                   recorder.stopPlayback();
                                   // sound buzzer 3 times for correct
                                   for(int b=0;b<3;b++) {
                                        digitalWrite(BUZZER,HIGH);
                                        delay(100);
                                        digitalWrite(BUZZER,LOW);
                                        delay(100);
                                   }
                                   delay(5000); // delay to settle down
                              } 
                              else {
                                   // sound buzzer 2 long beeps, means wrong
                                   for(int b=0;b<2;b++) {
                                        digitalWrite(BUZZER,HIGH);
                                        delay(250);
                                        digitalWrite(BUZZER,LOW);
                                        delay(200);
                                   }
                              }
                              // reset user input code
                              inputcounter=0;
                              for(int i=0; i<PASSCODELEN; i++) {
                                   inputcode[i]=false;
                              }                             
                              break;
                         default:
                              break;
                         }                        
                         delay(300);
                    }
                    // reset the touch sensor state               
                    padTouched[i]=false;
               }
          }     
     }
}

