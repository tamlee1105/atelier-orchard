const int d_in_photo = 2;
const int interrupt_photo = 0; // at D2 pin
const int interrupt_photo = 0; // at D2 pin

void photo_falling(){
  Serial.println("falling");
}

void setup()
{
  attachInterrupt(interrupt_photo, photo_falling, FALLING);
  Serial.begin(9600);
}

void loop()
{
  int val = digitalRead(d_in_photo);
  Serial.println(val);
  delay(10);
}
