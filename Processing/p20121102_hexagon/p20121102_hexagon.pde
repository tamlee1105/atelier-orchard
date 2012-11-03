void setup(){
  size(100, 100);
  int w = 80;
  int h = 80;
  int ofst_h = (width - w) >> 1;
  int ofst_v = (height- h) >> 1;
  int[] x = new int[]{ofst_h + (w>>1), ofst_h + (w>>1), ofst_h + 0,      ofst_h + 0,          ofst_h + (w>>1), ofst_h + w,          ofst_h + w};
  int[] y = new int[]{ofst_v + (h>>1), ofst_v + 0,      ofst_v + (h>>2), ofst_v + ((h*3)>>2), ofst_v + h,      ofst_v + ((h*3)>>2), ofst_v + (h>>2)};
  
  colorMode(HSB, 360, 100, 100);
  strokeJoin(ROUND);
  smooth();

  background(0, 0, 0, 50);
  
  strokeWeight(2.0);
  
  fill(200, 60, 60);
  stroke(200, 60, 60);
  
  triangle(x[0], y[0], x[1], y[1], x[2], y[2]);
  triangle(x[0], y[0], x[2], y[2], x[3], y[3]);
  triangle(x[0], y[0], x[3], y[3], x[4], y[4]);
  triangle(x[0], y[0], x[4], y[4], x[5], y[5]);
  
  fill(200, 40, 90);
  stroke(200,40, 90);
  
  triangle(x[0], y[0], x[5], y[5], x[6], y[6]);
  triangle(x[0], y[0], x[6], y[6], x[1], y[1]);
  
  stroke(200, 5, 90);
  
  line(x[1], y[1], x[2], y[2]);
  line(x[2], y[2], x[3], y[3]);
  line(x[3], y[3], x[4], y[4]);
  line(x[4], y[4], x[5], y[5]);
  line(x[5], y[5], x[6], y[6]);
  line(x[6], y[6], x[1], y[1]);
  
  line(x[1], y[1], x[4], y[4]);
  line(x[2], y[2], x[5], y[5]);
  line(x[3], y[3], x[6], y[6]);
  
  save("out_80x80.png");
  exit();
}
