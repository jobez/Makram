#ifndef __AUDIO_H__
#define __AUDIO_H__
//INTERFACE GENERATED WITH CM-IFS
#include <faust/audio/jack-dsp.h>

class MakramAudio
 : public jackaudio_midi
{
public:

	void updateDsp(dsp* new_dsp);

	void connectPorts();
};
#endif // __AUDIO_H__
