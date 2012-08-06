#include "Tlc5940.h"

class LED {
  private: int pwm_value; // [0,4095]
  private: int diff;
  private: int bottom_value;
  
  public: LED(){
  }
  
  public: void init(int delay_t, int diff, int cycle){
    this->pwm_value = 4095 - (cycle - delay_t);
    this->diff = diff;
    this->bottom_value = 4095 - diff * cycle;
  }
  
  public: int update(){
    pwm_value -= diff;
    if(pwm_value < this->bottom_value){
      pwm_value = 4095;
    }
    return pwm_value > 0 ? pwm_value : 0;
  }
};

LED leds[12];

void setup()
{
  for(int pin = 1; pin < 13; ++pin){
    leds[pin-1].init(pin * 100, 64, 140);
  }
  Tlc.init();
}

void loop()
{
  for(int pin = 1; pin < 13; ++pin){
    Tlc.set(pin, leds[pin - 1].update());
  }

  Tlc.update();
  delay(10);
}

