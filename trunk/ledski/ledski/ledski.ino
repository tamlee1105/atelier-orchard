int ledPin = 3;      // LED connected to digital pin 9
int analogPin = 0;   // potentiometer connected to analog pin 3
int val = 0;         // variable to store the read value

float Vdd = 4.79;
float Gres = Vdd / 5.0; // [V/g]
float ofst = Vdd / 2.0;

void setup()
{
  pinMode(ledPin, OUTPUT);   // sets the pin as output
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
  val = analogRead(analogPin);   // read the input pin

  float v = (float)val / 1023.0 * Vdd;
  v = v - (ofst - Gres);
  v = (v / (2 * Gres));
  val = (int)(v * 255.0);

  if(val>255) val = 255;
  else if(val<0) val = 0;

  analogWrite(ledPin, val);  // analogRead values go from 0 to 1023, analogWrite values from 0 to 255
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
