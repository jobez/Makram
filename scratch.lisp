(in-package :makram)

(defun seq-split-remainder (seq)
  (bind ((last (-> seq last first)))
    (->> seq
      (serapeum:partition (lambda (el)
                            (equal last el))))))

(defun nil-pad (list on-list)
  (append list
          (make-list (max 0
                          (-
                           (length on-list)
                           (length list))))))

(defun interleave (l0 l1)
  (iter (for rem :in (nil-pad l0 l1))
        (for re :in (nil-pad l1 l0))
        (collect (append re rem))))

(defun bjorklund (list)
  (bind (((:values remainders reals)
          (->> list seq-split-remainder)))
    (if (<= (length remainders) 1)
        (alexandria:flatten (append reals remainders))
        (bjorklund (interleave remainders reals)))))

(defun euclidean-rhythm (k n)
  (bjorklund (append
              (make-list k
                         :initial-element
                         '(1))
              (make-list (- n k)
                         :initial-element
                         '(0)))))

(euclidean-rhythm 3 8)


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


;; (faust-syntax!
;;                (f/import "stdfaust.lib")
;;                (f/defun process ()
;;                         ((b (f/funcall button "capture"))
;;                          (bint (-> b int))
;;                          (r (-> bint
;;                               (- _ (delay-1 bint))
;;                               (<= _ 0)))
;;                          (d (~ (-> (+ bint)
;;                                  (* r))
;;                                _))
;;                          (delay (acc de delay))
;;                          (capture (-> (* b)
;;                                     (~ (-> +
;;                                          (delay (* 8 65536)
;;                                                 (- d 1)))
;;                                        (* (- 1.0 b))))))
;;                         1))

;; (faust-dsp! life
;;             (faust-syntax!
;;               (decl author "me")
;;               (f/import "stdfaust.lib")

;;               (f/defun process ()
;;                        ((smoo (acc si smoo))
;;                         (automat (acc ba automat))
;;                         (bowvel (->
;;                                     (hslider "bowvel"
;;                                                0.01 0.0
;;                                                1.0 0.01)
;;                                   (automat
;;                                    (* 2 360) 16 0.0)
;;                                   smoo))
;;                         (strlength (->
;;                                      (hslider "strlength"
;;                                                 0.75 0
;;                                                 2 0.01)
;;                                      (automat
;;                                       (* 2 360) 16 0.0)
;;                                      smoo))
;;                         (vio (acc pm "violinModel"))

;;                         ;; (strlength (-> (hslider "strlength"
;;                         ;;                         0.75 0
;;                         ;;                         2 0.01)
;;                         ;;              smoo))
;;                         (bowpress (-> (hslider "bowpress"
;;                                                0.5 0
;;                                                1 0.01)
;;                                     smoo))
;;                         ;; (bowvel (-> (hslider "bowvel"
;;                         ;;                      0 0
;;                         ;;                      1 0.01)
;;                         ;;           smoo))
;;                         (bowpos (-> (hslider "bowpos"
;;                                              0.7 0
;;                                              1 0.01)
;;                                   smoo))
;;                         (outgain (-> (hslider "outgain"
;;                                               0.5 0
;;                                               1 0.01)
;;                                    smoo)))
;;                        (-> (vio strlength bowpress
;;                                 bowvel bowpos)
;;                          (* outgain)))))

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




(remfaust life)
(pfaust life)
(sfaust life)
(?faust life)



(comment
  (-> (lookup-faust-dsp 'life)
    fau-audio-ptr
    connect-audio-src)


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
