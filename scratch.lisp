(in-package :makram)

(faust-dsp! :instr0
            (faust-syntax!
              (decl author "me")
              (f/import "stdfaust.lib")
              (f/defun process ()
                       ((gate (button "gate"))
                        (freq (hslider "freq[unit:Hz]" 440 20 1000 1))
                        (smoo (acc si smoo))
                        (osc (acc os osc))
                        (saw (acc os sawtooth))
                        (asdre (acc en adsre))
                        (panner (acc sp panner))
                        (gain (hslider "gain"
                                       0.8 0
                                       10 0.01))
                        (vol (hslider "vol"
                                      0.3 0
                                      10 0.01))
                        (pan (hslider "pan"
                                      0.5 0
                                      1 0.01))
                        (attack (-> (hslider "attack"
                                             0.01 0
                                             1 0.001)
                                  smoo))
                        (decay (-> (hslider "decay"
                                            0.3 0
                                            1 0.001)
                                 smoo))
                        (sustain (-> (hslider "sustain"
                                              0.5 0
                                              1 0.01)
                                   smoo))
                        (release (-> (hslider "release"
                                              0.99 0
                                              1 0.001)
                                   smoo)))
                       (->
                           (*
                            (+
                             (osc freq)
                             (* (osc freq)
                                  (saw freq)))
                            (asdre attack decay sustain release gate))
                         (* (* vol gain) _) ))))

(faust-dsp! :instr1
            (faust-syntax!
              (decl author "me")
              (f/import "stdfaust.lib")
              (f/defun process ()
                       ((gate (button "gate"))
                        (freq (hslider "freq[unit:Hz]" 440 20 1000 1))
                        (smoo (acc si smoo))
                        (osc (acc os osc))
                        (saw (acc os sawtooth))
                        (asdre (acc en adsre))
                        (panner (acc sp panner))
                        (gain (hslider "gain"
                                       0.8 0
                                       10 0.01))
                        (vol (hslider "vol"
                                      0.3 0
                                      10 0.01))
                        (pan (hslider "pan"
                                      0.5 0
                                      1 0.01))
                        (attack (-> (hslider "attack"
                                             0.01 0
                                             1 0.001)
                                  smoo))
                        (decay (-> (hslider "decay"
                                            0.3 0
                                            1 0.001)
                                 smoo))
                        (sustain (-> (hslider "sustain"
                                              0.5 0
                                              1 0.01)
                                   smoo))
                        (release (-> (hslider "release"
                                              0.99 0
                                              1 0.001)
                                   smoo)))
                       (->
                           (*
                            (+
                             (* (osc freq)
                                (saw freq))
                             (osc freq))
                            (asdre attack decay sustain release gate))

                        (* (* vol gain) _) )
                       )))

(progn
  (iter
    (with offset = 0)
    (for i :from 1 :to 8)
    (iter
      (for beat :in (euclidean-rhythm 5 8))
      (generating note :in '(:d2 :a2 :b2 :b2 :a2))
      (incf offset 0.6)

      (unless (zerop beat)
        (makram.scheduler:sched! offset :instr1 :freq (note->hz (next note)))
        (makram.scheduler:sched! offset :instr1 :gate 1.0))
      (makram.scheduler:sched! (+ offset  0.6) :instr1 :gate 0.0)))
  (iter
    (with offset = 0)
    (for i :from 1 :to 16)
    (iter
      (for beat :in (euclidean-rhythm 5 8))
      (generating note :in '(:d4 :a4 :b4 :a4 :b4))
      (incf offset 0.2)
      (log:info (* i offset) beat note offset)
      (unless (zerop beat)
        (makram.scheduler:sched! offset :instr0 :freq (note->hz (next note)))
        (makram.scheduler:sched! offset :instr0 :gate 1.0))
      (makram.scheduler:sched! (+ offset  0.2) :instr0 :gate 0.0))))


(remfaust life)
(pfaust life)
(sfaust life)
(?faust life)



(comment
  (-> (lookup-faust-dsp 'life)
    fau-audio-ptr
    connect-audio-src)

  (set-faust! instr0 :gate 0.0)
  (set-faust! life :timbre 0.75)
  (set-faust! life :vol 0.1)
  (set-faust! life :key 52.0)
  (set-faust! life :note 14.0)
  (set-faust! life :note 11.0)
  (set-faust! life :note 10.0)
  (set-faust! life :note 9.0)
  (set-faust! life :note 8.0)
  (set-faust! life :note 5.0)
  (set-faust! life :note 4.0)
  (set-faust! life :note 3.0)
  (set-faust! life :note 2.0)
  (set-faust! life :note 1.0)
  (set-faust! life :release 0.0)
  (set-faust! life :note 0.0)
  (set-faust! life :release 0.98)
  (set-faust! life :release 0.8)
  (set-faust! life :release 0.2)
  (set-faust! life :sustain 1.0)
  (set-faust! life :decay 0.1)
  (set-faust! life :attack 0.05)


  (set-faust! life "bowvel" 0.5)
  (set-faust! life "bowpos" 0.8)
  (set-faust! life "strlength" 0.75)
  (set-faust! life "bowvel" 0.8)
  (set-faust! life "outgain" 3.1)
  (progn
    (set-faust! life "gate" 1.0)
    (sleep 0.8)
    (set-faust! life "gate" 0.0))

  (set-faust! life "/violin/bow/position" 0.4)



  ;; (comment
  ;;   (def-suite faust-syntax :description "lisp->faust xform verification")
  ;;   (in-suite faust-syntax)
  ;;   (test series-parallel
  ;;     (is
  ;;      (string=
  ;;       (->> '(:series
  ;;              (:parallel x y) ^)
  ;;         expand-georg
  ;;         pre->in
  ;;         reduce-expr)
  ;;       "X,Y : ^")))
  ;;   (explain! (run 'faust-syntax)))
  )
