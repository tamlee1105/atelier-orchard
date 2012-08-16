ArrayList<Particle> particles;
PImage bg;
int att = 15; // pixel attenuation
int occ = 0;  // occurrence probability in percent

void setup() {
  colorMode(HSB, 360, 100, 100);
  size( 320, 240 );
  frameRate(30);
  particles = new ArrayList<Particle>();
  for ( int i = 0; i < 1; i++ ) {
    particles.add(new Particle(width / 2, height / 2, 100, PI/30f, PI/30f));
  }
  bg = createImage(width, height, RGB);
}


void draw() {
  if(random(100) < occ){
    //particles.add(new Particle(random(0, width), random(-20, 0), PI/10f, PI/10f));
  }
  for (int y = 0; y < height; ++y ) {
    for (int x = 0; x < width; ++x ) {
      color p = bg.get(x, y);
      p = color(hue(p), saturation(p), brightness(p)-att); // アルファにしたい
      for (Particle particle : particles) {
        p = particle.eval(x, y, p);
      }
      bg.set(x, y, p);
    }
  }
  ArrayList<Particle> invalid_particles = new ArrayList<Particle>();
  for (Particle particle : particles) {
    particle.update(frameCount);
    /*if(particle.y > height){
      invalid_particles.add(particle);
    }*/
  }
  for (Particle invalid_particle : invalid_particles) {
    particles.remove(particles.indexOf(invalid_particle));
  }
  image(bg, 0, 0);
}

class Particle{
  float x, y;
  float c_x, c_y;
  float r;
  float av_x, av_y;
  float diag_sq;
  
  Particle(float c_x, float c_y, int r, float av_x, float av_y){
    this.c_x = c_x;
    this.c_y = c_y;
    this.r = r;
    this.x = - this.r + this.c_x;
    this.y = this.c_y;
    this.av_x = av_x;
    this.av_y = av_y;
    this.diag_sq = (width * width + height * height);
    //println(" " + this.x + " " + this.y + " " + this.c_x + " " + this.c_y + " " + this.diag_sq);
  }
  void update(int t){
    //println(" " + (int)(35 * -sin(this.av_x * t)) + " " + (int)(35 * -cos(this.av_y * t)));
    this.x += this.av_x * r * sin(this.av_x * t);
    this.y += this.av_y * r * -cos(this.av_y * t);
    //println(" " + (int)(this.x) + " " + (int)(this.y));
  }
  
  color eval(int x, int y, color c){
    /*if(x == (int)this.x && y == (int)this.y) return color(0, 0, 100);
    else return c;*/
    float dx = this.x - x;
    float dy = this.y - y;
    float r2 = dx * dx + dy * dy;
    if(r2 > 20000){
      return c;
    }
    float a = (float)Math.sqrt(this.diag_sq/r2);
    return color(180, 5 + saturation(c), a + brightness(c));
  }
}
