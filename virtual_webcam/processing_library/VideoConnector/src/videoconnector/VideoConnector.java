package videoconnector;

import processing.core.*;

public class VideoConnector {

    PApplet           parent;
    VideoConnecotorJni jni;

    public VideoConnector(PApplet parent) {
        this.parent = parent;
        this.jni    = new VideoConnecotorJni();
        parent.registerPost(this);
    }

    public void post() {
    	jni.nativeAddFrame(parent.pixels);
    }
}
