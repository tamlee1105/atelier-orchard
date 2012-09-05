import processing.video.*;
MovieMaker mm;
ArrayList<ULine> underLines;
ArrayList<Title> titles;
String t_string = "Traffic";
boolean still;
float speed_title;
int state;
int turn = 8;

void setup() {
  size(640, 480);
  frameRate(30);
  colorMode(HSB, 360, 100, 100);
  //font = createFont("AcademyEngravedLetPlain", 20, true);
  //smooth();
  underLines = new ArrayList<ULine>();
  titles = new ArrayList<Title>();
  //font = createFont("HGSKyokashotai", 20, true);
  for(int i = 0; i < 2; ++i){
    int t = ((int)random(0xFF) & 0x1) == 0x0 ? 1: -1;
    int y = (int)random(20, height);
    float speed_y = t * random(30) / 10f;
    int b = (int)random(4, 10);
    underLines.add(new ULine(width, y, width, y, -50f, speed_y, color(0, 0, 100), b));
    titles.add(new Title(width, y, -50f, speed_y, 7*b));
  }
  still = false;
  speed_title = 0f;
  state = 0;
  smooth();
  if(turn > 0) mm = new MovieMaker(this, width, height, "title_11.mov", 30, MovieMaker.CINEPAK, MovieMaker.BEST);
}

void draw() {
  if(still) return;
  
  ArrayList<ULine> invalid_ulines = new ArrayList<ULine>();
  ArrayList<Title> invalid_titles = new ArrayList<Title>();
  
  background(0, 0, 0);
  //fill(color((int)random(180, 195), 80, 100));
  //textFont(font);
  //textSize(text_size);
  
  
  /* renew */
  for(ULine uline : underLines){
    uline.draw();
    if(uline.sx <= 0){
       invalid_ulines.add(uline);
    }
  }
  for (ULine invalid_uline : invalid_ulines) {
    underLines.remove(underLines.indexOf(invalid_uline));
  }
  
  for(Title title : titles){
    title.draw(speed_title);
    //if(title.x + textWidth(t_string) <= 0){
    //   invalid_titles.add(title);
    //}
  }
  //for (Title invalid_title : invalid_titles) {
  //  titles.remove(titles.indexOf(invalid_title));
  //}
  mm.addFrame();
  
  switch(state){
    case 0:
      if(underLines.get(0).ex <= 0){
        speed_title = 1f;
        state = 1;
      }
      break;
    case 1:
      for(ULine uline : underLines){
        uline.setStill(true);
      }
      if(titles.get(0).x <= (width/* - textWidth(t_string)*/)/2){
        speed_title = 0.06;
        state = 2;
      }
      break;
    case 2:
      if(titles.get(0).x <= 10){
        speed_title = 1f;
        state = 3;
      }
      break;
    case 3:
      if(titles.get(0).x <= -20){
        state = 4;
      }
      break;
    case 4:
      for(ULine uline : underLines){
        uline.setStill(false);
        uline.setVanish(true);
      }
      state = 5;
      break;
    case 5:
      /* addition */
      if(underLines.size() == 0){
        titles.clear();
        for(int i = 0; i < 2; ++i){
          int t = ((int)random(0xFF) & 0x1) == 0x0 ? 1: -1;
          int y = (int)random(height);
          float speed_y = t * random(30) / 10f;
          int b = (int)random(4, 10);
          underLines.add(new ULine(width, y, width, y, -50f, speed_y, color(0, 0, 100), b));
          titles.add(new Title(width, y, -50f, speed_y, 7*b));
        }
        speed_title = 0f;
        state = 0;
        --turn;
        if(0 >= turn){
          mm.finish();  // Finish the movie if space bar is pressed!
          exit();
        }
      }
      break;
  }
}

class Title {
  float x, y;
  float speed_x, speed_y;
  float angle;
  int t_size;
  PFont font;
  
  Title(float x, float y, float speed_x, float speed_y, int t_size){
    this.x = x;
    this.y = y;
    this.speed_x = speed_x;
    this.speed_y = speed_y;
    this.angle = atan2(-speed_y, -speed_x);
    this.t_size = t_size;
    this.font = createFont("BroadwayBT-Regular", this.t_size, true);
  }
  
  void draw(float ax){
    this.x += (ax * speed_x);
    this.y += (ax * speed_y);
    pushMatrix();
    translate(this.x, this.y);
    rotate(this.angle);
    textFont(font);
    textSize(this.t_size);
    text(t_string, 0, 0);
    //rotate(0);
    //translate(0, 0);
    popMatrix();
  }
}

class ULine {
  float sx, sy, ex, ey;
  int w;
  float shift_speed_x, shift_speed_y;
  color c;
  boolean vanish;
  boolean still;

  ULine(float sx, float sy, float ex, float ey, float speed_x, float speed_y, color c, int stroke_width){
    this.sx = sx;
    this.sy = sy;
    this.ex = ex;
    this.ey = ey;
    this.shift_speed_x = speed_x;
    this.shift_speed_y = speed_y;
    this.c  = c;
    this.w = stroke_width;
    this.vanish = false;
    this.still = false;
  }
  
  void draw(){
    if(!this.still){
      if(this.ex > 0 && !this.vanish){
        this.ex += this.shift_speed_x;
        this.ey += this.shift_speed_y;
      }else if(this.vanish){
        this.sx += this.shift_speed_x;
        this.sy += this.shift_speed_y;
      }
    }
    strokeWeight(w);
    stroke(this.c);
    line(sx, sy, ex, ey);
  }
  
  void setStill(boolean b){
    this.still = b;
  }
  
  void setVanish(boolean b){
    this.vanish = b;
  }
}

void keyPressed() {
  if (key == ' ') {
    still = !still;
  }
}
