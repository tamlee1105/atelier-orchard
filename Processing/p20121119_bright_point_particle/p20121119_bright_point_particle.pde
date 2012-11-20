import processing.video.*;

final int OCCURRENCE    = 1;
final int BRIGHNESS_TH  = 253;
final int PARTICLES_LIM = 150;
final int PIXEL_PITCH   = 10;
final int FRAME_PITCH   = 2;

OutputFrame outputFrame = null;

Capture capture;
int W = 640;
int H = 480;

void setup()
{
  size(W, H);
  colorMode(RGB, 255);
  background(0);
  String[] cameras = Capture.list();
  capture = new Capture(this, cameras[0]);
  capture.start();
  frameRate(30);
}

void draw()
{
  long t = System.currentTimeMillis();
  if (capture.available()){
    capture.read();
    if(outputFrame == null){
      outputFrame = new OutputFrame(capture, W, H);
    }
    //image(capture, 0, 0);
    image(outputFrame.drawFrame(capture, frameCount), 0, 0);
  }
  println("" + (System.currentTimeMillis() - t));
}

class Particle{
  PImage tex;
  PVector p;
  PVector v;
  Particle(PImage tex, int px, int py){
    this.tex = tex;
    p = new PVector(px, py);
    v = new PVector(random(-8, 8), random(-10, -20));
  }
  public boolean update(){
    p.x += v.x;
    p.y += v.y;
    if(p.x < 0 || p.x > W || p.y < 0 || p.y > H){
      return false;
    }
    return true;
  }
}

class OutputFrame{
  int w, h;
  ArrayList<Particle> particles;
  //PApplet 
  //PImage frame;
  
  OutputFrame(PImage initial_frame, int w, int h){
    this.w = w;
    this.h = h;
    particles = new ArrayList<Particle>();
    //frame = createImage(w, h, RGB);
  }
  
  public PImage drawFrame(PImage curr_frame, int frame_count){
    //frame.background(0);
    // 各画素の輝度を評価して必要ならパーティクル追加
    if(frame_count % frameCount == 0){
      for(int px = (int)random(PIXEL_PITCH); px < w; px+=PIXEL_PITCH){
        for(int py = (int)random(PIXEL_PITCH); py < h; py+=PIXEL_PITCH){
          if(particles.size() < PARTICLES_LIM){
            if(BRIGHNESS_TH < brightness(curr_frame.get(px, py))){
              if(random(100) < OCCURRENCE){
                particles.add(new Particle(loadImage("heart.png"), px, py));
              }
            }
          }
        }
      }
    }
    // 全パーティクルの再評価、削除、描画
    for(int i = 0; i < particles.size(); ){
      if(!particles.get(i).update()){
        particles.remove(i);
      } else {
        curr_frame.blend(particles.get(i).tex, 0, 0,   
               particles.get(i).tex.width, particles.get(i).tex.height,  
               (int)particles.get(i).p.x, (int)particles.get(i).p.y,  
               particles.get(i).tex.width, particles.get(i).tex.height, ADD);  
        ++i;
      }
    }
    return curr_frame;
  }
}
