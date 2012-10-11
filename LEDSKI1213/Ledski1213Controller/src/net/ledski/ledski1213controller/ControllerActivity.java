package net.ledski.ledski1213controller;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.SeekBar;
import android.widget.Toast;

public class ControllerActivity extends Activity {

    private SharedPreferences mShared;

    private static final String TAG = "Ledski1213Controller";

    //
    private int     mStateCtrlMode  = 0x0;
    private boolean mStateCtrlPwm   = false;
    private boolean mStateCtrlPower = false;

    // UIパーツ群
    private Button mPowerButton;
    private Button mPwmButton;
    private Button mModeButton;
    private Button mBehaviorRedButton;
    private Button mBehaviorGreenButton;
    private Button mBehaviorBlueButton;
    //private Button mResetButton;
    private SeekBar mRedSeekBar;
    private SeekBar mGreenSeekBar;
    private SeekBar mBlueSeekBar;
    //private SeekBar mAttSeekBar;
    private SeekBar mGammaSeekBar;

    private String[] mBehaviorButtonLavels = new String[]{"X連動","Y連動","Z連動","手動"};

    // Bluetooth
    private String               mConnectedDeviceName      = null; /**< Name of the connected device */
    //private ArrayAdapter<String> mConversationArrayAdapter;        /**< Array adapter for the conversation thread */
    private BluetoothAdapter     mBluetoothAdapter         = null; /**< Local Bluetooth adapter */
    private BluetoothChatService mChatService = null;              /**< Member object for the chat services */

    // Intent request codes
    private static final int REQUEST_CONNECT_DEVICE = 1;
    private static final int REQUEST_ENABLE_BT      = 2;

    // Message types sent from the BluetoothChatService Handler
    public static final int MESSAGE_STATE_CHANGE = 1;
    public static final int MESSAGE_READ = 2;
    public static final int MESSAGE_WRITE = 3;
    public static final int MESSAGE_DEVICE_NAME = 4;
    public static final int MESSAGE_TOAST = 5;

