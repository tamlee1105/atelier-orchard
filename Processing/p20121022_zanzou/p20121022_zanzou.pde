import processing.video.*;

Capture capture;
int W = 640;
int H = 480;
ZanzouFilter filter = null;

void setup()
{
  size(W * 2, H);
  colorMode(RGB, 255);
  background(0);
  String[] cameras = Capture.list();
  println(cameras);
  capture = new Capture(this, cameras[0]);
  capture.start();
  frameRate(30);
  t = System.currentTimeMillis();
}

long t = 0;
void draw()
{
  println("" + (System.currentTimeMillis() - t));
  t = System.currentTimeMillis();
  if (capture.available()){
    capture.read();
    if(filter == null){
      filter = new ZanzouFilter(capture, W, H);
    }
    image(capture, 0, 0);
    image(filter.process(capture), W, 0);
  }
}

/*void ablend(PImage dst, PImage src, int w, int h){
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
}*/

class ZanzouFilter {
  PImage mPrevFrame;
  int[]  mCurveHighPass = new int [256];
  int w = 0, h = 0;
  
  ZanzouFilter(PImage initial_frame, int w, int h){
    this.w = w;
    this.h = h;
    
    // initialization of the curve
    for(int i = 0; i < 256; ++i){
      int val = i < 128 ? 0 : i * 2 - 255;
      val = (int) (val < 0 ? 0 : val > 255 ? 255 : val);
      //println(String.format("[%3d] 0x%08X", i, val));
      mCurveHighPass[i] = val;
    }
    
    // initialization of the prev frame buffer
    mPrevFrame = new PImage(w, h);
    mPrevFrame.copy(initial_frame, 0, 0, w, h, 0, 0, w, h);
  }
  
  public PImage process(PImage curr_frame){
    for(int xx = 0; xx < w; ++xx){
      for(int yy = 0; yy < h; ++yy){
        int src = curr_frame.get(xx, yy);
        int dst = mPrevFrame.get(xx, yy);
        int src_r = mCurveHighPass[(int)red(src)]; // tone curve
        int src_g = mCurveHighPass[(int)green(src)]; // tone curve
        int src_b = mCurveHighPass[(int)blue(src)]; // tone curve
        int dst_r = (int)red(dst);
        int dst_g = (int)green(dst);
        int dst_b = (int)blue(dst);
        color c = color(
          (src_r > dst_r ? src_r : dst_r) - 0f,
          (src_g > dst_g ? src_g : dst_g) - 0f,
          (src_b > dst_b ? src_b : dst_b) - 0f); // lighten and att
        //println(String.format("0x%08X 0x%02X 0x%02X 0x%08X", px, (int)brightness(px), process((int)brightness(px)), c));
        mPrevFrame.set(xx, yy, c);
      }
    }
    return mPrevFrame;
  }
}
