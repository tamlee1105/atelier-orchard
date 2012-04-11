import processing.video.*;

Capture capture;

void setup()
{
  size(320<<1, 240);
  background(0);
  println(Capture.list());
  capture = new Capture(this, width>>1, height);
  frameRate(10);
}

void draw()
{
  if (capture.available()){
    capture.read();
    image(capture, 0, 0);
    image(mono(capture, 320, 240), 320, 0);
  }
}

PImage mono(PImage image, int w, int h)
{
  color col;
  int a;
  for(int x = 0; x < w; ++x){
    for(int y = 0; y < h; ++y){
      col = image.get(x, y);
      a   = (int) (red(col) + green(col) + blue(col)) / 3;
      image.set(x, y, color(a));
    }
  }
  return image;
}


