package net.kimnii.bluetoothtouchpad;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;

public class TouchPadActivity extends Activity {

    private String mTag;
    private SurfaceView mSurfaceView;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_touch_pad);

        mTag = getString(R.string.app_name);

        mSurfaceView = (SurfaceView) this.findViewById(R.id.surfaceView);
        mSurfaceView.getHolder().addCallback(mSurfaceHolderCallback);
        mSurfaceView.setOnTouchListener(mOnTouchListener);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_touch_pad, menu);
        return true;
    }

    private SurfaceHolder.Callback mSurfaceHolderCallback = new SurfaceHolder.Callback(){

        @Override
        public void surfaceChanged(SurfaceHolder holder, int format,
                int width, int height) {
            Log.d(mTag, "surfaceChanged() w: " + width + "h: " + height);
        }

        @Override
        public void surfaceCreated(SurfaceHolder holder) {
            Log.d(mTag, "surfaceCreated()");
        }

        @Override
        public void surfaceDestroyed(SurfaceHolder holder) {
            Log.d(mTag, "surfaceDestroyed()");
        }

    };

    private View.OnTouchListener mOnTouchListener = new View.OnTouchListener(){
        @Override
        public boolean onTouch(View view, MotionEvent event) {
            switch(event.getAction()){
            case MotionEvent.ACTION_DOWN:
                break;
            case MotionEvent.ACTION_MOVE:
                break;
            case MotionEvent.ACTION_UP:
                break;
            }
            int x = (int)event.getX();
            int y = (int)event.getY();
            //Log.d(mTag, "onTouch() x: " + x + " y: " + y);
            return true;
        }
    };
}
