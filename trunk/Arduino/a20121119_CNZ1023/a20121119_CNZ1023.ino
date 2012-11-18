 const int d_in_photo = 2;
//const int AI4 = 4;

void setup()
{
  //pinMode(d_in_photo, INPUT);
  Serial.begin(9600);
}

void loop()
{
  int val = digitalRead(d_in_photo);
  //int aval = analogRead(AI4);
  Serial.println(val);
  delay(10);
}
