#include <MIDI.h>

// MIDI Library 
// http://www.arduino.cc/playground/Main/MIDILibrary

// 4051 multiplexer
// http://www.arduino.cc/playground/Learning/4051

int sensorPin = 0;
int sensorValue;
int midiValue = 0;
int old_midiValue[8];

int midiCh = 1;

int r0 = 0;    // 4051 A
int r1 = 0;    // 4051 B
int r2 = 0;    // 4051 C
int row = 0;    // storeing the bin code
int count = 0;
byte bin[] = {0,1,10,11,100,101,110,111};    //bin array org

int cc[] = {10,11,91,93,73,72,74,71};       // MIDI Control change
// PAN, EXP, Reverb, Chorus, Atack, Release, Cutoff, Resonance

void control(){
    if(count > 7){
      count = 0;
    }
    row = bin[count];
    r0 = row & 0x01;
    r1 = (row>>1) & 0x01;
    r2 = (row>>2) & 0x01;
    
    digitalWrite(2,r0);
    digitalWrite(3,r1);
    digitalWrite(4,r2);
    
    sensorValue = analogRead(sensorPin);
    midiValue = sensorValue / 8;
    
    //Serial.print("Sensor: ");
    //Serial.print(sensorValue, DEC);
    //Serial.print(", Midi: ");
    //Serial.print(midiValue);
    //Serial.print(", ");
    
   if(midiValue != old_midiValue[count]){
      //Serial.print("midiCh: ");
      //Serial.print(midiCh);
      //Serial.print(", cc[count]: ");
      //Serial.print(cc[count]);
      MIDI.sendControlChange(cc[count], midiValue, midiCh);
   }
   //Serial.print("\n");
    
    old_midiValue[count] = midiValue;
    //count++;
    
    //delay(200);            // delay 200 milliseconds
  }
  

void setup(){
  //Serial.begin(9600);      // open the serial port at 9600 bps:
  
  pinMode(2, OUTPUT);    //A
  pinMode(3, OUTPUT);     //B
  pinMode(4, OUTPUT);     //C

  MIDI.begin(1);

}

void loop(){
 control();
}
