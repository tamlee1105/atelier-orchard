int[] x;
int[] y;

void setup(){
  size(80, 85);
  int d = 44;
  x = new int[]{d>>1, d>>1, 0,    0,        d>>1, d,        d};
  y = new int[]{d>>1, 0,    d>>2, (d*3)>>2, d,    (d*3)>>2, d>>2};
  
  colorMode(HSB, 360, 100, 100);
  strokeJoin(ROUND);
  smooth();

  background(0, 0, 0, 50);
  
  strokeWeight(2.0);
  
  hexagon(2, 2, 200);
  hexagon(28, 38, 320);
  
  save("out.png");
  exit();
}

void hexagon(int xx, int yy, int h){
  pushMatrix();
  translate(xx, yy);
    
  {
    fill(h, 60, 60);
    stroke(h, 60, 60);
    triangle(x[0], y[0], x[1], y[1], x[2], y[2]);
    triangle(x[0], y[0], x[2], y[2], x[3], y[3]);
    triangle(x[0], y[0], x[3], y[3], x[4], y[4]);
    triangle(x[0], y[0], x[4], y[4], x[5], y[5]);
  }
  
  {
    fill(h, 40, 90);
    stroke(h,40, 90);
    triangle(x[0], y[0], x[5], y[5], x[6], y[6]);
    triangle(x[0], y[0], x[6], y[6], x[1], y[1]);
  }
  
  {  
    stroke(h, 5, 90);
    line(x[1], y[1], x[2], y[2]);
    line(x[2], y[2], x[3], y[3]);
    line(x[3], y[3], x[4], y[4]);
    line(x[4], y[4], x[5], y[5]);
    line(x[5], y[5], x[6], y[6]);
    line(x[6], y[6], x[1], y[1]);
    
    line(x[1], y[1], x[4], y[4]);
    line(x[2], y[2], x[5], y[5]);
    line(x[3], y[3], x[6], y[6]);
  }
  
  popMatrix();
}
