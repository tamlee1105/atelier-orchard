package net.kimnii.bluetoothtouchpad;

import java.util.ArrayList;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.Path;
import android.util.Log;
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
    private int mBackgroundColor;
    private ArrayList<Circle> mCircles = new ArrayList<Circle>();

    public TouchPadView(Context context) {
        super(context);
        mTag = context.getString(R.string.app_name);

        mSurfaceHolder = this.getHolder();
        mSurfaceHolder.addCallback(mSurfaceHolderCallback);

        mPaint.setColor(Color.WHITE);
        mPaint.setStrokeWidth(4);
        mPaint.setStyle(Style.STROKE);
        mBackgroundColor = Color.BLACK;
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
                // TODO canvas の null チェック（終了時に不具合）
                canvas.drawColor(mBackgroundColor); // 動作してない？
                canvas.drawPath(mPath, mPaint);
                for(Circle circle : mCircles){
                    if(!circle.draw(canvas, elapsedTime)){
                        ; // けす？
                    }
                }
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
        Paint paint = new Paint();
        paint.setColor(Color.WHITE);
        paint.setStrokeWidth(4);
        paint.setStyle(Style.FILL);
        mCircles.add(new Circle(x, y, 10f, paint));
        mBackgroundColor = yuv2rgb(255f, (255f * x / this.getWidth() - 128f), (255f * y / this.getHeight() - 128f));
        //Log.d(mTag, "onTouch() mBackgroundColor: " + String.format("0x%08X", mBackgroundColor));
        return (this.mOnTouchListener == null ) ? true : this.mOnTouchListener.onTouch(this, event);
    }

    private class Circle {
        float x;
        float y;
        float r;
        Paint paint;

        Circle(float x, float y, float r, Paint paint){
            this.x = x;
            this.y = y;
            this.r = r;
            this.paint = paint;
        }

        public boolean draw(Canvas canvas, long time){
            if(--r > 0){
                canvas.drawCircle(x, y, r, paint);
            }
            return false;
        }
    }

    private int yuv2rgb(float y, float u, float v){
        int r = (int) (y             + 1.402 + v);
        int g = (int) (y - 0.344 * u - 0.714 * v);
        int b = (int) (y + 1.772 * u);
        return (r << 16) | (g << 8) | b;
    }

}
