#pragma once

#include <yctypes.h>
class YCMutex;

/**
* �L���v�`���f�[�^���M�p�N���X�ł��B
*/
class VideoConnector
{
public:

	/**
	* �\�z���܂��B
	*/
	VideoConnector(const wchar_t* memName, const wchar_t* writeEventName, const wchar_t* readEventName);

	/**
	* �j�����܂��B
	*/
	virtual ~VideoConnector(void);

	float time;

	int width;

	int height;

	CaptureSender sender;

	unsigned char* imageBuf;

};
