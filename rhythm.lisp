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

(defun euclid (m k)
  (if (zerop k)
      m
      (euclid k (mod m k))))

(comment
 (euclid 3 8)

 (euclidean-rhythm 3 8))
