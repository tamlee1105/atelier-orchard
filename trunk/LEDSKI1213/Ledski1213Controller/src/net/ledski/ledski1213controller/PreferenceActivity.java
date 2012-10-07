package net.ledski.ledski1213controller;

import android.os.Bundle;
import android.app.Activity;
import android.view.Menu;

public class PreferenceActivity extends Activity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_preference);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_preference, menu);
        return true;
    }
}
