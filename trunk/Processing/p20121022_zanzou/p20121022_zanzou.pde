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
}

long t = 0;
void draw()
{
  t = System.currentTimeMillis();
  if (capture.available()){
    capture.read();
    if(filter == null){
      filter = new ZanzouFilter(capture, W, H);
    }
    image(capture, 0, 0);
    image(filter.process(capture), W, 0);
  }
  println("" + (System.currentTimeMillis() - t));
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
  PImage mBackground;
  PImage mResultFrame;
  int[]  mCurveHighPass = new int [256];
  int[]  mCurveLowPass  = new int [256];
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
      mCurveLowPass[i]  = i < 128 ? i : 255 - i;
    }
    
    // initialization of the prev frame buffer
    mPrevFrame = new PImage(w, h);
    mPrevFrame.copy(initial_frame, 0, 0, w, h, 0, 0, w, h);
    
    mBackground = new PImage(w, h);
    for(int xx = 0; xx < w; ++xx){
      for(int yy = 0; yy < h; ++yy){
        int p = initial_frame.get(xx, yy);
        color c = color( mCurveLowPass[(int)red(p)], mCurveLowPass[(int)green(p)], mCurveLowPass[(int)blue(p)]);
        mBackground.set(xx, yy, c);
      }
    }
    
    mResultFrame = new PImage(w, h);
  }
  
  public PImage process(PImage curr_frame){
    for(int xx = 0; xx < w; ++xx){
      for(int yy = 0; yy < h; ++yy){
        int src = curr_frame.get(xx, yy);
        int dst = mPrevFrame.get(xx, yy);
        int bgn = mBackground.get(xx, yy);
        int src_r = mCurveHighPass[(int)red(src)]; // tone curve
        int src_g = mCurveHighPass[(int)green(src)]; // tone curve
        int src_b = mCurveHighPass[(int)blue(src)]; // tone curve
        int dst_r = (int)red(dst);
        int dst_g = (int)green(dst);
        int dst_b = (int)blue(dst);
        int bgn_r = (int)red(bgn);
        int bgn_g = (int)green(bgn);
        int bgn_b = (int)blue(bgn);
        color c = color(
          (src_r > dst_r ? src_r : dst_r) - 1f,
          (src_g > dst_g ? src_g : dst_g) - 1f,
          (src_b > dst_b ? src_b : dst_b) - 1f); // lighten and att
        //println(String.format("0x%08X 0x%02X 0x%02X 0x%08X", px, (int)brightness(px), process((int)brightness(px)), c));
        mPrevFrame.set(xx, yy, c);
        
        src_r = mCurveLowPass[(int)red(src)]; // tone curve
        src_g = mCurveLowPass[(int)green(src)]; // tone curve
        src_b = mCurveLowPass[(int)blue(src)]; // tone curve
        c = color( 
          (src_r >> 1) + (bgn_r >> 1),
          (src_g >> 1) + (bgn_g >> 1), 
          (src_b >> 1) + (bgn_b >> 1) );
        mBackground.set(xx, yy, c);
        
        dst = mPrevFrame.get(xx, yy);
        bgn = mBackground.get(xx, yy);
        dst_r = (int)red(dst);
        dst_g = (int)green(dst);
        dst_b = (int)blue(dst);
        bgn_r = (int)red(bgn);
        bgn_g = (int)green(bgn);
        bgn_b = (int)blue(bgn);
        c = color(
          (bgn_r > dst_r ? bgn_r : dst_r),
          (bgn_g > dst_g ? bgn_g : dst_g),
          (bgn_b > dst_b ? bgn_b : dst_b)); // lighten and att
        mResultFrame.set(xx, yy, c);
      }
    }
    return mResultFrame;
  }
}
