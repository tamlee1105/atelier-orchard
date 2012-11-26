// TODO: OutOfMemory
// TODO: 残像
// TODO: テクスチャ
// refer: http://tercel-sakuragaoka.blogspot.jp/2011/06/processing_16.html

final int OCCURRENCE    = 5;
final int BRIGHNESS_TH  = 253;
final int PARTICLES_LIM = 50;
final int PARTICLES_SIZE = 20;
final int PIXEL_PITCH   = 10;
final int PIXEL_OFFSET  = -50;
final int FRAME_PITCH   = 2;

OutputFrame outputFrame = null;

int W = 640;
int H = 480;

void setup()
{
  size(W, H);
  colorMode(RGB, 255);
  background(0);
  frameRate(30);
}

void draw()
{
  long t = System.currentTimeMillis();
  if (true){
    if(outputFrame == null){
      outputFrame = new OutputFrame(W, H);
    }
    image(outputFrame.drawFrame(frameCount), 0, 0);
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
    v = new PVector(0, random(2, 4));
  }
  public boolean update(){
    p.x += v.x;
    p.y += v.y;
    v.y += 0.3;
    if(p.x < 0 || p.x > W || p.y < PIXEL_OFFSET || p.y > H){
      return false;
    }
    return true;
  }
}

class OutputFrame{
  int w, h;
  ArrayList<Particle> particles;
  PImage mPrevFrame;
  
  OutputFrame(int w, int h){
    this.w = w;
    this.h = h;
    particles = new ArrayList<Particle>();
    mPrevFrame = createImage(w, h, RGB);
  }
  
  public PImage drawFrame(int frame_count){
    //frame.background(0);
    // 各画素の輝度を評価して必要ならパーティクル追加
    if(frame_count % frameCount == 0){
      for(int py = PIXEL_OFFSET ; py < h; py+=PIXEL_PITCH){
        for(int px = (int)random(PIXEL_PITCH); px < w; px+=PIXEL_PITCH){
          if(particles.size() < PARTICLES_LIM){
            if(random(10000) < OCCURRENCE){
              particles.add(new Particle(tex(mask(PARTICLES_SIZE, PARTICLES_SIZE), PARTICLES_SIZE, PARTICLES_SIZE), px, py));
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
        mPrevFrame.blend(particles.get(i).tex, 0, 0,   
               particles.get(i).tex.width, particles.get(i).tex.height,  
               (int)particles.get(i).p.x, (int)particles.get(i).p.y,  
               particles.get(i).tex.width, particles.get(i).tex.height, LIGHTEST );  
        ++i;
      }
    }
    return mPrevFrame;
  }
}

PImage mask(int w, int h){
  PImage mask = createImage(w, h, RGB);
  for(int py = 0; py < h; ++py){
    for(int px = 0; px < w; ++px){
      // TODO: shape
      float sx = (float)px - (float)w / 2f;
      float sy = (float)py - (float)h / 2f;  
      float r2 = ((float)w / 2f) * ((float)h / 2f) - 60f;
      if(r2 > sx * sx + sy * sy){
        mask.set(px, py, color(255, 255, 255, 255));
      }else{
        mask.set(px, py, color(0, 0, 0, 0));
      }
    }
  }
  mask.filter(BLUR, 3);
  return mask;
}

PImage tex(PImage mask, int w, int h){
  PImage tex = createImage(w, h, RGB);
  for(int py = 0; py < h; ++py){
    for(int px = 0; px < w; ++px){
      int r = 127;
      int g = 0;
      int b = 0;
      int a = (int)alpha(mask.get(px, py));
      tex.set(px, py, color(r, g, b));
    }
  }
  tex.blend(mask, 0, 0, tex.width, tex.height,
                   0, 0, mask.width, mask.height, OVERLAY);  
  return tex;
}
