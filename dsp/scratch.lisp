(progn
 (remfaust life)
 (faust-dsp! life
             (faust-syntax!
               (decl author "me")
               (f/import "stdfaust.lib")
               (f/def key 60)
               (f/def ncy 15)
               (f/def ccy 15)
               (f/def bps 360)
               (f/defun process ()
                        ((sh (acc ba "sAndH"))
                         (l (-> (hslider "master"
                                         -20 -60
                                         0 0.01)
                              (acc ba db2linear)))
                         (c (-> (hslider "timbre"
                                         0 0
                                         1 0.01))))
                        (mrg
                         (harpe c 12 38)
                         (<->
                          (* l)
                          (* l))))

               (f/defun harpe (c n b)
                        ((att 12)
                         (automat (acc ba automat))
                         (bb (-> (hslider "key"
                                          38
                                          20 50
                                          1)
                               int))
                         (hand (-> (vgroup "loop%b"
                                           (f/funcall hslider "[1]note"
                                                      4 0
                                                      n 1))
                                 int
                                 (f/funcall automat
                                            360 3 0.0)))
                         (lvl 1.0)
                         (pan (p) ()
                              (splt _
                                    (<-> (*
                                          (sqrt
                                           (- 1 p)))
                                         (*
                                          (sqrt
                                           p)))))
                         (position (a x) ()
                                   (-> (<
                                        (abs
                                         (- x a))
                                        0.5)))
                         (db2linear (x) ()
                                    (-> (pow 10
                                             (/ x 20.0)))))
                        (mrg (splt hand
                                   (par
                                    i n
                                    (->
                                        (position
                                         (+ i 1))
                                      (string c
                                              (acc (f/funcall penta bb)
                                                   (f/funcall degree2hz i))
                                              att lvl)
                                      (pan
                                       (/
                                        (+ i 0.5)
                                        n)))))

                             (<-> _ _)))

               (f/defun penta (key) ()
                        (env (a4hz 440)
                             (degree2midi (0) ()
                                          (-> (+ key 0)))
                             (degree2midi (1) ()
                                          (-> (+ key 2)))
                             (degree2midi (2) ()
                                          (-> (+ key 4)))
                             (degree2midi (3) ()
                                          (-> (+ key 7)))
                             (degree2midi (4) ()
                                          (-> (+ key 9)))
                             (degree2midi (d) ()
                                          (->
                                              (degree2midi
                                               (- d 5))
                                            (+

                                             12)))
                             (degree2hz (d) ((semiton (n) ()
                                                      (-> 2.0 (^ _ (/ n 12.0)))))
                                        (-> a4hz
                                          (*
                                           (semiton
                                            (-
                                             (degree2midi
                                              d)
                                             69)))))))

               (f/defun string (coef freq t60 level trig)
                        ((resonator (d a) ()
                                    (~ (-> + (@ (- d 1)))
                                       (-> average (* _ a))
                                       ))
                         (average (x) ()
                                  (-> (/
                                       ( +
                                         (* x
                                            (+ 1 coef))
                                         (*
                                          (delay-1 x)
                                          (- 1 coef)))
                                       2)))
                         (trigger (n) ()
                                  (-> upfront
                                    (~ +
                                       (decay n))
                                    (> 0.0)))
                         (upfront (x) ()
                                  (->
                                      (- x (delay-1 x))
                                    (>

                                     0.0)))
                         (decay (n x) ()
                                (-> x
                                  (- _
                                     (/
                                      (> x 0.0)
                                      n))))
                         (freq2samples (f) ()
                                       (-> f (/ 48000.0 _)))
                         (att () ()
                              (-> (pow 0.01
                                       (/ 1.0 (* freq t60)))))
                         (noise (acc no noise)))
                        (->
                            (* noise level)
                          (* (-> trig (trigger (freq2samples freq))))
                          (resonator (freq2samples freq)
                                     att))))))



