import processing.video.*;

Capture capture;
int W = 640;
int H = 480;
PImage prevFrame = null;
ToneCurve curveBlack;

void setup()
{
  size(W * 2, H);
  background(0);
  String[] cameras = Capture.list();
  println(cameras);
  capture = new Capture(this, cameras[0]);
  capture.start();
  frameRate(30);
  curveBlack = new ToneCurve();
  while(!capture.available());
  capture.read();
  prevFrame = applyTone(curveBlack, capture, new PImage(W, H));
}

void draw()
{
  if (capture.available()){
    capture.read();
    image(capture, 0, 0);
    
    image(merge(capture, prevFrame, W, H), W, 0);
  }
}

PImage merge(PImage prev, PImage curr, int w, int h)
{
  for(int x = 0; x < w; ++x){
    for(int y = 0; y < h; ++y){
    }
  }
  return image;
}

PImage applyTone(ToneCurve tc, PImage src, PImage dst, int w, int h){
  for(int x = 0; x < w; ++x){
    for(int y = 0; y < h; ++y){
      Color c = new Color(tc.process(), saturation(x, y, src), ); // hsv
      dst.set(x, y, )
    }
  }
  return image;
}

class ToneCurve {
    byte[] curve = new byte[256];
    void init(){
        for(int i = 0; i < 256; ++i){
            curve[i] = i < 128 ? 0 : i * 2 - 255; // コールバック化したい
        }
    }
    byte process(byte in){
        return curve[in];
    }
}