    // Key names received from the BluetoothChatService Handler
    public static final String DEVICE_NAME = "device_name";
    public static final String TOAST = "toast";

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_controller);

        // UIパーツ取得
        mPowerButton           = (Button) this.findViewById(R.id.buttonPower);
        mPwmButton             = (Button) this.findViewById(R.id.buttonPWM);
        mModeButton            = (Button) this.findViewById(R.id.buttonMode);
        //mBehaviorRedButton   = (Button)this.findViewById(R.id.buttonRed);
        //mBehaviorGreenButton = (Button) this.findViewById(R.id.buttonGreen);
        //mBehaviorBlueButton  = (Button) this.findViewById(R.id.buttonBlue);
        //mResetButton         = (Button) this.findViewById(R.id.buttonReset);
        mRedSeekBar          = (SeekBar) this.findViewById(R.id.seekBarRed);
        mGreenSeekBar        = (SeekBar) this.findViewById(R.id.seekBarGreen);
        mBlueSeekBar         = (SeekBar) this.findViewById(R.id.seekBarBlue);
        //mAttSeekBar          = (SeekBar) this.findViewById(R.id.seekBarAtt);
        mGammaSeekBar          = (SeekBar) this.findViewById(R.id.seekBarGamma);

        // UIパーツリスナ登録
        mPowerButton.setOnClickListener(mOnCtrlButtonClick);
        mPwmButton.setOnClickListener(mOnCtrlButtonClick);
        mModeButton.setOnClickListener(mOnCtrlButtonClick);
        //mBehaviorRedButton.setOnClickListener(mOnBehaviorButtonClick);
        //mBehaviorGreenButton.setOnClickListener(mOnBehaviorButtonClick);
        //mBehaviorBlueButton.setOnClickListener(mOnBehaviorButtonClick);
        //mResetButton.setOnClickListener(mOnResetButtonClick);
        mRedSeekBar.setOnSeekBarChangeListener(mOnRGBSeekBarChange);
        mGreenSeekBar.setOnSeekBarChangeListener(mOnRGBSeekBarChange);
        mBlueSeekBar.setOnSeekBarChangeListener(mOnRGBSeekBarChange);
        mGammaSeekBar.setOnSeekBarChangeListener(mOnGammaSeekBarChange);
        //mAttSeekBar.setOnSeekBarChangeListener(mOnATTSeekBarChange);

        // SharedPreferenceの読み込み
        mShared = this.getSharedPreferences("shared", Context.MODE_PRIVATE);

        // UI部品初期化
        //changeRGBBehaivor(mRedSeekBar, mBehaviorRedButton, mShared.getInt("behavior_red", 0));
        //changeRGBBehaivor(mGreenSeekBar, mBehaviorGreenButton, mShared.getInt("behavior_green", 1));
        //changeRGBBehaivor(mBlueSeekBar, mBehaviorBlueButton, mShared.getInt("behavior_blue", 2));
        mRedSeekBar.setProgress(255);
        mRedSeekBar.setMax(255);
        mGreenSeekBar.setProgress(255);
        mGreenSeekBar.setMax(255);
        mBlueSeekBar.setProgress(255);
        mBlueSeekBar.setMax(255);
        mGammaSeekBar.setProgress(127);
        mGammaSeekBar.setMax(255);

        // Get local Bluetooth adapter
        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        // If the adapter is null, then Bluetooth is not supported
        if (mBluetoothAdapter == null) {
            Toast.makeText(this, "Bluetooth is not available", Toast.LENGTH_LONG).show();
            finish();
            return;
        }

    }

    @Override
    public void onStart() {
        super.onStart();

        // If BT is not on, request that it be enabled.
        // setupChat() will then be called during onActivityResult
        if (!mBluetoothAdapter.isEnabled()) {
            Intent enableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableIntent, REQUEST_ENABLE_BT);
        // Otherwise, setup the chat session
        } else {
            if (mChatService == null) setupChat();
        }
    }

    private void setupChat() {
        Log.d(TAG, "setupChat()");

        /*
        // Initialize the array adapter for the conversation thread
        mConversationArrayAdapter = new ArrayAdapter<String>(this, R.layout.message);
        mConversationView = (ListView) findViewById(R.id.in);
        mConversationView.setAdapter(mConversationArrayAdapter);

        // Initialize the compose field with a listener for the return key
        mOutEditText = (EditText) findViewById(R.id.edit_text_out);
        mOutEditText.setOnEditorActionListener(mWriteListener);

        // Initialize the send button with a listener that for click events
        mSendButton = (Button) findViewById(R.id.button_send);
        mSendButton.setOnClickListener(new OnClickListener() {
            public void onClick(View v) {
                // Send a message using content of the edit text widget
                TextView view = (TextView) findViewById(R.id.edit_text_out);
                String message = view.getText().toString();
                sendMessage(message);
            }
        });*/

        // Initialize the BluetoothChatService to perform bluetooth connections
        mChatService = new BluetoothChatService(this, mHandler);
    }

    // The Handler that gets information back from the BluetoothChatService
    private final Handler mHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
            case MESSAGE_STATE_CHANGE:
                //if(D) Log.i(TAG, "MESSAGE_STATE_CHANGE: " + msg.arg1);
                switch (msg.arg1) {
                case BluetoothChatService.STATE_CONNECTED:
                    //mTitle.setText(R.string.title_connected_to);
                    //mTitle.append(mConnectedDeviceName);
                    //mConversationArrayAdapter.clear();
                    break;
                case BluetoothChatService.STATE_CONNECTING:
                    //mTitle.setText(R.string.title_connecting);
                    break;
                case BluetoothChatService.STATE_LISTEN:
                case BluetoothChatService.STATE_NONE:
                    //mTitle.setText(R.string.title_not_connected);
                    break;
                }
                break;
            case MESSAGE_WRITE:
                byte[] writeBuf = (byte[]) msg.obj;
                // construct a string from the buffer
                String writeMessage = new String(writeBuf);
                //mConversationArrayAdapter.add("Me:  " + writeMessage);
                break;
            case MESSAGE_READ:
                byte[] readBuf = (byte[]) msg.obj;
                // construct a string from the valid bytes in the buffer
                String readMessage = new String(readBuf, 0, msg.arg1);
                //mConversationArrayAdapter.add(mConnectedDeviceName+":  " + readMessage);
                break;
            case MESSAGE_DEVICE_NAME:
                // save the connected device's name
                mConnectedDeviceName = msg.getData().getString(DEVICE_NAME);
                Toast.makeText(getApplicationContext(), "Connected to "
                               + mConnectedDeviceName, Toast.LENGTH_SHORT).show();
                break;
            case MESSAGE_TOAST:
                Toast.makeText(getApplicationContext(), msg.getData().getString(TOAST),
                               Toast.LENGTH_SHORT).show();
                break;
            }
        }
    };

    @Override
    public synchronized void onResume() {
        super.onResume();

        // Performing this check in onResume() covers the case in which BT was
        // not enabled during onStart(), so we were paused to enable it...
        // onResume() will be called when ACTION_REQUEST_ENABLE activity returns.
        if (mChatService != null) {
            // Only if the state is STATE_NONE, do we know that we haven't started already
            if (mChatService.getState() == BluetoothChatService.STATE_NONE) {
              // Start the Bluetooth chat services
              mChatService.start();
            }
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_controller, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        Intent intent;
        switch (item.getItemId()) {
        case R.id.menu_settings:
            // TODO: コマンド設定Activityへの遷移
            //intent = new Intent(this, PreferenceActivity.class);
            //startActivity(intent);
            return true;
        case R.id.menu_scan:
            // Launch the DeviceListActivity to see devices and do scan
            intent = new Intent(this, DeviceListActivity.class);
            startActivityForResult(intent, REQUEST_CONNECT_DEVICE);
            return true;
        case R.id.menu_discoverable:
            // Ensure this device is discoverable by others
            ensureDiscoverable();
            return true;
        }
        return false;
    }

    private void ensureDiscoverable() {
        if (mBluetoothAdapter.getScanMode() !=
            BluetoothAdapter.SCAN_MODE_CONNECTABLE_DISCOVERABLE) {
            Intent discoverableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_DISCOVERABLE);
            discoverableIntent.putExtra(BluetoothAdapter.EXTRA_DISCOVERABLE_DURATION, 300);
            startActivity(discoverableIntent);
        }
    }

    /** コントロール系ボタンを押したとき */
    private View.OnClickListener mOnCtrlButtonClick = new View.OnClickListener() {
        @Override
        public void onClick(View view) {
            switch(view.getId()){
            case R.id.buttonMode:
                mStateCtrlMode++;
                if(mStateCtrlMode >= 3){
                    mStateCtrlMode = 0;
                }
                break;
            case R.id.buttonPWM:
                mStateCtrlPwm = !mStateCtrlPwm;
                break;
            case R.id.buttonPower:
                mStateCtrlPower = !mStateCtrlPower;
                break;
            }
            //sendMessage("点灯/消灯ボタンが押された\r\n");
            sendCommand(new byte[]{(byte) mShared.getInt("power_on_address", getResources().getInteger(R.integer.default_power_on_address)), (byte) mShared.getInt("power_on_data", getResources().getInteger(R.integer.default_power_on_data))});
            // FIXME 上記コマンド
        }
    };

    /** RGB挙動変更ボタンを押したとき */
    /*private View.OnClickListener mOnBehaviorButtonClick = new View.OnClickListener() {
        @Override
        public void onClick(View view) {
            String key = "";
            SeekBar seekBar = null;
            switch(view.getId()){
            case R.id.buttonRed:
                key = "behavior_red";
                seekBar = mRedSeekBar;
                break;
            case R.id.buttonGreen:
                key = "behavior_green";
                seekBar = mGreenSeekBar;
                break;
            case R.id.buttonBlue:
                key = "behavior_blue";
                seekBar = mBlueSeekBar;
                break;
            default:
                return;
            }
            int behavior = mShared.getInt(key, 0) + 1;
            if(behavior >= 4){
                behavior = 0;
            }
            mShared.edit().putInt(key, behavior).commit();
            changeRGBBehaivor(seekBar, (Button)view, behavior);
        }
    };*/

    /** RGB挙動変更ボタンとシークバーの状態を変更 */
    /*private void changeRGBBehaivor(SeekBar seekBar, Button button, int behavior){
        button.setText(mBehaviorButtonLavels[behavior]);
        if(behavior == 3){
            seekBar.setEnabled(true);
            seekBar.setClickable(true);
        }else{
            seekBar.setEnabled(false);
            seekBar.setClickable(false);
        }
    }*/

    /** [SWリセット]ボタンを押したとき */
    /*private View.OnClickListener mOnResetButtonClick = new View.OnClickListener() {

        @Override
        public void onClick(View view) {
            // TODO 自動生成されたメソッド・スタブ

        }
    };*/

    /** RGBシークバーが操作されたとき */
    private SeekBar.OnSeekBarChangeListener mOnRGBSeekBarChange = new SeekBar.OnSeekBarChangeListener() {
        @Override
        public void onStopTrackingTouch(SeekBar seekBar) {
        }

        @Override
        public void onStartTrackingTouch(SeekBar seekBar) {
        }

        @Override
        public void onProgressChanged(SeekBar seekBar, int progress,
                boolean fromUser) {
            switch(seekBar.getId()){
            case R.id.seekBarRed:
                break;
            case R.id.seekBarGreen:
                break;
            case R.id.seekBarBlue:
                break;
            default:
                return;
            }
            // TODO コマンド送信
        }
    };

    /** Gammaシークバーが操作されたとき */
    private SeekBar.OnSeekBarChangeListener mOnGammaSeekBarChange = new SeekBar.OnSeekBarChangeListener() {

        @Override
        public void onStopTrackingTouch(SeekBar seekBar) {
        }

        @Override
        public void onStartTrackingTouch(SeekBar seekBar) {
        }

        @Override
        public void onProgressChanged(SeekBar seekBar, int progress,
                boolean fromUser) {
            // TODO コマンド送信
        }
    };

    private void sendCommand(byte[] command){
        // Check that we're actually connected before trying anything
        if (mChatService.getState() != BluetoothChatService.STATE_CONNECTED) {
            Toast.makeText(this, R.string.not_connected, Toast.LENGTH_SHORT).show();
            return;
        }

        // Check that there's actually something to send
        if (command.length > 1) {
            // Get the message bytes and tell the BluetoothChatService to write
            mChatService.write(command);

            // Reset out string buffer to zero and clear the edit text field
            //mOutStringBuffer.setLength(0);
            //mOutEditText.setText(mOutStringBuffer);
        }

    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
        case REQUEST_CONNECT_DEVICE:
            // When DeviceListActivity returns with a device to connect
            if (resultCode == Activity.RESULT_OK) {
                // Get the device MAC address
                String address = data.getExtras()
                                     .getString(DeviceListActivity.EXTRA_DEVICE_ADDRESS);
                // Get the BLuetoothDevice object
                BluetoothDevice device = mBluetoothAdapter.getRemoteDevice(address);
                // Attempt to connect to the device
                mChatService.connect(device);
            }
            break;
        case REQUEST_ENABLE_BT:
            // When the request to enable Bluetooth returns
            if (resultCode == Activity.RESULT_OK) {
                // Bluetooth is now enabled, so set up a chat session
                //TODO setupChat();
            } else {
                // User did not enable Bluetooth or an error occured
                Log.d(TAG, "BT not enabled");
                Toast.makeText(this, R.string.bt_not_enabled_leaving, Toast.LENGTH_SHORT).show();
                finish();
            }
        }
    }

    /** キー操作のオーバーライド */
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        switch(keyCode){
        case KeyEvent.KEYCODE_BACK:
        case KeyEvent.KEYCODE_HOME:
        case KeyEvent.KEYCODE_MENU:
        case KeyEvent.KEYCODE_SEARCH:
        }
        return false;
    }

    /** 初期コマンド送信（connect時に実行、UIの状態を全部送信して同期する） */
    private void sendInitialCommand(){
        // UI状態取得
        // TODO

        // ここでコマンド生成でもいいかも

        // コマンド送信
        sendCommand(new byte[]{}); // Ctrl系
        sendCommand(new byte[]{}); // Red
        sendCommand(new byte[]{}); // Green
        sendCommand(new byte[]{}); // Blue
        sendCommand(new byte[]{}); // γ
    }
}