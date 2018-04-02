(in-package :makram.scheduler)

(defvar *scheduler* (make-instance 'scheduler))

(sched-run *scheduler*)

(defun sched! (time-delta instr-name attr val)
 (sched-add *scheduler*
            (+ time-delta
               (sched-time *scheduler*))
            #'makram::set-faust-dsp-prop!
            instr-name attr val))

(comment
 (sched-clear *scheduler*)
 (sched-stop *scheduler*))
