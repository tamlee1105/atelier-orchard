/** G-sensor input 0-255 */
int front_x = 0, front_y = 0, front_z = 0;
int rear_x  = 0, rear_y  = 0, rear_z  = 0;

/** LED output 0-1023 */
int front_r = 0, front_g = 0, front_b = 0;
int rear_r  = 0, rear_g  = 0, rear_b  = 0;

float Vdd = 4.79;
float Gres = Vdd / 5.0; // [V/g]
float ofst = Vdd / 2.0;

void setup()
{
  pinMode(3, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(6, OUTPUT);
  pinMode(9, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(11, OUTPUT);
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
  front_x = analogRead(0);
  front_y = analogRead(1);
  front_z = analogRead(2);
  rear_x  = analogRead(3);
  rear_y  = analogRead(4);
  rear_z  = analogRead(5);
  
  front_r = func(front_x);
  front_g = func(front_y);
  front_b = func(front_z);
  rear_r  = func(rear_x);
  rear_g  = func(rear_y);
  rear_b  = func(rear_z);

  analogWrite(3, front_r);
  analogWrite(5, front_g);
  analogWrite(6, front_b);
  analogWrite(9, rear_r);
  analogWrite(10, rear_g);
  analogWrite(11, rear_b);
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
