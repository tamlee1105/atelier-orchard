#pragma once

#include <yctypes.h>
class YCMutex;

/**
* キャプチャデータ送信用クラスです。
*/
class VideoConnector
{
public:

	/**
	* 構築します。
	*/
	VideoConnector(const wchar_t* memName, const wchar_t* writeEventName, const wchar_t* readEventName);

	/**
	* 破棄します。
	*/
	virtual ~VideoConnector(void);

	float time;

	int width;

	int height;

	CaptureSender sender;

	unsigned char* imageBuf;

};
