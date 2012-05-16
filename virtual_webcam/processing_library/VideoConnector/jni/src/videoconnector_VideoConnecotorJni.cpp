/** videoconnector_VideoConnecotorJni.cpp
 *
 *
 *
 */

#include "stdafx.h"
#include <CaptureSender.h>
#include <ycapture.h>
#include "videoconnector_VideoConnecotorJni.h"
#include <stdio.h>

struct videoconnector{
	float          time;
	int            width;
	int            height;
	CaptureSender  *sender;
	unsigned char  *imageBuf;
} *p_vc;

/*
 * Class:     videoconnector_VideoConnecotorJni
 * Method:    nativeInitialize
 * Signature: (II)V
 */
JNIEXPORT void JNICALL Java_videoconnector_VideoConnecotorJni_nativeInitialize
  (JNIEnv *env, jobject obj, jint w, jint h)
{
	p_vc = (struct videoconnector*) malloc(sizeof(struct videoconnector));
	if(p_vc == 0){
		printf("p_vc = 0x%08X\n", p_vc); // 標準出力でなくエラー出力にすること
		return;
	}

	p_vc->time   = 0.f;
	p_vc->width  = w;
	p_vc->height = h;
	p_vc->sender = new CaptureSender(CS_SHARED_PATH, CS_EVENT_WRITE, CS_EVENT_READ);
	p_vc->imageBuf = new unsigned char[w * h * 3];
}

/*
 * Class:     videoconnector_VideoConnecotorJni
 * Method:    nativeAddFrame
 * Signature: (F[I)V
 */
JNIEXPORT void JNICALL Java_videoconnector_VideoConnecotorJni_nativeAddFrame
  (JNIEnv *env, jobject obj, jfloat frame_rate, jintArray pixels)
{

	jint* p_argb = env->GetIntArrayElements(pixels, NULL);
	//nSize = env->GetArrayLength(pixels);

	unsigned char* p_rgb = p_vc->imageBuf;

	// RGB <- ARGB 転送
	for(int y = p_vc->height; y > 0; --y) {
		int r = y * p_vc->width;
		for(int x = (y - 1) * p_vc->width; x < r; ++x){
			*(p_rgb++) = (unsigned char) ((p_argb[x] & 0x00FF0000) >> 16);
			*(p_rgb++) = (unsigned char) ((p_argb[x] & 0x0000FF00) >> 8);
			*(p_rgb++) = (unsigned char)  (p_argb[x] & 0x000000FF);
			//if(p_argb[i]) printf("p_argb[%d] = 0x%08X\n", i, p_argb[i]);
		}
	}

	// 前フレームからの経過ミリ秒を加算
	p_vc->time += 1000.f / frame_rate;

	// 送信する
	HRESULT hr = p_vc->sender->Send((LONGLONG)p_vc->time, 
		p_vc->width, 
		p_vc->height, 
		p_vc->imageBuf);
	if(FAILED(hr)) {
		// エラー: 続行しない
		fprintf(stderr, "Error: 0x%08x\n", hr);
		return;
	}else if(hr == S_OK) {
		// 送信成功
		//printf("Sent: %d\n", i);
	}else{
		// フィルタ未起動。無視
		//fprintf(stderr, "Ignored: %d\n", i);
	}

	env->ReleaseIntArrayElements(pixels, p_argb, 0);
}

/*
 * Class:     videoconnector_VideoConnecotorJni
 * Method:    nativeFinalize
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_videoconnector_VideoConnecotorJni_nativeFinalize
  (JNIEnv *env, jobject obj)
{
	delete[] p_vc->imageBuf;
	free(p_vc);
}
