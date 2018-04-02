(in-package :makram)

(cffi:define-foreign-library faustbind
  (t #.(asdf/system:system-relative-pathname :makram "cxx/faustbind.so")))

(cffi:load-foreign-library 'faustbind)

(cffi:defcfun ("str_to_dsp" str-to-dsp) :pointer
  (dsp-name :string)
  (dsp :string))

(cffi:defcfun ("init_jack" init-jack) :pointer
  (audio-name :string)
  (dsp :pointer))

(cffi:defcfun ("connect_audio_src" connect-audio-src) :void
  (audio :pointer))

(cffi:defcfun ("init_apiui" init-apiui) :pointer
  (dsp :pointer))

(cffi:defcfun ("kill_apiui" kill-apiui) :void
  (apiui :pointer))

(cffi:defcfun ("kill_audio" kill-audio) :void
  (audio :pointer))

(cffi:defcfun ("kill_dsp" kill-dsp) :void
  (dsp :pointer))

(cffi:defcfun ("play" playfaust) :void
  (audio :pointer))

(cffi:defcfun ("stop" stop) :void
  (audio :pointer))

(cffi:defcfun ("update_dsp" update-dsp) :void
  (audio :pointer)
  (dsp :pointer))

(cffi:defcfun ("dsp_to_json" dsp-to-json) :string
  (dsp :pointer))

(cffi:defcfun ("get_param" get-param) :float
  (ui :pointer)
  (param-path :string))

(cffi:defcfun ("set_param" set-param) :void
  (ui :pointer)
  (param-path :string)
  (value :float))

(defparameter *faust-aunits*
  (make-hash-table))

;; maybe useful to make dsp + ui its own thing and extend into an audio-ptr
;; but meh its easier to make a dsp graph within faust rn--sure there's an
;; upper limit where the jit loses its nice feedback, but let's address that
;; when it happens <2017-12-01 Fri>
(defstruct (faust-unit
             (:conc-name fu-)
             (:constructor %make-faust-unit))
  (dsp-ptr (null-pointer)
           :type foreign-pointer)
  (ui-ptr (null-pointer)
          :type foreign-pointer))

(defstruct (faust-audio-unit
             (:conc-name fau-)
             (:include faust-unit)
             (:constructor %make-faust-audio-unit))
  (audio-ptr (null-pointer)
             :type foreign-pointer))

(defn-inline delete-dsp! ((fau faust-audio-unit))
    null
  (stop (fau-audio-ptr fau))
  (kill-audio (fau-audio-ptr fau))
  (kill-dsp (fau-dsp-ptr fau))
  (kill-apiui (fau-ui-ptr fau))
  (values))

(defn %remfaust ((aunit-name symbol))
    null
  (some-> aunit-name
    lookup-faust-dsp
    delete-dsp!)
  (remhash aunit-name *faust-aunits*)
  (values))

(defn-inline update-dsp! ((fau faust-audio-unit)
                          (dsp foreign-pointer))
    faust-audio-unit
  (stop (fau-audio-ptr fau))
  (kill-apiui (fau-ui-ptr fau))
  (let ((new-ui (init-apiui dsp)))
    (setf (fau-dsp-ptr fau)
          dsp
          (fau-ui-ptr fau)
          new-ui)
    (update-dsp (fau-audio-ptr fau)
                (fau-dsp-ptr fau))
    fau))

(defn-inline sym->faust-string ((aunit-name symbol))
    string
  (-> aunit-name
    symbol-name
    string-downcase))

(defn-inline expr->aunit ((name string)
                          (expr string))
    faust-audio-unit
  (bind ((dsp (str-to-dsp name expr))
         (audio (init-jack name dsp))
         (apiui (init-apiui dsp)))
    (%make-faust-audio-unit
     :dsp-ptr dsp
     :ui-ptr apiui
     :audio-ptr audio)))

(defn lookup-faust-dsp ((aunit-name symbol))
    (or faust-audio-unit null)
  (gethash aunit-name *faust-aunits*))

(defn-inline set-faust-dsp-prop! ((aunit-sym symbol)
                                  (prop (or string symbol))
                                  (val float))
    null
  (bind ((prop (cond-> prop
                 (symbolp prop)
                 sym->faust-string)))
    (some-> aunit-sym
      lookup-faust-dsp
      fau-ui-ptr
      (set-param prop val)))

  (values))

(defn-inline get-faust-dsp-prop!
    ((aunit-sym symbol)
     (prop (or string symbol)))
    float
  (bind ((prop (cond-> prop
                 (symbolp prop)
                 sym->faust-string)))

    (-> aunit-sym
      lookup-faust-dsp
      fau-ui-ptr
      (get-param prop))))

(defn %faust-dsp! ((aunit-sym symbol)
                   (expr string)
                   (play boolean))
    null
  (let* ((faust-name (-> aunit-sym
                       sym->faust-string))
         (aunit
          (alexandria:if-let (aunit (lookup-faust-dsp aunit-sym))


            (update-dsp! aunit
                         (str-to-dsp faust-name
                                     expr))
            (setf (gethash aunit-sym
                           *faust-aunits*)
                  (expr->aunit faust-name
                               expr)))))
    (when play
      (playfaust (fau-audio-ptr aunit))))
  (values))

(defmacro faust-dsp! (name
                      expr
                      &optional (play t))
  `(%faust-dsp! ',name ,expr ,play))

(defmacro ?faust (name)
  `(lookup-faust-dsp ',name))

(defmacro sfaust (name)
  `(some->
       ',name
     lookup-faust-dsp
     fau-audio-ptr
     stop))

(defmacro pfaust (name)
  `(some->
       ',name
     lookup-faust-dsp
     fau-audio-ptr
     playfaust))

(defmacro remfaust (&body names)
  `(dolist (name ',names)
     (%remfaust name)))

(defmacro set-faust! (name prop val)
  `(set-faust-dsp-prop! ',name ',prop ,val))

(defmacro get-faust! (name prop)
  `(get-faust-dsp-prop! ',name ',prop))
