import processing.video.*;

Capture capture;

void setup()
{
  size(640, 480);
  background(0);
  String[] cameras = Capture.list();
  println(cameras);
  capture = new Capture(this, cameras[0]);
  capture.start();
  frameRate(30);
}

void draw()
{
  if (capture.available()){
    capture.read();
    image(capture, 0, 0);
    //image(zanzou(capture, 320, 240), 320, 0);
  }
}

PImage zanzou(PImage image, int w, int h)
{
  /*color col;
  int a;
  int block_width = 16, block_height = 16; 
  
  for(int x = 0; x < w; x += block_width){
    for(int y = 0; y < h; y += block_height){
      blockMozaic(image, x, y, block_width, block_height);
    }
  }*/
  return image;
}
