package videoconnector;

public class VideoConnecotorJni {
	static{
		System.loadLibrary( "videoconnector" );
	}

	public native void nativeInitialize(int width, int height);

	public native void nativeAddFrame( float frame_rate, int[] pixels );

	public native void nativeFinalize();

}
