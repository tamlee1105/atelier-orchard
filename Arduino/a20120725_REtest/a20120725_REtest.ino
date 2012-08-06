


const int d_in_rotalyA = 2;
const int d_in_rotalyB = 3;


int new_D, old_D;
unsigned char value;


void setup()
{
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
  
  Serial.begin(9600);      // open the serial port at 9600 bps:
}

void loop()
{
    new_D = 0x0;
    if(digitalRead(d_in_rotalyA) == HIGH){
      new_D |= 0x1;
    }
    if(digitalRead(d_in_rotalyB) == HIGH){
      new_D |= 0x2;
    }
    
    if(new_D != old_D){
      int D = ((old_D << 1) + new_D) & 0x2;
      if(D == 0x0){ // CW
        ++value;
      }else if(D == 0x2){ // CCW
        --value;
      }
      Serial.print(value);
      Serial.print("\n");
      old_D = new_D;
    }
}
