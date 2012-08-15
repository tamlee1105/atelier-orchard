ArrayList<Particle> particles;
PImage bg;
int att = 15; // pixel attenuation
int occ = 0;  // occurrence probability in percent

void setup() {
  colorMode(RGB, 256);
  size( 320, 240 );
  frameRate(30);
  particles = new ArrayList<Particle>();
  for ( int i = 0; i < 1; i++ ) {
    particles.add(new Particle(width / 2 + 100, height / 2, PI/10f, PI/10f));
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
      p = color(red(p)-att, green(p)-att, blue(p)-att); // アルファにしたい
      for (Particle particle : particles) {
        int dx = x - (int)particle.x;
        int dy = y - (int)particle.y;
        p = particle.eval(p, dx * dx + dy * dy);
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
  float vx, vy;
  float r, g, b;
  
  Particle(float x, float y, float vx, float vy){
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.r = .3f;
    this.g = .5f;
    this.b = .7f;
  }
  void update(int t){
    println(" " + (int)(35 * -sin(this.vx * t)) + " " + (int)(35 * -cos(this.vy * t)));
    this.x += 35 * -sin(this.vx * t);
    this.y += 35 * -cos(this.vy * t);
    //println(" " + (int)(this.x) + " " + (int)(this.y));
  }
  
  color eval(color c, float r2){
    if(r2 == 0) return color(255, 255, 255);
    else return c;
    /*if(r2 > 20000){
      return c;
    }
    float a = (float)Math.sqrt(250000/r2);
    return color(a * this.r + red(c), a * this.g + green(c), a * this.b + blue(c));*/
  }
}
