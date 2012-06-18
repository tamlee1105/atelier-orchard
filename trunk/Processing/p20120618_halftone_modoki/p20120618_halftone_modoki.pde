import processing.video.*;

Capture capture;
static final int W = 320;
static final int H = 240;

void setup() {
  size(W, H, P2D);
  frameRate(15);
  colorMode(RGB, 255, 255, 255, 100);
  capture = new Capture(this, W, H, 12);
}

void draw() 
{ 
  if (!capture.available()) {
    return;
  }

  capture.read();
  background(0);
  halftone(capture);
}

static final int BLOCK_SIZE = 8;
void halftone(PImage input)
{
  for (int x = 0; x < W; x+=BLOCK_SIZE) {
    for (int y = 0; y < H; y+=BLOCK_SIZE) {
      int ave = 0;
      for (int bx = x; bx < x + BLOCK_SIZE; ++bx) {
        for (int by = y; by < y + BLOCK_SIZE; ++by) {
          ave += brightness(input.pixels[x + y * W]);
        }
      }
      ave = ave >> 11;
      pushMatrix();
      translate(x+(BLOCK_SIZE>>1), y+(BLOCK_SIZE>>1));
      fill(255); 
      noStroke();
      ellipse(0, 0, ave, ave);
      popMatrix();
    }
  }

  return;
}

