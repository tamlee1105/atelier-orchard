import processing.video.*;

Capture capture;

void setup()
{
  size(320, 240);
  background(0);
  capture = new Capture(this, width, height);
  frameRate(10);
}

void draw()
{
  if (capture.available()){
    capture.read();
    image(capture, 0, 0);
  }
}

