/**
 * 
 * 
 * (http://www.jhlabs.com/ip/blurring.html)
 */

PImage img, img2;

void setup() {
  frameRate(15);
  colorMode(RGB, 255, 255, 255, 100);
  img  = loadImage("../p20120619_Distortion/hana.jpg");
  size(img.width<<1, img.height, P2D);
  img2 = new PImage(img.width, img.height);
}

void draw() 
{ 
  //boxBlur(img, img); // こうすると徐々にぼやける効果になる
  boxBlur(img2, img);
  background(0);
  image(img, 0, 0);
  image(img2, img.width, 0);
}

	
    void boxBlur(PImage dst, PImage src) {
        int hRadius = 5;
        int vRadius = 5;
        int iterations = 1;
        int w = src.width;
        int h = src.height;

        if ( dst == null )
            dst = new PImage(w, h);
        
        PImage tmp = new PImage(w, h); 

        for (int i = 0; i < iterations; i++ ) {
            blur( src, tmp, w, h, hRadius );
            blur( tmp, dst, h, w, vRadius );
        }
    }

    void blur( PImage in, PImage out, int w, int h, int r) {
        int widthMinus1 = w-1;
        int tableSize = 2*r+1;
        int divide[] = new int[256*tableSize];

        for ( int i = 0; i < 256*tableSize; i++ )
            divide[i] = i/tableSize;

        int inIndex = 0;
        
        for ( int y = 0; y < h; y++ ) {
            int outIndex = y;
            int ta = 0, tr = 0, tg = 0, tb = 0;

            for ( int i = -r; i <= r; i++ ) {
                int rgba = in.pixels[inIndex + min(max(i, 0), w-1)];
                ta += (rgba >> 24) & 0xff;
                tr += (rgba >> 16) & 0xff;
                tg += (rgba >> 8) & 0xff;
                tb += rgba & 0xff;
            }

            for ( int x = 0; x < w; x++ ) {
                out.pixels[ outIndex ] = (divide[ta] << 24) | (divide[tr] << 16) | (divide[tg] << 8) | divide[tb];

                int i1 = x+r+1;
                if ( i1 > widthMinus1 )
                    i1 = widthMinus1;
                int i2 = x-r;
                if ( i2 < 0 )
                    i2 = 0;
                int rgb1 = in.pixels[inIndex+i1];
                int rgb2 = in.pixels[inIndex+i2];
                
                ta += ((rgb1 >> 24) & 0xff)-((rgb2 >> 24) & 0xff);
                tr += ((rgb1 & 0xff0000)-(rgb2 & 0xff0000)) >> 16;
                tg += ((rgb1 & 0xff00)-(rgb2 & 0xff00)) >> 8;
                tb += (rgb1 & 0xff)-(rgb2 & 0xff);
                outIndex += h;
            }
            inIndex += w;
        }
    }
