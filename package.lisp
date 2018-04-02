;;;; package.lisp

(uiop:define-package #:makram.faust-syntax
    (:mix :cl :metabang-bind
          :arrow-macros :iterate
          :serapeum :fiveam)
  (:import-from :%rtg-math :defn :defn-inline)
  (:export faust-syntax!))

(uiop:define-package #:makram
    (:mix :cl :rtg-math
          :metabang-bind :arrow-macros
          :iterate :cffi
          :lparallel.queue
          :serapeum)
    (:import-from :%rtg-math :defn :defn-inline))

(uiop:define-package #:makram.scheduler
    (:mix :cl :metabang-bind
          :arrow-macros :iterate
          :scheduler :serapeum
          :fiveam)
  (:import-from :%rtg-math :defn :defn-inline)
  (:export sched!))
