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

void setup() {
	pinMode(pin2, OUTPUT);
	digitalWrite(pin2, LOW);
	pinMode(Blue1, OUTPUT);
	analogWrite(Blue1, LOW);
	pinMode(pin4, OUTPUT);
	digitalWrite(pin4, LOW);
	pinMode(Red1, OUTPUT);
	analogWrite(Red1, LOW);
	pinMode(Green1, OUTPUT);
	analogWrite(Green1, LOW);
	pinMode(White1, OUTPUT);
	digitalWrite(White1, LOW);
	pinMode(SPKp, OUTPUT);
	digitalWrite(SPKp, LOW);
	pinMode(Blue2, OUTPUT);
	analogWrite(Blue2, LOW);
	pinMode(Red2, OUTPUT);
	analogWrite(Red2, LOW);
	pinMode(Green2, OUTPUT);
	analogWrite(Green2, LOW);
	pinMode(White2, OUTPUT);
	digitalWrite(White2, LOW);
	pinMode(SPKn, OUTPUT);
	digitalWrite(SPKn, LOW);
}

void loop() {
  int LightSeq[] = {Red1,Red2,Green1,Green2,Blue1,Blue2};
  static int i = 0;
  static boolean spkflg = false;
  for(int j = 0;j <= 5;j++){
    for(;i <= analogRead(AI1)/4;i++){

      digitalWrite(SPKp,spkflg);
      digitalWrite(SPKn,!spkflg);
      spkflg = !spkflg;

      analogWrite(LightSeq[j],i);
      delay(analogRead(AI0) / 8);
    }
    analogWrite(LightSeq[j],255);
    for(;i >=  analogRead(AI2)/4;i--){

      digitalWrite(SPKp,spkflg);
      digitalWrite(SPKn,!spkflg);
      spkflg = !spkflg;

      analogWrite(LightSeq[j],i);
      delay(analogRead(AI0) / 8);
    }
    analogWrite(LightSeq[j],0);
  }
}
