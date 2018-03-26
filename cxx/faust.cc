//IMPLEMENTATION GENERATED WITH CM-IFS
#include "faust.h"
#include <faust/gui/JSONUI.h>
#include <faust/gui/APIUI.h>
#include <faust/gui/FUI.h>
#include <faust/gui/OSCUI.h>
#include <faust/gui/httpdUI.h>
#include <faust/gui/MidiUI.h>
#include <faust/midi/rt-midi.h>
#include <faust/midi/RtMidi.cpp>
namespace faust
{
	APIUI fAPIUI;
	extern "C"
	{

		dsp* str_to_dsp(char *cdsp_name, char *cdsp_str)
		{
			std::string dsp_str(cdsp_str);
			std::string dsp_name(cdsp_name);
			std::string error_msg;
			llvm_dsp_factory* dsp_fact = createDSPFactoryFromString(dsp_name, dsp_str, 0, 0, "", error_msg);
			std::cerr << error_msg << std::endl;
			std::cout << dsp_str << std::endl;
			return dsp_fact->createDSPInstance();
		}

		MakramAudio* init_jack(char *caudio_name, dsp* dsp)
		{
			MakramAudio* audio = new MakramAudio;
			audio->init(caudio_name, dsp);
			return audio;
		}

		void connect_audio_src(MakramAudio* audio)
		{
			audio->connectPorts();
		}

		APIUI* init_apiui(dsp* dsp)
		{
			APIUI* apiui = new APIUI;
			dsp->buildUserInterface(apiui);
			return apiui;
		}

		void connect_dsp(MakramAudio* audio, dsp* dsp)
		{
			audio->setDsp(dsp);
		}

		void update_dsp(MakramAudio* audio, dsp* dsp)
		{
			audio->updateDsp(dsp);
		}

		void play(MakramAudio* audio)
		{
			audio->start();
		}

		void stop(MakramAudio* audio)
		{
			audio->stop();
		}

		void kill_dsp(dsp* dsp)
		{
			delete dsp;
		}

		void kill_audio(MakramAudio* audio)
		{
			delete audio;
		}

		void kill_apiui(APIUI* fAPIUI)
		{
			delete fAPIUI;
		}

		const char* dsp_to_json(dsp* dsp)
		{
			JSONUI json(dsp->getNumInputs(), dsp->getNumOutputs());
			dsp->buildUserInterface(&json);
			std::string jsn = json.JSON();
			return jsn.c_str();
		}

		void set_param(APIUI* fAPIUI, const char* address, float value)
		{
			fAPIUI->setParamValue(fAPIUI->getParamIndex(address), value);
		}

		float get_param(APIUI* fAPIUI, const char* address)
		{
			return fAPIUI->getParamValue(fAPIUI->getParamIndex(address));
		}
	}
}