const int d_in_photo = 2;
const int interrupt_photo = 0; // at D2 pin

void photo_falling(){
  int val = digitalRead(d_in_photo);
  if(val == HIGH){
    Serial.println("rising");
  }else{
    Serial.println("falling");
  }
}

void setup()
{
  attachInterrupt(interrupt_photo, photo_falling, CHANGE);
  Serial.begin(9600);
}

void loop()
{
  delay(10);
}
