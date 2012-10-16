package net.kimnii.bluetoothtouchpad;

import android.content.Context;
import android.graphics.Canvas;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;

public class TouchPadView extends SurfaceView {

    SurfaceHolder mSurfaceHolder;
    Thread mDrawingThread; /**< 描画処理スレッド */

    public TouchPadView(Context context) {
        super(context);
        mSurfaceHolder = this.getHolder();
        mSurfaceHolder.addCallback(mSurfaceHolderCallback);
    }

    private SurfaceHolder.Callback mSurfaceHolderCallback = new SurfaceHolder.Callback(){

        @Override
        public void surfaceChanged(SurfaceHolder holder, int format,
                int width, int height) {
        }

        @Override
        public void surfaceCreated(SurfaceHolder holder) {
            mDrawingThread = new Thread(mRunnableDraw);
            mDrawingThread.start();
        }

        @Override
        public void surfaceDestroyed(SurfaceHolder holder) {
            mDrawingThread = null;
        }

    };

    /** 描画処理 */
    Runnable mRunnableDraw = new Runnable(){
        @Override
        public void run() {
            Canvas canvas = mSurfaceHolder.lockCanvas();
            //描画オブジェクトの更新、描画
            mSurfaceHolder.unlockCanvasAndPost(canvas);
        }
    };

    /** タッチ処理 */
    @Override
    public boolean onTouchEvent(MotionEvent event){
        int x = (int)event.getX();
        int y = (int)event.getY();
        switch(event.getAction()){
        case MotionEvent.ACTION_DOWN:
            break;
        case MotionEvent.ACTION_MOVE:
            break;
        case MotionEvent.ACTION_UP:
            break;
        }
        return false;
    }

}
