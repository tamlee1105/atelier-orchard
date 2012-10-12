package net.ledski.ledski1213controller;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.widget.EditText;

public class PreferenceActivity extends Activity {

    private static final String TAG = "Ledski1213Controller";

    private SharedPreferences mShared;
    private EditText mEditTextPowerOnAddress;
    private EditText mEditTextPowerOnData;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_preference);

        // SharedPreferenceの読み込み
        mShared = this.getSharedPreferences("shared", Context.MODE_PRIVATE);

        this.setupEditTextViews();
    }

    /*
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_preference, menu);
        return true;
    }*/

    private void setupEditTextViews(){

        // 点灯コマンド（アドレス）
        mEditTextPowerOnAddress = (EditText) findViewById(R.id.editTextPowerOnAddress);
        mEditTextPowerOnAddress.setText(String.format("%02X", mShared.getInt("power_on_address", getResources().getInteger(R.integer.default_ctrl_address))));
        mEditTextPowerOnAddress.addTextChangedListener(new TextWatcher(){
            @Override
            public void afterTextChanged(Editable s) {
                mShared.edit().putInt("power_on_address", Byte.valueOf(s.toString().split("\r\n|\n\r|\r|\n", -1)[0], 16)).commit();
            }
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count,
                    int after) {
            }
            @Override
            public void onTextChanged(CharSequence s, int start, int before,
                    int count) {
            }
        });

        // 点灯コマンド（データ）
        mEditTextPowerOnData = (EditText) findViewById(R.id.editTextPowerOnData);
        mEditTextPowerOnData.setText(String.format("%02X", mShared.getInt("power_on_data", getResources().getInteger(R.integer.default_ctrl_address))));
        mEditTextPowerOnData.addTextChangedListener(new TextWatcher(){
            @Override
            public void afterTextChanged(Editable s) {
                mShared.edit().putInt("power_on_data", Integer.parseInt(s.toString().split("\r\n|\n\r|\r|\n", -1)[0], 16)).commit();
            }
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count,
                    int after) {
            }
            @Override
            public void onTextChanged(CharSequence s, int start, int before,
                    int count) {
            }
        });
    }
}
