(in-package :makram)

;; as came across in the oldmacdonald.lisp example in common lisp music
(defun note->hz ( note)
  (let* ((low 16.351597)
         (raw (string note))
         (key '((c bs) (df cs) (d) (ds ef)
                (e ff) (f es) (gf fs) (g)
                (gs af) (a) (as bf) (b cf)))
         (pos (position-if #'digit-char-p raw))
         (int (or (position (intern (subseq raw 0 pos))
                            key :test #'member)
                  (error "cant resolve note ~S" nam)))
         (oct (if pos (parse-integer raw :start pos) 4)))
    (* low (expt 2 (+ oct (/ int 12))))))