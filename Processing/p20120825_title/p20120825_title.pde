import processing.video.*;

MovieMaker       mm;
ArrayList<ULine> underLines;            // 下線
ArrayList<Title> titles;                // テキスト
boolean          still;                 // 静止(Spaceキーで切替可)
float            title_speed;           // 速さ
int              state;
String           t_string  = "Traffic"; // テキストの内容
int              repeat    = 8;         // 繰り返し回数
final boolean    dump      = true;      // 動画ダンプ
String           font_name = "BroadwayBT-Regular"; // フォント名

void setup() {
  size(640, 480);
  frameRate(30);
  colorMode(HSB, 360, 100, 100);
  underLines = new ArrayList<ULine>();
  titles     = new ArrayList<Title>();
  for(int i = 0; i < 2; ++i){
    int t = ((int)random(0xFF) & 0x1) == 0x0 ? 1: -1;
    int y = (int)random(20, height);
    float speed_y = t * random(30) / 10f;
    int b = (int)random(4, 10);
    underLines.add(new ULine(width, y, width, y, -50f, speed_y, color(0, 0, 100), b));
    titles.add(new Title(width, y, -50f, speed_y, 7*b));
  }
  still       = false;
  title_speed = 0f;
  state       = 0;
  smooth();
  if(repeat > 0 && dump){
    mm = new MovieMaker(this, width, height, "title.mov", 30, MovieMaker.CINEPAK, MovieMaker.BEST);
  }
}

void draw() {
  if(still){
    return;
  }
  
  ArrayList<ULine> invalid_ulines = new ArrayList<ULine>();
  ArrayList<Title> invalid_titles = new ArrayList<Title>();
  
  background(0, 0, 0);
  
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
    title.draw(title_speed);
  }
  
  if(dump){
    mm.addFrame();
  }
  
  switch(state){
    case 0:
      if(underLines.get(0).ex <= 0){
        title_speed = 1f;
        state = 1;
      }
      break;
    case 1:
      for(ULine uline : underLines){
        uline.setStill(true);
      }
      if(titles.get(0).x <= width/2){
        title_speed = 0.06;
        state = 2;
      }
      break;
    case 2:
      if(titles.get(0).x <= 10){
        title_speed = 1f;
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
        title_speed = 0f;
        state = 0;
        --repeat;
        if(0 >= repeat){
          if(dump){
            mm.finish();
          }
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
    this.font = createFont(font_name, this.t_size, true);
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
