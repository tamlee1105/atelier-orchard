package net.kimnii.bluetoothtouchpad;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.widget.LinearLayout;

public class TouchPadActivity extends Activity {

    private String mTag;
    private TouchPadView mTouchPadView;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_touch_pad);

        mTag = getString(R.string.app_name);

        mTouchPadView = new TouchPadView(this);

        LinearLayout linearLayoutTouchPad = (LinearLayout)findViewById(R.id.linearLayoutTouchPad);
        //linearLayoutTouchPad.addView(mTouchPadView, new LayoutParams());
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_touch_pad, menu);
        return true;
    }

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
