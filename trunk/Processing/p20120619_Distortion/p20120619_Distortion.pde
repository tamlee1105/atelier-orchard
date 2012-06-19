/**
 * 
 * 
 * (http://stackoverflow.com/questions/5542942/looking-for-fast-image-distortion-algorithms)
 */

PImage img, img2;

void setup() {
  frameRate(15);
  colorMode(RGB, 255, 255, 255, 100);
  img  = loadImage("hana.jpg");
  size(img.width<<1, img.height, P2D);
  img2 = new PImage(img.width, img.height);
}

void draw() 
{ 
  sphereDistortion(img2, img, mouseX - img.width, mouseY);
  background(0);
  image(img, 0, 0);
  image(img2, img.width, 0);
}

class Point {
  int x;
  int y;
  Point(int x, int y){
    this.x = x;
    this.y = y;
  }
  Point(){
    this.x = 0;
    this.y = 0;
  }
}

void sphereDistortion(PImage dst, PImage src, int ox, int oy)
{
  int w = dst.width;
  int h = dst.height;

  float theta, radi;
  float nx, ny;

  for (int x = 0; x < w; ++x) {
    for (int y = 0; y < h; ++y) {
      int x0 = x - ox;
      int y0 = y - oy;
      theta = atan2((y0), (x0));
      radi  = (x0 * x0 + y0 * y0) / max(w>>1, h>>1);
      nx = ox + radi * cos(theta);
      if (nx < 0 || w <= nx){
        dst.set(x, y, color(0));
        continue;
      }
      ny = oy + radi * sin(theta);
      if (ny < 0 || h <= ny) {
        dst.set(x, y, color(0));
        continue;
      }
      dst.set(x, y, src.get((int)nx, (int)ny));
    }
  }
}

