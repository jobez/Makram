#ifndef __CLUI_H__
#define __CLUI_H__
//INTERFACE GENERATED WITH CM-IFS
#include <map>
#include <vector>
#include <string>
#include <faust/gui/UI.h>
#include <faust/gui/meta.h>
#include <faust/dsp/dsp.h>

class CLUI
 : public UI
{
	std::vector<std::string> boxes;
	bool atRoot = true;
	std::map<std::string, FAUSTFLOAT*> option_map;
public:
	enum OPTTYPE {  FLOAT,  BOOL };

	void openTabBox(const char* label) override 
	{
		if (atRoot)
			atRoot = false;
		else
			boxes.push_back(label);
	}

	void openHorizontalBox(const char* label) override 
	{
		if (atRoot)
			atRoot = false;
		else
			boxes.push_back(label);
	}

	void openVerticalBox(const char* label) override 
	{
		if (atRoot)
			atRoot = false;
		else
			boxes.push_back(label);
	}

	virtual void closeBox();

	virtual void addSoundfile(const char* label, const char* filename, Soundfile** sf_zone);

	void addVerticalSlider(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step) override 
	{
		option_map[label] = zone;
	}

	void addHorizontalSlider(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step) override 
	{
		option_map[label] = zone;
	}

	void addNumEntry(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step) override 
	{
		option_map[label] = zone;
	}

	void addButton(const char* label, FAUSTFLOAT* zone) override 
	{
		option_map[label] = zone;
	}

	void addCheckButton(const char* label, FAUSTFLOAT* zone) override 
	{
		option_map[label] = zone;
	}

	void addHorizontalBargraph(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT min, FAUSTFLOAT max) override 
	{
		option_map[label] = zone;
	}

	void addVerticalBargraph(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT min, FAUSTFLOAT max) override 
	{
		option_map[label] = zone;
	}
};
#endif // __CLUI_H__
