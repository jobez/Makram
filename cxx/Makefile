all: faustbind.so

CXX = g++
LIBS = -lOSCFaust -lfaust -ljack
CFLAGS = -shared $(shell pkg-config --cflags --libs rtmidi) $(shell llvm-config --ldflags --libs all) -fpermissive
FILES =

%.h: %.cc.lisp
	@echo "$< $@"
	@cm-cxx -E "(require :cm-ifs)" -E '(setf cm-ifs:*gen-interface* t)' $< -o $@

%.cc: %.cc.lisp
	@echo "CM $<"
	@cm-cxx -E "(require :cm-ifs)" -E '(setf cm-ifs:*gen-interface* nil)'  $< -o $@

faustbind.so: clui.h clui.cc faust.h faust.cc audio.h audio.cc
	$(CXX) $^ $(CFLAGS) $(LIBS) $(FILES) -o $@

clean:
	rm -f *.cc *.h *.so
