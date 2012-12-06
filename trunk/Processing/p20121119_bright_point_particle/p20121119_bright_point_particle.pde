import processing.video.*;
import fullscreen.*; 

final int OCCURRENCE    = 1;
final int BRIGHNESS_TH  = 253;
final int PARTICLES_LIM = 150;
final int PIXEL_PITCH   = 10;
final int FRAME_PITCH   = 2;

OutputFrame outputFrame = null;

Capture capture;
int W = 640;
int H = 480;

FullScreen fs;

void setup()
{
  size(W, H);
  colorMode(RGB, 255);
  background(0);
  String[] cameras = Capture.list();
  capture = new Capture(this, cameras[0]);
  capture.start();
  frameRate(30);
  //smooth();
  //fs = new FullScreen(this, 1);
  //fs.enter(); 
}

void draw()
{
  long t = System.currentTimeMillis();
  
  if (!capture.available()){
    return;
  }
  
  capture.read();
  if(outputFrame == null){
    outputFrame = new OutputFrame(capture, W, H);
  }
  //image(capture, 0, 0);
  image(outputFrame.drawFrame(capture, frameCount), 0, 0);

  println("" + (System.currentTimeMillis() - t));
}

class Particle{
  PImage tex;
  float px, py;
  float vx, vy;
  float ax, ay;
  
  Particle(PImage tex, int px, int py){
    this.tex = tex;
    this.tex.filter(BLUR);
    this.px = px;
    this.py = py;
    this.vx = random(-5, 5);
    this.vy = random(-3, -10);
    this.ax = 0f;
    this.ay = -0.3f;
  }
  
  public boolean update(){
    px += vx;
    py += vy;
    vx += ax;
    vy += ay;
    if(px < 0 || px > W || py < 0 || py > H){
      return false;
    }
    return true;
  }
}

class OutputFrame{
  int w, h;
  ArrayList<Particle> particles;
  
  OutputFrame(PImage initial_frame, int w, int h){
    this.w = w;
    this.h = h;
    particles = new ArrayList<Particle>();
  }
  
  public PImage drawFrame(PImage curr_frame, int frame_count){  
    // 各画素の輝度を評価して必要ならパーティクル追加
    //if(frame_count % frameCount == 0){
    if(true){
      for(int px = (int)random(PIXEL_PITCH); px < w; px+=PIXEL_PITCH){
        for(int py = (int)random(PIXEL_PITCH); py < h; py+=PIXEL_PITCH){
          if(particles.size() < PARTICLES_LIM){
            if(BRIGHNESS_TH < brightness(curr_frame.get(px, py))){
              if(random(100) < OCCURRENCE){
                particles.add(new Particle(loadImage("heart2.png"), px, py));
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
               (int)particles.get(i).px - (particles.get(i).tex.width >> 1), (int)particles.get(i).py - (particles.get(i).tex.height >> 1),  
               particles.get(i).tex.width, particles.get(i).tex.height, ADD);  
        ++i;
      }
    }
    return curr_frame;
  }
}
