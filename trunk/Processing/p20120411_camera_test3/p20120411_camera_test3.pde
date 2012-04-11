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
    image(mozaic(capture, 320, 240), 320, 0);
  }
}

PImage mozaic(PImage image, int w, int h)
{
  color col;
  int a;
  int block_width = 16, block_height = 16; 
  
  for(int x = 0; x < w; x += block_width){
    for(int y = 0; y < h; y += block_height){
      blockMozaic(image, x, y, block_width, block_height);
    }
  }
  return image;
}

void blockMozaic(PImage image, int block_left, int block_top, int block_width, int block_height)
{
  color col;
  int sum_r = 0, sum_g = 0, sum_b = 0;
  int amount = 1;
  for(int y = block_top; y < block_top + block_height; y+=2){
    for(int x = block_left; x < block_left + block_width; x+=2, ++amount){
      col = image.get(x, y);
      sum_r += red(col);
      sum_g += green(col);
      sum_b += blue(col);
    }
  }
  sum_r /= amount;
  sum_g /= amount;
  sum_b /= amount;
  for(int y = block_top; y < block_top + block_height; ++y){
    for(int x = block_left; x < block_left + block_width; ++x){
      image.set(x, y, color(sum_r, sum_g, sum_b));
    }
  }
}

