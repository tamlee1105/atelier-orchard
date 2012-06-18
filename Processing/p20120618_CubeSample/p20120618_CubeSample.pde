/**
 * 
 * 
 * (http://r-dimension.xsrv.jp/classes_j/3_interactive3d/)
 */


float boxSize = 20;    //立方体のサイズ
float distance = 30;    //立方体同士の距離
float halfDis;    //立方体同士の一辺の全体の距離の半分
int boxNum = 6;    //立方体の数
 
void setup(){
  size(400, 400, P3D);
  halfDis = distance*(boxNum-1)/2;    //6個並んだ際の距離の半分
}
 
void draw(){
  background(0);
  stroke(255, 0, 0, 100);
  line(width/2, 0, width/2, height);
  line(0, height/2, width, height/2);
 
  translate(width/2, height/2);    //立体の中心を画面中央に移動   
  rotateY(radians(mouseX));
  rotateX(radians(mouseY));
 
  stroke(0);
  fill(255, 255, 255);    
 
  for(int z = 0; z < boxNum; z ++){    //立方体を、z軸方向に30ピクセルごとに並べて6個生成  
    for(int y = 0; y < boxNum; y ++){    //立方体を、y軸方向に30ピクセルごとに並べて6個生成  
      for(int x = 0; x < boxNum; x ++){    //立方体を、x軸方向に30ピクセルごとに並べて6個生成
        pushMatrix();
        translate(x*distance-halfDis, y*distance-halfDis, z*distance-halfDis);
        box(boxSize, boxSize, boxSize);    //20 x 20 x 20pxの立方体を描く
        popMatrix();
      }
    }
  }
}
