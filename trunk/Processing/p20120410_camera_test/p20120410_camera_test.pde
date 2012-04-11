import processing.video.*;

Capture capture;
PImage image = new PImage(320, 240);

void setup()
{
  size(320<<1, 240);
  background(0);
  capture = new Capture(this, width>>1, height);
  frameRate(10);
}

void draw()
{
  if (capture.available()){
    capture.read();
    image(capture, 0, 0);
    image(image, 320, 0);
  }
}

void mouseReleased()
{
  image.copy(capture, 0, 0, 320, 240, 0, 0, 320, 240);
}

