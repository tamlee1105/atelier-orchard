package net.kimnii.bluetoothtouchpad;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.Path;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;

public class TouchPadView extends SurfaceView {

    private String mTag;
    private SurfaceHolder mSurfaceHolder;
    private Thread mDrawingThread; /**< 描画処理スレッド */
    private long mFrameDuration = 1000 / 15;
    private View.OnTouchListener mOnTouchListener;

    private Path mPath = new Path();
    private Paint mPaint = new Paint();

    public TouchPadView(Context context) {
        super(context);
        mTag = context.getString(R.string.app_name);

        mSurfaceHolder = this.getHolder();
        mSurfaceHolder.addCallback(mSurfaceHolderCallback);

        mPaint.setColor(Color.WHITE);
        mPaint.setStrokeWidth(4);
        mPaint.setStyle(Style.STROKE);
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
    private Runnable mRunnableDraw = new Runnable(){
        @Override
        public void run() {
            final long startTime = System.currentTimeMillis();
            while(true){
                long frameStartTime = System.currentTimeMillis();
                long elapsedTime = frameStartTime - startTime;
                Canvas canvas = mSurfaceHolder.lockCanvas();
                //canvas.drawColor(Color.BLUE);
                canvas.drawPath(mPath, mPaint);
                //canvas.drawCircle(x, y, 50, mPaint);
                mSurfaceHolder.unlockCanvasAndPost(canvas);
                try {
                    long sleepTime = mFrameDuration - (System.currentTimeMillis() - frameStartTime);
                    if(sleepTime > 0){
                    Thread.sleep(sleepTime);
                    }
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    };

    @Override
    public void setOnTouchListener (View.OnTouchListener listener){
        this.mOnTouchListener = listener;
    }

    /** タッチ処理 */
    @Override
    public boolean onTouchEvent(MotionEvent event){
        float x = event.getX();
        float y = event.getY();
        //Log.d(mTag, "onTouch() x: " + x + " y: " + y);
        switch(event.getAction()){
        case MotionEvent.ACTION_DOWN:
            mPath.moveTo(x, y);
            break;
        case MotionEvent.ACTION_MOVE:
            mPath.lineTo(x, y);
            break;
        case MotionEvent.ACTION_UP:
            break;
        }
        return (this.mOnTouchListener == null ) ? true : this.mOnTouchListener.onTouch(this, event);
    }

    private class Circle {

    }

}
