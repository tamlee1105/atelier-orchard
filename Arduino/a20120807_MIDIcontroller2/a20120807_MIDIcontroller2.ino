/* Arduino Pro Mini (5V, 16MHz) w/ ATmega328 */
#include <MIDI.h>

/* Arduino Pin Asignment */ 
const int a_in_4051    = 0;
const int a_in_fade    = 2;
const int a_in_speed   = 3;
const int a_in_xfader  = 1;
const int d_in_transA  = 7;
const int d_in_transB  = 8;
const int d_in_rotalyA = 2;
const int d_in_rotalyB = 3;
const int d_out_4051A  = 10;
const int d_out_4051B  = 11;
const int d_out_4051C  = 12;
const int d_out_led    = 13;

/* TC4051 Pin Asignment */
const int IDX_RED    = 5;
const int IDX_GREEN  = 7;
const int IDX_BLUE   = 6;
const int IDX_DIST   = 4;
const int IDX_MIRROR = 3;
const int IDX_RGB    = 0;
const int IDX_GLITCH = 1;
const int IDX_WAVE   = 2;

int vr_new_4051[8];
int vr_new_fadeout;
int vr_new_speed;
int vr_new_xfader;
int sw_new_transA;
int sw_new_transB;

int vr_4051[8];
int vr_fadeout;
int vr_speed;
int vr_xfader;
int sw_transA;
int sw_transB;

const int cc_4051[]   = {10,11,91,93,73,72,74,71};
const int cc_fadeout  = 75;
const int cc_speed    = 76;
const int cc_position = 77;
const int cc_xfader   = 78;

int midiCh = 1;
int led_val = 0;

int new_D, old_D;
unsigned char value;

void setup(){
  pinMode(d_out_4051C, OUTPUT); // A
  pinMode(d_out_4051B, OUTPUT); // B
  pinMode(d_out_4051A, OUTPUT); // C
  pinMode(d_out_led, OUTPUT); // C
  pinMode(d_in_transA, INPUT);  // 
  pinMode(d_in_transB, INPUT);  // 
  pinMode(d_in_rotalyA, INPUT);
  pinMode(d_in_rotalyB, INPUT);
  
  value = 0;
  old_D = 0x0;
  if(digitalRead(d_in_rotalyA) == HIGH){
    old_D |= 0x1;
  }
  if(digitalRead(d_in_rotalyB) == HIGH){
    old_D |= 0x2;
  }

  MIDI.begin(1);
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
      digitalWrite(d_out_4051A, (i>>2) & 0x1);
      digitalWrite(d_out_4051B, (i>>1) & 0x1);
      digitalWrite(d_out_4051C,  i     & 0x1);
      vr_new_4051[i] = analogRead(a_in_4051)   >> 3;
    }
    vr_new_fadeout  = analogRead(a_in_fade)    >> 3;
    vr_new_speed    = analogRead(a_in_speed)   >> 3;
    sw_new_transA   = digitalRead(d_in_transA);
    sw_new_transB   = digitalRead(d_in_transB);
    vr_new_xfader   = analogRead(a_in_xfader)  >> 3;
    
    new_D = 0x0;
    if(digitalRead(d_in_rotalyA) == HIGH){
      new_D |= 0x1;
    }
    if(digitalRead(d_in_rotalyB) == HIGH){
      new_D |= 0x2;
    }
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
    if(new_D != old_D){
      int D = ((old_D << 1) + new_D) & 0x2;
      if(D == 0x0){ // CW
        ++value;
      }else if(D == 0x2){ // CCW
        --value;
      }
      MIDI.sendControlChange(cc_position, value & 0x7F, midiCh);
      //Serial.print(value & 0x7F);
      //Serial.print("\n");
      old_D = new_D;
    }
    
    if(sw_transA != sw_new_transA || sw_transB != sw_new_transB || vr_xfader != vr_new_xfader){
        sw_transA = sw_new_transA;
        sw_transB = sw_new_transB;
        vr_xfader = vr_new_xfader;
        if(sw_transA == HIGH && sw_transB == HIGH){
        }else if(sw_transA == HIGH){
          MIDI.sendControlChange(cc_xfader, 127, midiCh);
          //Serial.print(127);
          //Serial.print("\n");
        }else if(sw_transB == HIGH){
          MIDI.sendControlChange(cc_xfader, 0, midiCh);
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
