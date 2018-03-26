(use-package :cm-ifs)

(load "helpers.lisp")

(defmacro mk-box (fn-name)
  `(function ,fn-name ((const char* label)) override -> void
             (if atRoot
                 (set atRoot false)
                 (boxes.push-back label))))

(defmacro mk-option (fn-name type output)
  (declare (ignorable type output))
  `(function ,fn-name ((const char* label)
                       (FAUSTFLOAT* zone)
                       (FAUSTFLOAT init)
                       (FAUSTFLOAT min)
                       (FAUSTFLOAT max)
                       (FAUSTFLOAT step))
             override -> void
             (set option-map[label] zone)))

(defmacro mk-boxes (fn-names)
  `(progn
     ,@(loop
          :for fn-name
          :in fn-names
          :collect (mk-box fn-name))))

(defmacro mk-options (option-args)
  `(progn
     ,@(loop
          :for (fn-name type output)
          :in option-args
          :collect (mk-option fn-name type output))))

(with-interface (clui)
  (interface-only
   (include <map>)
   (include <vector>)
   (include <string>)
   (include <faust/gui/UI.h>)
   (include <faust/gui/meta.h>)
   (include <faust/dsp/dsp.h>)

   (class CLUI
       ((public UI))
     (decl (((instantiate #:std::vector (#:std::string)) boxes)
            (bool atRoot = true)
            ((instantiate #:std::map
                          (#:std::string)
                          (FAUSTFLOAT*))
             option-map)))
     (public
       (enum OPTTYPE (FLOAT BOOL))

       (mk-boxes (openTabBox openHorizontalBox openVerticalBox))
       (function closeBox () virtual -> void)
       (function addSoundfile ((const char* label)
                               (const char* filename)
                               (Soundfile** sf-zone))
           virtual -> void)

       (mk-options (;; (addHorizontalBargraph FLOAT true)
                    ;; (addVerticalBargraph FLOAT true)
                    ;; (addButton BOOL true)
                    ;; (addCheckButton BOOL true)
                    (addVerticalSlider FLOAT true)
                    (addHorizontalSlider FLOAT true)
                    (addNumEntry FLOAT true)))

       (function addButton ((const char* label)
                            (FAUSTFLOAT* zone))
             override -> void
             (set option-map[label] zone))

       (function addCheckButton ((const char* label)
                            (FAUSTFLOAT* zone))
             override -> void
             (set option-map[label] zone))

       (function addHorizontalBargraph
           ((const char* label)
            (FAUSTFLOAT* zone)

            (FAUSTFLOAT min)
            (FAUSTFLOAT max))
             override -> void
             (set option-map[label] zone))

       (function addVerticalBargraph
           ((const char* label)
            (FAUSTFLOAT* zone)

            (FAUSTFLOAT min)
            (FAUSTFLOAT max))
             override -> void
             (set option-map[label] zone))
        ))))