(faust-dsp! life
            (faust-syntax!
              (decl author "me")
              (f/import "stdfaust.lib")
              (f/def key 60)
              (f/def ncy 15)
              (f/def ccy 15)
              (f/def bps 360)
              (f/defun process ()
                       ((sh (acc ba "sAndH"))
                        (l (-> (hslider "master"
                                        -20 -60
                                        0 0.01)
                             (acc ba db2linear)))
                        (c (-> (hslider "timbre"
                                        0 0
                                        1 0.01))))
                       (mrg
                        (harpe c 11 38)
                        (<->
                         (* l)
                         (* l))))

              (f/defun harpe (c n b)
                       ((att 3)
                        (sh (acc ba "sAndH"))
                        (automat (acc ba automat))
                        (bb (-> (hslider "key"
                                         38
                                         20 50
                                         1)
                              int))
                        (hand (-> (vgroup "loop%b"
                                          (f/funcall hslider "[1]note"
                                                     4 0
                                                     n 1))
                                int
                                (f/funcall automat
                                           (* 2 360) 16 0.0)))
                        (lvl 1.0)
                        (pan (p) ()
                             (splt _
                                   (<-> (*
                                         (sqrt
                                          (- 1 p)))
                                        (*
                                         (sqrt
                                          p)))))
                        (position (a x) ()
                                  (-> (<
                                       (abs
                                        (- x a))
                                       0.5)))
                        (db2linear (x) ()
                                   (-> (pow 10
                                            (/ x 20.0)))))
                       (mrg (splt hand
                                  (par
                                   i n
                                   (->
                                       (position
                                        (+ i 1))
                                     (string c
                                             (acc (f/funcall penta bb)
                                                  (f/funcall degree2hz i))
                                             att lvl)
                                     (pan
                                      (/
                                       (+ i 0.5)
                                       n)))))

                            (<-> _ _)))

              (f/defun penta (key) ()
                       (env (a4hz 440)
                            (degree2midi (0) ()
                                         (-> (+ key 0)))
                            (degree2midi (1) ()
                                         (-> (+ key 2)))
                            (degree2midi (2) ()
                                         (-> (+ key 4)))
                            (degree2midi (3) ()
                                         (-> (+ key 7)))
                            (degree2midi (4) ()
                                         (-> (+ key 9)))
                            (degree2midi (d) ()
                                         (->
                                             (degree2midi
                                              (- d 5))
                                           (+

                                            12)))
                            (degree2hz (d) ((semiton (n) ()
                                                     (-> 2.0 (^ _ (/ n 12.0)))))
                                       (-> a4hz
                                         (*
                                          (semiton
                                           (-
                                            (degree2midi
                                             d)
                                            69)))))))

              (f/defun string (coef freq t60 level trig)
                       ((resonator (d a) ()
                                   (~ (-> + (@ (- d 6)))
                                      (-> average (* _ a))
                                      ))
                        (average (x) ()
                                 (-> (/
                                      ( +
                                        (* x
                                           (+ 1 coef))
                                        (*
                                         (delay-1 x)
                                         (- 1 coef)))
                                      2)))
                        (trigger (n) ()
                                 (-> upfront
                                   (~ +
                                      (decay n))
                                   (> 0.0)))
                        (upfront (x) ()
                                 (->
                                     (- x (delay-1 x))
                                   (>

                                    0.0)))
                        (decay (n x) ()
                               (-> x
                                 (- _
                                    (/
                                     (> x 0.0)
                                     n))))
                        (freq2samples (f) ()
                                      (-> f (/ 48000.0 _)))
                        (att () ()
                             (-> (pow 0.01
                                      (/ 1.0 (* freq t60)))))
                        (noise (acc no noise)))
                       (->
                           (* noise level)
                         (* (-> trig (trigger (freq2samples freq))))
                         (resonator (freq2samples freq)
                                    att)))))

(faust-dsp! life
            (faust-syntax!
              (decl author "johann")
              (f/import "stdfaust.lib")

              (f/def bb (-> (hslider "key"
                                     52
                                     20 50
                                     1)
                          int))
              (f/defun penta (key) ()
                       (env (a4hz 440)
                            (degree2midi (0) ()
                                         (-> (+ key 0)))
                            (degree2midi (1) ()
                                         (-> (+ key 2)))
                            (degree2midi (2) ()
                                         (-> (+ key 4)))
                            (degree2midi (3) ()
                                         (-> (+ key 7)))
                            (degree2midi (4) ()
                                         (-> (+ key 9)))
                            (degree2midi (d) ()
                                         (->
                                             (degree2midi
                                              (- d 5))
                                           (+

                                            12)))
                            (degree2hz (d) ((semiton (n) ()
                                                     (-> 2.0
                                                       (^ _ (/ n 12.0)))))
                                       (-> a4hz
                                         (*
                                          (semiton
                                           (-
                                            (degree2midi
                                             d)
                                            69)))))))
              (f/defun process ()
                       ((automat (acc ba automat))
                        (smoo (acc si smoo))
                        (osc (acc os osc))
                        (saw (acc os sawtooth))
                        (asdr (acc en adsr))
                        (panner (acc sp panner))
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
                                   smoo))
                        (hand (-> (hslider "[1]note"
                                           11 0
                                           11 1)
                                int
                                (automat
                                 (* 2 360) 32 0.0)))
                        (freq (i) () (-> (acc (f/funcall penta bb)
                                              (f/funcall degree2hz i))))
                        (gain (hslider "gain"
                                       0.8 0
                                       10 0.01))
                        (position (a x) ()
                                  (-> (<
                                       (abs
                                        (- x a))
                                       0.5))))
                       (mrg
                        (splt hand
                              (par i 24
                                   (-> (position (+ i 1))
                                     (*
                                      (* (-
                                          (saw (freq (+ i 0)))
                                          (* (saw (freq (+ i 2)))
                                             (osc (freq (+ i 0)))))
                                         (-> _
                                           (asdr attack decay sustain release)))

                                      (* vol gain) )
                                     )))
                        (<-> (* (-> pan sqrt))
                             (* (-> (- 1 pan) sqrt)))))))
