int width  = 500;
int height = 500;
ArrayList points;
int curr_idx = 0;

void setup()
{
  size(width, height);
  background(0, 1);
  
  setPoints();
}

void draw()
{
  translate(0, height);
  
  noFill();
  stroke(255, 255, 255, 0.5);
  
  strokeWeight(0.1);
  
  int[] pt = new int[2];
  
  beginShape();
  for(int i = 0; i < curr_idx; i++){
    pt = points.get(i);
    curveVertex(pt[0], pt[1]);
  }
  endShape();
  
}

void setPoints()
{  
  points = new ArrayList();
  
  int len = width - (int)random(height/2);
  int p_num = len / 10;
  
  int step = len / p_num + (int)random(5, 1);
  int start_x = (int)Math.random() * width;
  
  int yure = (int)random(6, 2);
  
  int[] pt = new int[2];
  
  for(int i = 0; i < p_num; i++){
    pt[0] = start_x + (int)random(yure, -yure);
    pt[1] = -step * i;
    points.add(pt);
    if(i==0){
      points.add(points.get(0));
    }
  }
  points.add(pt);
}
