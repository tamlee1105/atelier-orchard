package net.ledski.ledski1213controller;

import java.util.ArrayList;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Intent;
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
import android.widget.TextView;
import android.widget.Toast;

public class ControllerActivity extends Activity {

    //private SharedPreferences mShared;

    private static final String TAG = "Ledski1213Controller";

    //
    private int     mStateCtrlModeRed  = 0x0;
    private int     mStateCtrlModeGreen  = 0x0;
    private int     mStateCtrlModeBlue  = 0x0;
    private boolean mStateCtrlPwm   = false;
    private boolean mStateCtrlPower = false;

    // UIパーツ群
    private Button mPowerButton;
    private Button mPwmButton;
    //private Button mModeButton;
    private Button mBehaviorRedButton;
    private Button mBehaviorGreenButton;
    private Button mBehaviorBlueButton;
    //private Button mResetButton;
    private SeekBar mRedSeekBar;
    private SeekBar mGreenSeekBar;
    private SeekBar mBlueSeekBar;
    //private SeekBar mAttSeekBar;
    private SeekBar mGammaSeekBar;
    private TextView mEchoMonitorText;
    private TextView mBluetoothStatusText;

    private String[] mBehaviorButtonLavels = new String[]{" [手動]"," [デモ]"," [g-1ch]"," [g-2ch]", " [g-3ch]"};

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
        //mModeButton            = (Button) this.findViewById(R.id.buttonMode);
        mBehaviorRedButton   = (Button)this.findViewById(R.id.buttonRed);
        mBehaviorGreenButton = (Button) this.findViewById(R.id.buttonGreen);
        mBehaviorBlueButton  = (Button) this.findViewById(R.id.buttonBlue);
        //mResetButton         = (Button) this.findViewById(R.id.buttonReset);
        mRedSeekBar          = (SeekBar) this.findViewById(R.id.seekBarRed);
        mGreenSeekBar        = (SeekBar) this.findViewById(R.id.seekBarGreen);
        mBlueSeekBar         = (SeekBar) this.findViewById(R.id.seekBarBlue);
        //mAttSeekBar          = (SeekBar) this.findViewById(R.id.seekBarAtt);
        mGammaSeekBar          = (SeekBar) this.findViewById(R.id.seekBarGamma);
        mEchoMonitorText       = (TextView) this.findViewById(R.id.textViewEchoMonitor);
        mBluetoothStatusText                 = (TextView) this.findViewById(R.id.textViewBluetoothStatus);

        // UIパーツリスナ登録
        mPowerButton.setOnClickListener(mOnCtrlButtonClick);
        mPwmButton.setOnClickListener(mOnCtrlButtonClick);
        //mModeButton.setOnClickListener(mOnBehaviorButtonClick);
        mBehaviorRedButton.setOnClickListener(mOnBehaviorButtonClick);
        mBehaviorGreenButton.setOnClickListener(mOnBehaviorButtonClick);
        mBehaviorBlueButton.setOnClickListener(mOnBehaviorButtonClick);
        //mResetButton.setOnClickListener(mOnResetButtonClick);
        mRedSeekBar.setOnSeekBarChangeListener(mOnRGBSeekBarChange);
        mGreenSeekBar.setOnSeekBarChangeListener(mOnRGBSeekBarChange);
        mBlueSeekBar.setOnSeekBarChangeListener(mOnRGBSeekBarChange);
        mGammaSeekBar.setOnSeekBarChangeListener(mOnGammaSeekBarChange);
        //mAttSeekBar.setOnSeekBarChangeListener(mOnATTSeekBarChange);

