// testclient.cpp : �R���\�[�� �A�v���P�[�V�����̃G���g�� �|�C���g���`���܂��B
//

#include "stdafx.h"
#include <CaptureSender.h>
#include <ycapture.h>

/*
 * Class:     videoconnector_VideoConnecotorJni
 * Method:    nativeInitialize
 * Signature: (II)V
 */
JNIEXPORT void JNICALL Java_videoconnector_VideoConnecotorJni_nativeInitialize
  (JNIEnv *env, jobject obj, jint w, jint h)
{
	time   = 0.f;
	width  = w;
	height = h;

	sender = new CaptureSender::CaptureSender(CS_SHARED_PATH, CS_EVENT_WRITE, CS_EVENT_READ);
	imageBuf = new unsigned char[width * height * 3];
}

/*
 * Class:     videoconnector_VideoConnecotorJni
 * Method:    nativeAddFrame
 * Signature: (F[I)V
 */
JNIEXPORT void JNICALL Java_videoconnector_VideoConnecotorJni_nativeAddFrame
  (JNIEnv *env, jobject obj, jfloat frame_rate, jintArray pixels)
{
	jboolean ret;
	int i, nSize;

	jint* p_argb = (*env)->GetIntArrayElements(env, pixels, &ret);
	nSize = (*env)->GetArrayLength(env, pixels);

	// RGB <- ARGB �]��
	for(i=0; i < nSize; ++i) {
		*(imageBuf++) = (p_argb[i] | 0x000000FF);
		*(imageBuf++) = (p_argb[i] | 0x0000FF00) >> 8;
		*(imageBuf++) = (p_argb[i] | 0x00FF0000) >> 16;
	}

	// �O�t���[������̌o�߃~���b�����Z
	time += 1000.f / frame_rate;

	// ���M����
	HRESULT hr = sender.Send(time, width, height, imageBuf);
	if(FAILED(hr)) {
		// �G���[: ���s���Ȃ�
		fprintf(stderr, "Error: 0x%08x\n", hr);
		break;
	}else if(hr == S_OK) {
		// ���M����
		printf("Sent: %d\n", i);
	}else{
		// �t�B���^���N���B����
		printf("Ignored: %d\n", i);
	}

	(*env)->ReleaseIntArrayElements(env, pixels, p_argb, 0);
}

/*
 * Class:     videoconnector_VideoConnecotorJni
 * Method:    nativeFinalize
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_videoconnector_VideoConnecotorJni_nativeFinalize
  (JNIEnv *env, jobject obj)
{
	delete[] imageBuf;
	imageBuf = NULL;
}
