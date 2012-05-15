package videoconnector;

import processing.core.*;

public class VideoConnector {

    PApplet           parent;
    VideoConnecotorJni jni;

    public VideoConnector(PApplet parent) {
        this.parent = parent;
        this.jni    = new VideoConnecotorJni();
        jni.nativeInitialize(parent.width, parent.height);
        parent.registerPost(this);
    }

    public void post() {
    	jni.nativeAddFrame( parent.frameRate, parent.pixels);
    }
}