        // SharedPreferenceの読み込み
        //mShared = this.getSharedPreferences("shared", Context.MODE_PRIVATE);

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
        mBehaviorRedButton.setText(mBehaviorButtonLavels[mStateCtrlModeRed]);
        mBehaviorGreenButton.setText(mBehaviorButtonLavels[mStateCtrlModeGreen]);
        mBehaviorBlueButton.setText(mBehaviorButtonLavels[mStateCtrlModeBlue]);
        mPwmButton.setText(getString(R.string.label_button_pwm) + (mStateCtrlPwm ? " [動作中]" : " [停止中]"));
        mPowerButton.setText(getString(R.string.label_button_power) + (mStateCtrlPower ? " [ON]" : " [OFF]"));

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
            if (mChatService == null) {
                mChatService = new BluetoothChatService(this, mHandler);
            }
        }
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
                    mBluetoothStatusText.setText(R.string.title_connected_to);
                    mBluetoothStatusText.append(mConnectedDeviceName);
                    //mConversationArrayAdapter.clear();
                    sendInitialCommand();
                    break;
                case BluetoothChatService.STATE_CONNECTING:
                    mBluetoothStatusText.setText(R.string.title_connecting);
                    break;
                case BluetoothChatService.STATE_LISTEN:
                case BluetoothChatService.STATE_NONE:
                    mBluetoothStatusText.setText(R.string.title_not_connected);
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
                String str = String.format("[%2dbytes] ", readBuf.length);
                for(int i = 0; i < readBuf.length; ++i){
                    str += String.format("%02X ", readBuf[i]);
                }
                ///Toast.makeText(getApplicationContext(), str, Toast.LENGTH_SHORT).show();
                mEchoMonitorText.setText(str);
                mCommandMarshaller.registerReceived(readBuf);
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

    /**  */
    private class CommandMarshaller {
        private boolean mSendable = true;
        private ArrayList<Byte> sendMessageBuffer = new ArrayList<Byte>();
        private ArrayList<Byte> receivedMessageBuffer = new ArrayList<Byte>();

        public void registerSent(byte[] command){
            /*mSendable = false;
            sendMessageBuffer.clear();
            receivedMessageBuffer.clear();
            for(int i = 0; i < command.length; ++i){
                sendMessageBuffer.add(command[i]);
            }*/
        }

        public void registerReceived(byte[] command){
            /*if(mSendable){
                return;
            }
            for(int i = 0; i < command.length; ++i){
                receivedMessageBuffer.add(command[i]);
            }
            //if(receivedMessageBuffer.size() != sendMessageBuffer.size()){
            //    return;
            //}
            for(int i = 0; i < sendMessageBuffer.size(); ++i){
                if(receivedMessageBuffer.get(i) != sendMessageBuffer.get(i)){
                    return;
                }
            }
            String str = "";
            for(int i = 0; i < sendMessageBuffer.size(); ++i){
                str += String.format("%02X ", receivedMessageBuffer.get(i));
            }
            mEchoMonitorText.setText(str);*/
            mSendable = true;
        }

        public boolean confirmSendable(){
            return mSendable;
        }
    }
    private CommandMarshaller mCommandMarshaller = new CommandMarshaller();

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
        /*
        case R.id.menu_settings:
            // TODO: コマンド設定Activityへの遷移
            //intent = new Intent(this, PreferenceActivity.class);
            //startActivity(intent);
            return true;
            return true;*/
        case R.id.menu_scan:
            // Launch the DeviceListActivity to see devices and do scan
            intent = new Intent(this, DeviceListActivity.class);
            startActivityForResult(intent, REQUEST_CONNECT_DEVICE);
            return true;
        case R.id.menu_discoverable:
            // Ensure this device is discoverable by others
            ensureDiscoverable();
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
            String buttonLabel = "";
            switch(view.getId()){
            /*case R.id.buttonMode:
                mStateCtrlMode++;
                if(mStateCtrlMode >= 3){
                    mStateCtrlMode = 0;
                }
                buttonLabel = getString(R.string.label_button_mode) + ((mStateCtrlMode == 0 ? " [マニュアル]": mStateCtrlMode == 1 ? " [デモ]" : " [加速度]"));
                break;*/
            case R.id.buttonPWM:
                mStateCtrlPwm = !mStateCtrlPwm;
                buttonLabel = getString(R.string.label_button_pwm) + (mStateCtrlPwm ? " [動作中]" : " [停止中]");
                break;
            case R.id.buttonPower:
                mStateCtrlPower = !mStateCtrlPower;
                buttonLabel = getString(R.string.label_button_power) + (mStateCtrlPower ? " [ON]" : " [OFF]");
                break;
            default:
                return;
            }
            //((Button)view).setText("");
            ((Button)view).setText(buttonLabel);
            //sendMessage("点灯/消灯ボタンが押された\r\n");
            byte[] command = new byte[]{0x0, 0x0};
            command[0] |= (byte) getResources().getInteger(R.integer.default_ctrl_address);
            //command[1] |= (mStateCtrlMode == 0 ? 0: mStateCtrlMode == 1 ? 1 : 2) << 2; // 0: manual, 1: demo, 2: g
            command[1] |= (mStateCtrlPwm ? 1 : 0) << 1;
            command[1] |= (mStateCtrlPower ? 1 : 0) << 0;
            sendCommand(command);
        }
    };

    /** RGB挙動変更ボタンを押したとき */
    private View.OnClickListener mOnBehaviorButtonClick = new View.OnClickListener() {
        @Override
        public void onClick(View view) {
            int stateCtrlMode = 0;
            byte address = 0x00;
            SeekBar seekBar = null;
            switch(view.getId()){
            case R.id.buttonRed:
                mStateCtrlModeRed++;
                if(mStateCtrlModeRed >= mBehaviorButtonLavels.length){
                    mStateCtrlModeRed = 0;
                }
                stateCtrlMode = mStateCtrlModeRed;
                seekBar = mRedSeekBar;
                address = (byte) getResources().getInteger(R.integer.default_red_mode_address);
                break;
            case R.id.buttonGreen:
                mStateCtrlModeGreen++;
                if(mStateCtrlModeGreen >= mBehaviorButtonLavels.length){
                    mStateCtrlModeGreen = 0;
                }
                stateCtrlMode = mStateCtrlModeGreen;
                seekBar = mGreenSeekBar;
                address = (byte) getResources().getInteger(R.integer.default_green_mode_address);
                break;
            case R.id.buttonBlue:
                mStateCtrlModeBlue++;
                if(mStateCtrlModeBlue >= mBehaviorButtonLavels.length){
                    mStateCtrlModeBlue = 0;
                }
                stateCtrlMode = mStateCtrlModeBlue;
                seekBar = mBlueSeekBar;
                address = (byte) getResources().getInteger(R.integer.default_blue_mode_address);
                break;
            default:
                return;
            }
            String buttonLabel = mBehaviorButtonLavels[stateCtrlMode];
            ((Button)view).setText(buttonLabel);

            /* TODO seekBarの有効/無効化 */

            byte[] command = new byte[]{0x0, 0x0};
            command = new byte[]{0x0, 0x0};
            command[0] |= address;
            command[1] |= (byte) stateCtrlMode;
            sendCommand(command);
        }
    };

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
            byte address;
            switch(seekBar.getId()){
            case R.id.seekBarRed:
                address = (byte) getResources().getInteger(R.integer.default_red_value_address);
                break;
            case R.id.seekBarGreen:
                address = (byte) getResources().getInteger(R.integer.default_green_value_address);
                break;
            case R.id.seekBarBlue:
                address = (byte) getResources().getInteger(R.integer.default_blue_value_address);
                break;
            default:
                return;
            }
            byte[] command = new byte[]{0x0, 0x0};
            command[0] |= address;
            command[1] |= (byte) progress;
            sendCommand(command);
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
            byte[] command = new byte[]{0x0, 0x0};
            command[0] |= (byte) getResources().getInteger(R.integer.default_gamma_address);
            command[1] |= (byte) progress;
            sendCommand(command);
        }
    };

    private void sendCommand(byte[] command){
        if(mChatService == null){
            return;
        }

        if(mCommandMarshaller.confirmSendable() == false){
            return;
        }

        // Check that we're actually connected before trying anything
        if (mChatService.getState() != BluetoothChatService.STATE_CONNECTED) {
            Toast.makeText(this, R.string.not_connected, Toast.LENGTH_SHORT).show();
            return;
        }

        // Check that there's actually something to send
        if (command.length > 1) {
            //for(int i = 0; command.length > i; ++i){
            //    command[i] |= 0x30;
            //}
            // Get the message bytes and tell the BluetoothChatService to write
            mChatService.write(command);
            mCommandMarshaller.registerSent(command);
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
                mChatService = new BluetoothChatService(this, mHandler);
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
        byte[] command = new byte[]{0x0, 0x0};
        command[0] |= (byte) getResources().getInteger(R.integer.default_ctrl_address);
        //command[1] |= (mStateCtrlMode == 0 ? 0x00: mStateCtrlMode == 1 ? 0x01 : 0x02) << 2; // 0: manual, 1: demo, 2: g
        command[1] |= (mStateCtrlPwm ? 0x01 : 0x00) << 1;
        command[1] |= (mStateCtrlPower ? 0x01 : 0x00) << 0;
        sendCommand(command);

        command = new byte[]{0x0, 0x0};
        command[0] |= (byte) getResources().getInteger(R.integer.default_red_mode_address);
        command[1] |= (byte) (mStateCtrlModeRed == 0 ? 0x00: mStateCtrlModeRed == 1 ? 0x01 : 0x02);
        sendCommand(command);

        command = new byte[]{0x0, 0x0};
        command[0] |= (byte) getResources().getInteger(R.integer.default_green_mode_address);
        command[1] |= (byte) (mStateCtrlModeGreen == 0 ? 0x00: mStateCtrlModeGreen == 1 ? 0x01 : 0x02);
        sendCommand(command);

        command = new byte[]{0x0, 0x0};
        command[0] |= (byte) getResources().getInteger(R.integer.default_blue_mode_address);
        command[1] |= (byte) (mStateCtrlModeBlue == 0 ? 0x00: mStateCtrlModeBlue == 1 ? 0x01 : 0x02);
        sendCommand(command);

        command = new byte[]{0x0, 0x0};
        command[0] |= (byte) getResources().getInteger(R.integer.default_red_value_address);
        command[1] |= (byte) mRedSeekBar.getProgress();
        sendCommand(command);

        command = new byte[]{0x0, 0x0};
        command[0] |= (byte) getResources().getInteger(R.integer.default_green_value_address);
        command[1] |= (byte) mGreenSeekBar.getProgress();
        sendCommand(command);

        command = new byte[]{0x0, 0x0};
        command[0] |= (byte) getResources().getInteger(R.integer.default_blue_value_address);
        command[1] |= (byte) mBlueSeekBar.getProgress();
        sendCommand(command);

        command = new byte[]{0x0, 0x0};
        command[0] |= (byte) getResources().getInteger(R.integer.default_gamma_address);
        command[1] |= (byte) mGammaSeekBar.getProgress();
        sendCommand(command);
    }
}