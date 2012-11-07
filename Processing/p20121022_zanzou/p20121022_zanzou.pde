import processing.video.*;

Capture capture;
int W = 640;
int H = 480;
PImage prevFrame = null;
ToneCurve curveBlack;

void setup()
{
  size(W * 2, H);
  colorMode(HSB, 255);
  background(0);
  String[] cameras = Capture.list();
  println(cameras);
  capture = new Capture(this, cameras[0]);
  capture.start();
  frameRate(30);
  curveBlack = new ToneCurve();
}

void draw()
{
  if (capture.available()){
    capture.read();
    if(prevFrame == null){
      prevFrame = new PImage(W, H);
      prevFrame.copy(capture, 0, 0, W, H, 0, 0, W, H);
      //curveBlack.apply(capture, prevFrame, W, H);
    }
    image(capture, 0, 0);
    //capture.blend(prevFrame, 0, 0, W, H, 0, 0, W, H, LIGHTEST);
    ablend(prevFrame, capture, W, H);
    image(prevFrame, W, 0);
    //curveBlack.apply(prevFrame, prevFrame, W, H);
  }
}

void ablend(PImage dst, PImage src, int w, int h){
  for(int xx = 0; xx < w; ++xx){
    for(int yy = 0; yy < h; ++yy){
      int sx = src.get(xx, yy);
      int dx = dst.get(xx, yy);
      float alpha = 0.05;
      int r = (int)(red(sx) * alpha + red(dx) * (1.f - alpha)) & 0xFF;
      int g = (int)(green(sx) * alpha + green(dx) * (1.f - alpha)) & 0xFF;
      int b = (int)(blue(sx) * alpha + blue(dx) * (1.f - alpha)) & 0xFF;
      dst.set(xx, yy, (r<<16) | (g<<8) | b);
    }
  }
}

class ToneCurve {
  int[] curve = new int[256];
  void ToneCurve(){
      for(int i = 0; i < 256; ++i){
        int val0 = i < 128 ? 0 : i * 2 - 255; // コールバック化したい
        //int val0 = 127 + (i >> 1); 
        //int val0 = i; 
        int val1 = (int) (val0 < 0 ? 0 : val0 > 255 ? 255 : val0);
        curve[i] = val1;
      }
  }
  
  int process(int in){
      int idx = (int) (in < 0 ? 0 : in > 255 ? 255 : in);
      return curve[idx];
  }
  
  void apply(PImage dst, PImage src, int w, int h){
    for(int xx = 0; xx < w; ++xx){
      for(int yy = 0; yy < h; ++yy){
        int px = src.get(xx, yy);
        color c = color(hue(px), saturation(px), (float)process((int)brightness(px)), 255); // hsv
        dst.set(xx, yy, c);
      }
    }
  }
}
