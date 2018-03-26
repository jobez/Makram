;; -*- mode: Lisp; eval: (cm-mode 1); -*-
(use-package :cm-ifs)

(load "helpers.lisp")


(with-interface (faust)
  (interface-only
   ;; (include <faust/dsp/timed-dsp.h>)
   (include <faust/dsp/llvm-dsp.h>)
   ;; (include <faust/dsp/poly-dsp.h>)
   ;; (include <faust/dsp/dsp-combiner.h>)

   (include "audio.h")
   ;(include "clui.h")
   )

  (implementation-only


   (include <faust/gui/JSONUI.h>)
   (include <faust/gui/APIUI.h>)
   (include <faust/gui/FUI.h>)

   (include <faust/gui/OSCUI.h>)
   (include <faust/gui/httpdUI.h>)

   (include <faust/gui/MidiUI.h>)
   (include <faust/midi/rt-midi.h>)
   (include <faust/midi/RtMidi.cpp>))

  (namespace
   'faust
   (implementation-only
    (decl ((APIUI fAPIUI)))


    (extern "C"
            (function str-to-dsp
                ((char *cdsp-name)
                 (char *cdsp-str))
                -> dsp*
              (decl ((#:std::string (dsp-str cdsp-str))
                     (#:std::string (dsp-name cdsp-name))
                     (#:std::string error-msg)
                     (llvm_dsp_factory* dsp-fact =
                                        (createDSPFactoryFromString
                                         dsp-name
                                         dsp-str
                                         0
                                         0
                                         ""
                                         error-msg)))

                (cerr error-msg)
                (cprint dsp-str)
                (return
                  (dsp-fact->createDSPInstance))))

            (function init-jack ((char *caudio-name)
                                 (dsp* dsp))
                -> MakramAudio*
              (decl ((MakramAudio* audio = (new MakramAudio)))
                (audio->init
                 caudio-name
                 dsp)

                (return audio)))

            (function connect-audio-src ((MakramAudio* audio))
                -> void
              (audio->connectPorts))

            (function init-apiui ((dsp* dsp))
                -> APIUI*
              (decl ((APIUI* apiui = (new APIUI)))
                (dsp->buildUserInterface apiui)
                (return apiui)))


            (function connect-dsp ((MakramAudio* audio)
                                   (dsp* dsp))
                -> void
              (audio->setDsp dsp))

            (function update-dsp ((MakramAudio* audio)
                                  (dsp* dsp))
                -> void
              (audio->updateDsp dsp))

            (function play ((MakramAudio* audio))
                -> void
              ;; (audio.addMidiIn dsp_poly)
              (audio->start))

            (function stop ((MakramAudio* audio))
                -> void
              (audio->stop))

            (function kill-dsp ((dsp* dsp))
                -> void
              (delete dsp))

            (function kill-audio ((MakramAudio* audio))
                -> void
              (delete audio))

            (function kill-apiui ((APIUI* fAPIUI))
                -> void
              (delete fAPIUI))

            (function dsp-to-json ((dsp* dsp))
                -> (const char*)
              (decl ((JSONUI (json
                              (dsp->getNumInputs)

                              (dsp->getNumOutputs)))))
              (dsp->buildUserInterface &json)
              (decl ((#:std::string jsn = (json.JSON))))
              (return (jsn.c_str)))

            (function set-param ((APIUI* fAPIUI)
                                 (const char* address)
                                 (float value))
                -> void
              (fAPIUI->setParamValue (fAPIUI->getParamIndex address)
                                     value))

            (function get-param ((APIUI* fAPIUI)
                                 (const char* address))
                -> float
              (return (fAPIUI->getParamValue
                       (fAPIUI->getParamIndex address))))




            ;; (function build-interfaces ((dsp* dsp))
            ;;     -> void

            ;;   (set oscinterface
            ;;        (new (OSCUI "georg"
            ;;                    0
            ;;                    0)))

            ;;   (set httpdinterface
            ;;        (new (httpdUI
            ;;              "georg"
            ;;              (dsp->getNumInputs)
            ;;              (dsp->getNumOutputs)
            ;;              0
            ;;              0)))

            ;;   (set midiinterface (new (MidiUI &audio)))

            ;;   (dsp->buildUserInterface midiinterface)


            ;;   (dsp->buildUserInterface oscinterface)

            ;;   (<< #:std::cout "osc-interface is on" #:std::endl)

            ;;   (dsp->buildUserInterface httpdinterface)

            ;;   (midiinterface->run)

            ;;   (httpdinterface->run)

            ;;   (oscinterface->run))

            ;; (function kill-interfaces ()
            ;;     -> void
            ;;   (httpdinterface->stop)
            ;;   (oscinterface->stop)
            ;;   (midiinterface->stop)
            ;;   ;; (delete midiinterface)
            ;;   (delete httpdinterface)
            ;;   (delete oscinterface))

            ))))
