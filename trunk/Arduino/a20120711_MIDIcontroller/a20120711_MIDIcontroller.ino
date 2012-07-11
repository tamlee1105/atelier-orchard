#include <MIDI.h>

const int a_in_4051   = 0;
const int a_in_fade   = 4;
const int a_in_speed  = 3;
const int a_in_pos    = 2;
const int a_in_xfader = 1;
const int d_in_transA = 5;
const int d_in_transB = 6;
const int d_out_4051A = 4;
const int d_out_4051B = 3;
const int d_out_4051C = 2;

const int IDX_RED    = 0;
const int IDX_GREEN  = 1;
const int IDX_BLUE   = 2;
const int IDX_DIST   = 3;
const int IDX_MIRROR = 4;
const int IDX_RGB    = 5;
const int IDX_GLITCH = 6;
const int IDX_WAVE   = 7;

int vr_new_4051[8];
int vr_new_fadeout;
int vr_new_speed;
int vr_new_position;
int sw_new_transA;
int sw_new_transB;
int vr_new_xfader;

int vr_4051[8];
int vr_fadeout;
int vr_speed;
int vr_position;
int sw_transA;
int sw_transB;
int vr_xfader;

const int cc_4051[]   = {10,11,91,93,73,72,74,71};
const int cc_fadeout  = 75;
const int cc_speed    = 76;
const int cc_position = 77;
const int cc_xfader   = 78;

int midiCh = 1;

void setup(){
  pinMode(d_out_4051C, OUTPUT); // A
  pinMode(d_out_4051B, OUTPUT); // B
  pinMode(d_out_4051A, OUTPUT); // C
  pinMode(d_in_transA, INPUT);  // 
  pinMode(d_in_transB, INPUT);  // 

  MIDI.begin(1);
  //Serial.begin(9600);
}

void loop(){
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
    vr_new_position = analogRead(a_in_pos)     >> 3;
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
      }
    }
    
    if(vr_fadeout != vr_new_fadeout){
        vr_fadeout = vr_new_fadeout;
        MIDI.sendControlChange(cc_fadeout, vr_fadeout, midiCh);
    }
    
    if(vr_speed != vr_new_speed){
        vr_speed = vr_new_speed;
        MIDI.sendControlChange(cc_speed, vr_speed, midiCh);
    }
    
    if(vr_position != vr_new_position){
        vr_position = vr_new_position;
        MIDI.sendControlChange(cc_position, vr_position, midiCh);
    }
    
    if(sw_transA != sw_new_transA || sw_transB != sw_new_transB || vr_xfader != vr_new_xfader){
        sw_transA = sw_new_transA;
        sw_transB = sw_new_transB;
        vr_xfader = vr_new_xfader;
        if(sw_transA == HIGH){
          MIDI.sendControlChange(cc_xfader, 127, midiCh);
        }else if(sw_transB == HIGH){
          MIDI.sendControlChange(cc_xfader, 0, midiCh);
        }else{
          MIDI.sendControlChange(cc_xfader, vr_xfader, midiCh);
        }
    }
  }
  
  /*{
    for(int i = 0; i < 8; ++i){
      if(vr_4051[i] != vr_new_4051[i]){
        vr_4051[i] = vr_new_4051[i];
        Serial.print(vr_4051[i]);
        Serial.print(" ");
        Serial.print("\n");
      }
    }
    
    if(vr_fadeout != vr_new_fadeout){
        vr_fadeout = vr_new_fadeout;
        Serial.print(vr_fadeout);
        Serial.print(" ");
        Serial.print("\n");
    }
    
    if(vr_speed != vr_new_speed){
        vr_speed = vr_new_speed;
        Serial.print(vr_speed);
        Serial.print(" ");
        Serial.print("\n");
    }
    
    if(vr_position != vr_new_position){
        vr_position = vr_new_position;
        Serial.print(vr_position);
        Serial.print(" ");
        Serial.print("\n");
    }
    
    if(sw_transA != sw_new_transA || sw_transB != sw_new_transB || vr_xfader != vr_new_xfader){
        sw_transA = sw_new_transA;
        sw_transB = sw_new_transB;
        vr_xfader = vr_new_xfader;
        if(sw_transA == HIGH){
          Serial.print(127);
          Serial.print(" ");
        }else if(sw_transB == HIGH){
          Serial.print(0);
          Serial.print(" ");
        }else{
          Serial.print(vr_xfader);
          Serial.print(" ");
        }
        Serial.print("\n");
    }
  }*/
  delay(20);
}
