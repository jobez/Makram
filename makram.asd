;;;; sequent.asd

(asdf:defsystem #:makram
  :description "Describe sequent here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :depends-on (:metabang-bind
               :iterate
               :arrow-macros
               :alexandria
               :serapeum
               :rtg-math
               :scheduler
               :jsown
               :fiveam
               :inlined-generic-function
               :nineveh
               :dirt
               :lparallel
               :bordeaux-threads
               :cffi
               #:cffi/c2ffi
               #:cffi-libffi)
  :serial t
  :defsystem-depends-on (:cffi/c2ffi)
  :components ((:file "package")
               (:file "faustsyntax")
               (:file "faustbind")))
