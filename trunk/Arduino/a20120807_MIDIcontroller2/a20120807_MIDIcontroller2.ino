/* Arduino Pro Mini (5V, 16MHz) w/ ATmega328 */
#include <MIDI.h>

/* Arduino Pin Asignment */ 
const int a_in_4051    = 0;
const int a_in_fade    = 2;
const int a_in_speed   = 3;
const int a_in_xfader  = 1;
const int d_in_transA  = 7;
const int d_in_transB  = 8;
const int d_in_rotaryA = 2;
const int d_in_rotaryB = 3;
const int d_out_4051A  = 10;
const int d_out_4051B  = 11;
const int d_out_4051C  = 12;
const int d_out_led    = 13;

/* interrupt channel assign */
const int interrupt_rotaryB = 0; // at D2 pin
const int interrupt_rotaryA = 1; // at D3 pin

/* TC4051 Pin Asignment */
const int IDX_RED    = 5;
const int IDX_GREEN  = 7;
const int IDX_BLUE   = 6;
const int IDX_DIST   = 4;
const int IDX_MIRROR = 3;
const int IDX_RGB    = 0;
const int IDX_GLITCH = 1;
const int IDX_WAVE   = 2;

/* MIDI ControlChange constants */
const int cc_4051[]   = {10,11,91,93,73,72,74,71};
const int cc_fadeout  = 75;
const int cc_speed    = 76;
const int cc_position = 77;
const int cc_xfader   = 78;

int vr_new_4051[8];
int vr_new_fadeout;
int vr_new_speed;
int vr_new_xfader;
int sw_new_transA;
int sw_new_transB;
volatile unsigned char re_new_pos;

int vr_4051[8];
int vr_fadeout;
int vr_speed;
int vr_xfader;
int sw_transA;
int sw_transB;
unsigned char re_pos;

int midiCh = 1;
int led_val = 0;
volatile int new_D, old_D, D;

void updateRotaryValue(){
    new_D = 0x0;
    if(digitalRead(d_in_rotaryA) == HIGH){
      new_D |= 0x1;
    }
    if(digitalRead(d_in_rotaryB) == HIGH){
      new_D |= 0x2;
    }
    D = bitRead((old_D << 1) + new_D, 2);
    //D = ((old_D << 1) + new_D) & 0x2;
    if(D == 0x0){ // CW
        --re_new_pos;
    }else if(D == 0x2){ // CCW
        ++re_new_pos;
    }
    
    old_D = new_D;
}

void re_change_A(){
  if (digitalRead(d_in_rotaryA) == HIGH) { 
    if (digitalRead(d_in_rotaryB) == LOW) {  
      ++re_new_pos;         // CW
    } else {
      --re_new_pos;         // CCW
    }
  } else { 
    if (digitalRead(d_in_rotaryB) == HIGH) {  
      ++re_new_pos;         // CW
    } else {
      --re_new_pos;         // CCW
    }
  }
}

void re_change_B(){
  if (digitalRead(d_in_rotaryB) == HIGH) {
    if (digitalRead(d_in_rotaryA) == HIGH) {  
      ++re_new_pos;         // CW
    } else {
      --re_new_pos;         // CCW
    }
  } else { 
    if (digitalRead(d_in_rotaryA) == LOW) {   
      ++re_new_pos;          // CW
    } else {
      --re_new_pos;          // CCW
    }
  }
}

void setup(){
  pinMode(d_out_4051C, OUTPUT); // A
  pinMode(d_out_4051B, OUTPUT); // B
  pinMode(d_out_4051A, OUTPUT); // C
  pinMode(d_out_led, OUTPUT); // C
  pinMode(d_in_transA, INPUT);  // 
  pinMode(d_in_transB, INPUT);  // 
  pinMode(d_in_rotaryA, INPUT);
  pinMode(d_in_rotaryB, INPUT);
  
  re_pos = re_new_pos = 0;
  old_D = 0x0;
  if(digitalRead(d_in_rotaryA) == HIGH){
    old_D |= 0x1;
  }
  if(digitalRead(d_in_rotaryB) == HIGH){
    old_D |= 0x2;
  }
  
  attachInterrupt(interrupt_rotaryA, re_change_A, CHANGE);
  attachInterrupt(interrupt_rotaryB, re_change_B, CHANGE);

  MIDI.begin(midiCh);
  //Serial.begin(9600);
}

void loop(){
  // led
  ++led_val;
  if(led_val & 0x10){
    digitalWrite(d_out_led, LOW);
  }else{
    digitalWrite(d_out_led, HIGH);
  }
  
  // data read 
  {
    for(int i = 0; i < 8; ++i){
      int r2 = bitRead(i, 2);
      int r1 = bitRead(i, 1);
      int r0 = bitRead(i, 0);
      digitalWrite(d_out_4051A, r2);
      digitalWrite(d_out_4051B, r1);
      digitalWrite(d_out_4051C, r0);
      vr_new_4051[i] = analogRead(a_in_4051)   >> 3;
    }
    vr_new_fadeout  = analogRead(a_in_fade)    >> 3;
    vr_new_speed    = analogRead(a_in_speed)   >> 3;
    sw_new_transA   = digitalRead(d_in_transA);
    sw_new_transB   = digitalRead(d_in_transB);
    vr_new_xfader   = analogRead(a_in_xfader)  >> 3;
  }
  
  // send midi message
  {
    for(int i = 0; i < 8; ++i){
      if(vr_4051[i] != vr_new_4051[i]){
        vr_4051[i] = vr_new_4051[i];
        MIDI.sendControlChange(cc_4051[i], vr_4051[i], midiCh);
        //Serial.print(vr_4051[i]);
        //Serial.print("\n");
      }
    }
    
    if(vr_fadeout != vr_new_fadeout){
        vr_fadeout = vr_new_fadeout;
        MIDI.sendControlChange(cc_fadeout, vr_fadeout, midiCh);
        //Serial.print(vr_fadeout);
        //Serial.print("\n");
    }
    
    if(vr_speed != vr_new_speed){
        vr_speed = vr_new_speed;
        MIDI.sendControlChange(cc_speed, vr_speed, midiCh);
        //Serial.print(vr_speed);
        //Serial.print("\n");
    }
    
    //if(vr_position != vr_new_position){
    //    vr_position = vr_new_position;
    //    MIDI.sendControlChange(cc_position, vr_position, midiCh);
    //}
    if(re_pos != re_new_pos){
      MIDI.sendControlChange(cc_position, re_pos & 0x7F, midiCh);
      //Serial.print(re_pos & 0x7F);
      //Serial.print("\n");
      re_pos = re_new_pos;
    }
    
    if(sw_transA != sw_new_transA || sw_transB != sw_new_transB || vr_xfader != vr_new_xfader){
        sw_transA = sw_new_transA;
        sw_transB = sw_new_transB;
        vr_xfader = vr_new_xfader;
        if(sw_transA == HIGH && sw_transB == HIGH){
        }else if(sw_transA == HIGH){
          MIDI.sendControlChange(cc_xfader, 0, midiCh);
          //Serial.print(127);
          //Serial.print("\n");
        }else if(sw_transB == HIGH){
          MIDI.sendControlChange(cc_xfader, 127, midiCh);
          //Serial.print(0);
          //Serial.print("\n");
        }else{
          MIDI.sendControlChange(cc_xfader, vr_xfader, midiCh);
          //Serial.print(vr_xfader);
          //Serial.print("\n");
        }
    }
  }
}
