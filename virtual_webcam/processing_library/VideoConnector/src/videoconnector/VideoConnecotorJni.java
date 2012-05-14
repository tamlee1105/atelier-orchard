package videoconnector;

public class VideoConnecotorJni {
	static{
		System.loadLibrary( "ycapture" );
	}

	public native void nativeAddFrame( int[] pixels );

}
