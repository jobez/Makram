(use-package :cm-ifs)

(load "helpers.lisp")

(with-interface (audio)
  (interface-only
   (include <faust/audio/jack-dsp.h>)
   (class MakramAudio
       ((public jackaudio_midi))
     (public
      (function updateDsp ((dsp* new-dsp))  -> void)
      (function connectPorts ()  -> void))))

  (implementation-only

   (function #:MakramAudio::connectPorts () -> void
     (decl ((auto incudine-ports = (jack-get-ports fClient "incudine" 0 JackPortIsInput)))
      (for ((int i = 0)
            (< i (fOutputPorts.size))
            (set i (+ i 1)))
        (cprint incudine-ports[i])
        (cprint (jack-port-name fOutputPorts[i]))
        (cprint (jack-connect fClient (jack_port_name fOutputPorts[i]) incudine-ports[i]))
        )))


   (function #:MakramAudio::updateDsp ((dsp* new-dsp)) -> void


     (for ((int i = 0)
           (< i (new-dsp->getNumInputs))
           (set i (+ i 1)))
       (decl ((char buf[256]))
         (snprintf buf 256 "in_%d" i)
         (jack_port_unregister fClient
                               fInputPorts[i])
         (set fInputPorts[i]
              (jack_port_register
               fClient
               buf
               JACK_DEFAULT_AUDIO_TYPE
               JackPortIsInput 0))))


     (for ((int i = 0)
           (< i (new-dsp->getNumOutputs))
           (set i (+ i 1)))
       (decl ((char buf[256]))
         (snprintf buf 256 "out_%d" i)
         (jack_port_unregister fClient
                               fOutputPorts[i])
         (set fOutputPorts[i]
              (jack_port_register
               fClient
               buf
               JACK_DEFAULT_AUDIO_TYPE
               JackPortIsOutput 0))))
     (decl ((dsp* oldDSP = fDSP))
           (new-dsp->init (jack_get_sample_rate fClient))
           (set fDSP new-dsp)
           (delete oldDSP)))))
