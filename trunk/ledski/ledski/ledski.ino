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
float Vdd = 5.00f;
float Gres = Vdd / 5.0f; // [V/g]
float ofst = Vdd / 2.0f;

unsigned long min_g = (unsigned long)(1024.f * (ofst - 2.f) / Vdd);
unsigned long max_g = (unsigned long)(1024.f * (ofst + 2.f) / Vdd);

void setup()
{
  pinMode(Blue1, OUTPUT);
  pinMode(Red1, OUTPUT);
  pinMode(Green1, OUTPUT);
  pinMode(Blue2, OUTPUT);
  pinMode(Red2, OUTPUT);
  pinMode(Green2, OUTPUT);
  
  analogReference(DEFAULT);
  
  Serial.begin(9600);      // open the serial port at 9600 bps:
  
  int gamma_in = analogRead(AI0);
 
  Serial.print((float)gamma_in / 511.f + .1f);
  Serial.print("\n\n");
  init_lut((float)gamma_in / 511.f + .1f);
}

int gamma_lut[256];

void init_lut(float gamma){
  for(int i = 0; i < 256; ++i){
    gamma_lut[i] = (int)(255.f * pow(((float)i / 255.f), gamma));
    Serial.print(gamma_lut[i]);
    Serial.print("\n");
  }
}

void loop()
{
  rear_x  = analogRead(AI3);
  rear_y  = analogRead(AI4);
  rear_z  = analogRead(AI5);
  
  front_r = rear_r  = gamma_lut[func2(rear_x)];
  front_g = rear_g  = gamma_lut[func2(rear_y)];
  front_b = rear_b  = gamma_lut[func2(rear_z)];

  analogWrite(Blue1, front_r);
  analogWrite(Red1, front_g);
  analogWrite(Green1, front_b);
  analogWrite(Blue2, rear_r);
  analogWrite(Red2, rear_g);
  analogWrite(Green2, rear_b);
}

/**
 * return  8bit
 * in     10bit
 */
int func2(int in){
  unsigned long v = (unsigned long)in; // 
  v = (((v - min_g)<<8) / (max_g - min_g)); // スケーリング
  v = (v > 255)? 255 : (v < 0)? 0 : v;
  return (int)v;
}

