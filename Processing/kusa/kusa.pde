int d_width  = 500;
int d_height = 500;
ArrayList points_x, points_y;
int curr_idx = 0;

void setup()
{
  size(d_width, d_height);
  background(16, 1);
  
  setPoints();
  
  frameRate(10);
}

void draw()
{
  Integer pt_x = 0, pt_y = 0;
  translate(0, d_height);
  
  noFill();
  stroke(255, 255, 255, 0.5);
  
  strokeWeight(10);
  
  beginShape();
  for(int i = 0; i < curr_idx; i++){
    pt_x = (Integer)points_x.get(i);
    pt_y = (Integer)points_y.get(i);
    //print("[" + i + "] " + "x "+ pt_x + ", y " + pt_y + "\n");
    curveVertex(pt_x, pt_y);
  }
  curveVertex(pt_x, pt_y);
  endShape();
  
  strokeWeight(1);
  
  fill(255, 255, 255, 0.5);
  
  if(curr_idx > 0){
    pt_x = (Integer)points_x.get(curr_idx - 1);
    pt_y = (Integer)points_y.get(curr_idx - 1);
  }else{
    pt_x = (Integer)points_x.get(0);
    pt_y = (Integer)points_y.get(0);
  }
  
  int radius = (int)random(15,1);
  ellipse(pt_y + (int)random(15, -15), pt_y + random(10, -10), radius, radius);
  
  curr_idx++;
  
  if(curr_idx > points_x.size()){
    curr_idx = 0;
    setPoints();
  }
  
}

void setPoints()
{
  int pt_x = 0, pt_y = 0;  
  points_x = new ArrayList();
  points_y = new ArrayList();
  
  int len = d_width - (int)random(d_height/2);
  int p_num = len / 10;
  print("p_num " + p_num + "\n");
  
  int step = len / p_num + (int)random(5, 1);
  int start_x = (int)(Math.random() * d_width);
  
  int yure = (int)random(2, 6);
  
  for(int i = 0; i < p_num; i++){
    pt_x = start_x + (int)random(-yure, yure);
    pt_y = step * i;
    points_x.add(new Integer(pt_x));
    points_y.add(new Integer(pt_y));
    if(i==0){
      points_x.add(new Integer(pt_x));
      points_y.add(new Integer(pt_y));
    }
    //print("x "+ pt[0] + ", y " + pt[1] + "\n");
  }
  points_x.add(new Integer(pt_x));
  points_y.add(new Integer(pt_y));
}
