const int pin2 = 2;
const int Blue1 = 3;
const int pin4 = 4;
const int Red1 = 5;
const int Green1 = 6;
const int White1 = 7;
const int SPKp = 8;
const int Blue2 = 9;
const int Red2 = 10;
const int Green2 = 11;
const int White2 = 12;
const int SPKn = 13;
const int AI0 = 0;
const int AI1 = 1;
const int AI2 = 2;
const int AI3 = 3;
const int AI4 = 4;
const int AI5 = 5;


/** G-sensor input 0-255 */
int front_x = 0, front_y = 0, front_z = 0;
int rear_x  = 0, rear_y  = 0, rear_z  = 0;

/** LED output 0-1023 */
int front_r = 0, front_g = 0, front_b = 0;
int rear_r  = 0, rear_g  = 0, rear_b  = 0;

//float Vdd = 4.79;
float Vdd = 5.00;
float Gres = Vdd / 5.0; // [V/g]
float ofst = Vdd / 2.0;

void setup()
{
  pinMode(Blue1, OUTPUT);
  pinMode(Red1, OUTPUT);
  pinMode(Green1, OUTPUT);
  pinMode(Blue2, OUTPUT);
  pinMode(Red2, OUTPUT);
  pinMode(Green2, OUTPUT);
  
  analogReference(DEFAULT);
}
/*
void loop()
{
  val = analogRead(analogPin);   // read the input pin
  val = (5 * val - 384)>>1;
  if(val>1023) val = 1023;
  else if(val<0) val = 0;
  analogWrite(ledPin, val>>2);  // analogRead values go from 0 to 1023, analogWrite values from 0 to 255
}
*/

void loop()
{
  front_x = analogRead(AI0);
  front_y = analogRead(AI1);
  front_z = analogRead(AI2);
  rear_x  = analogRead(AI3);
  rear_y  = analogRead(AI4);
  rear_z  = analogRead(AI5);
  
  front_r = func(front_x);
  front_g = func(front_y);
  front_b = func(front_z);
  rear_r  = func(rear_x);
  rear_g  = func(rear_y);
  rear_b  = func(rear_z);

  analogWrite(Blue1, front_r);
  analogWrite(Red1, front_g);
  analogWrite(Green1, front_b);
  analogWrite(Blue2, rear_r);
  analogWrite(Red2, rear_g);
  analogWrite(Green2, rear_b);
}

int func(int in){
  float v = (float)in / 1023.0 * Vdd;
  v = v - (ofst - Gres);
  v = (v / (2 * Gres));
  v = (int)(v * 255.0);

  if(v>255) v = 255;
  else if(v<0) v = 0;
  return (int)v;
}

/* // PWM test
void loop()
{
  val++;
  if(val>1023) val = 0;
  analogWrite(ledPin, val>>2);
  delay(1);
}
*/
