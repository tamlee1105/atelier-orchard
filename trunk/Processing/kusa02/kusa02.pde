ArrayList points_x, points_y;
int curr_idx = 0;
color mColor;

void setup()
{
  size(640, 480);
  background(16, 1);

  setRandomColor();
  setPoints();

  //colorMode(HSB, 360, 100, 100);
  colorMode(RGB, 255, 255, 255);

  //noStroke();

  smooth(); 
  
  frameRate(10);
}

void draw()
{
  Integer pt_x = 0, pt_y = 0;
  
  fill(0, 0, 0, 5); 
  rect(0, 0, width, height);
  translate(0, height);

  noFill();
  stroke(mColor);
  strokeWeight(2);
  
  beginShape();
  for(int i = 0; i < curr_idx; i++){
    pt_x = (Integer)points_x.get(i);
    pt_y = (Integer)points_y.get(i);
    //print("[" + i + "] " + "x "+ pt_x + ", y " + pt_y + "\n");
    curveVertex(pt_x, pt_y);
  }
  curveVertex(pt_x, pt_y);
  endShape();
  
  //-------------------------------------------
  
  if(curr_idx> 0 && curr_idx < points_x.size() - 1){
    if(curr_idx > 0){
      if(curr_idx > 0){
        pt_x = (Integer)points_x.get(curr_idx - 1);
        pt_y = (Integer)points_y.get(curr_idx - 1);
      }else{
        pt_x = (Integer)points_x.get(0);
        pt_y = (Integer)points_y.get(0);
      } 
      
      int branch_x =(int) random(0, 50);
      if(random(1)>0.5){
        branch_x *= -1;
      }
      int branch_y = (int)random(-50, -20);
      
      int branch_xx = branch_x + pt_x;
      int branch_yy = branch_y + pt_y;

      line(pt_x, pt_y, branch_xx, branch_yy);
      
      noStroke();
      fill(mColor);
      
      for(int i = 0; i < 5; i++){
        int radius = (int)random(4, 20);
        ellipse(branch_xx + (int)random(-10, 10), branch_yy + (int)random(-10, 10), radius, radius);
      }
    }
  }
  
  //-------------------------------------------
  
  if(curr_idx == 0){
    noStroke();
    fill(mColor, 50);
    int radius = 0;
    for(int i = 5; i < 5; i++){
      radius += i * (int)random(5, 15);
      pt_x = (Integer)points_x.get(1);
      pt_y = (Integer)points_y.get(1);
      ellipse(pt_x, pt_y, radius, radius);
    }
  }
  
  curr_idx++;
  
  if(curr_idx > points_x.size()){
    curr_idx = 0;
    //points_x = null;
    //points_y = null;
    setRandomColor();
    setPoints();
  }
  /*
  curr_idx++;
  
  if(curr_idx > points_x.size()){
    curr_idx = 0;
    setPoints();
  }
  */
  
}

void setPoints()
{
  int pt_x = 0, pt_y = 0;  
  points_x = new ArrayList();
  points_y = new ArrayList();
  
  int len = width - (int)random(height/1.5);
  int p_num = len / 10;
  //print("p_num " + p_num + "\n");
  
  int step = len / p_num + (int)random(5, 1);
  int start_x = (int)(Math.random() * width);
  
  int yure = (int)random(6, 2);
  
  for(int i = 0; i < p_num; i++){
    pt_x = start_x + (int)random(-yure, yure);
    pt_y = -step * i;
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

void setRandomColor()
{
  mColor =  color(random(50,200), random(50,200), random(50,200));
}
