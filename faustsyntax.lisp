(in-package #:makram)

(comment
  (program
   (statement
    declaration
    file-import
    (definition
        ((simple )
         (function )
         (pattern )
         (expressions
          diag
          (infix (math
                  bitwise
                  compare
                  primitives))
          time
          lexical
          foreign
          lambda))))))

(defclass semicolon-end
    () ())

(defclass parens-block ()
    ())

(defclass args ()
  ())

(defclass program ()
  ((statements
    :initarg :statements
    :accessor stmts)))

(defclass statement () ())

(defclass decl
    (statement semicolon-end)
  ((key  :accessor key
         :initarg :key)
   (val :accessor val
        :initarg :val)))

(defclass fileimport (statement semicolon-end)
  ((filename :accessor filename
             :initarg :filename)))

(defclass fdocumentation (statement)
  ())

(defclass definition (statement semicolon-end)
  ())

(defclass simple-def (definition)
  ((identifier :accessor identifier
               :initarg :identifier)
   (expression :accessor expression
               :initarg :expression)))


(defclass function-def (simple-def)
  ((arguments :accessor arguments
              :initarg :arguments)
   (enviro :accessor enviro
           :initarg :enviro)))

(defclass pattern-def (simple-def)
  ((pattern-args :accessor pattern-args
                 :initarg :pattern-args)))

(defclass expression ()
  ())

(defclass function-application (expression)
  ((identifier :accessor identifier
               :initarg :identifier)
   (arguments :accessor arguments
              :initarg :arguments)))

(defclass diagram (expression parens-block)
  ((binary-op :accessor binary-op
              :initarg :binary-op)
   (expressions :accessor expressions
                :initarg :expressions)))

;; (comment ~ comma : <: :>)

(defclass iteration (expression)
  ())
(comment par seq sum prod)

(defclass numerical (expression)
  ())

(defclass math (numerical)
  ())
(comment + - * / % ^)

(defclass bitwise (numerical)
  ())

(comment "|" & xor << >>)

(defclass comparison (numerical)
  ())

(comment < <= > >= == !=)

(defclass ftime (expression)
  ((lhs :accessor lhs
        :initarg :lhs)
   (rhs :accessor rhs
        :initarg :rhs)))

(defclass delay-n (ftime)
  ())

(defclass delay-1 (ftime)
  ())

 (comment @ "'" )

(defclass bracket-block ()
  ())

(defclass environment (expression)
  ())

(defclass env (expression bracket-block)
  ((definitions :accessor definitions
     :initarg :definitions)))

(defclass env-block (env)
  ())

(defclass with (env)
  ())

(defclass access (environment)
  ((expression :accessor expression
               :initarg :expression)
   (ident :accessor ident
          :initarg :ident)))

(comment
  (defclass library )
  (defclass component)
  (defclass foreign (expression)
    ()))

(defclass fnumber (expression)
  ())
(defclass fint (fnumber)
  ())
(defclass ffloat (fnumber)
  ())

(comment
  (defclass pattern-match (expression)))


(defparameter elementary-signal-ops
  '(- * ^ ! % mem @))

;; arithmetic operations
(defparameter block-diagram-ops
    '(:series ":"
      :parallel ","
      :split "<:"
      :merge ":>"
      :recur "~"))

(defvar *indent-depth* 2)

(declaim (special *indent-depth*))

(defn scope-depth->tab-control
    ((scope-depth integer))
    string
  (format nil "~~~s@T" score-depth))

(defparameter *faust-output*
  (make-string-output-stream))

(defgeneric emit (faust-statement stream))

;; (defgeneric prep (faust))

;; (defmethod prep ((str string))
;;   (format nil "~s" str))

;; (defmethod prep ((sym symbol))
;;   (->> sym symbol-name string-downcase))

;; (defmethod prep ((atom t))
;;   (format nil "~a" atom))

(defmethod emit ((atom t) stream)
  (format stream "~s" atom))

(defmethod emit ((fprog program) stream)
  (loop
     :for statement
     :in (stmts fprog)
     :do (emit statement stream)))

(defmethod emit :before ((decl decl)
                         stream)
  (format stream "declare "))

(defmethod emit :before ((env bracket-block)
                         stream)
  (format stream "{ ~%"))

(defmethod emit :after ((env bracket-block)
                        stream)
  (format stream "~2@T}"))

(defmethod emit :before ((env with)
                         stream)
  (format stream " with "))

(defmethod emit :before ((env env-block)
                         stream)
  (format stream "environment "))

(defmethod emit ((env env)
                 stream)
  (loop
     :for def
     :in (definitions env)
     :do (format stream "~4@T")
     :do (let ((*indent-depth* (+ *indent-depth* 2)))
           (emit def stream))))

(defmethod emit ((dec decl) stream)
  (format stream "~s ~s"
          (->> dec key)
          (->> dec val)))

(defmethod emit ((def simple-def) stream)
  (format stream "~s = "
          (->> def identifier))
  (-> def expression (emit stream)))

(defmethod emit ((def function-def) stream)
  (format stream "~s"
          (->> def identifier))
  (some-> def arguments (emit stream))
  (format stream " = ")
  (-> def expression (emit stream))
  (some-> def enviro (emit stream)))

(defmethod emit :after ((leaf semicolon-end) stream)
  (format stream ";~%"))

(defmethod emit :before ((fim fileimport) stream)
  (format stream "import"))

(defmethod emit ((fim fileimport) stream)
  (-> fim filename (emit stream)))

(defmethod emit ((def function-application) stream)
  (-> def identifier (emit stream))
  (some-> def arguments (emit stream)))

(defmethod emit ((dn delay-n) stream)
  (some-> dn lhs (emit stream))
  (format stream " @ ")
  (some->> dn rhs (emit stream)))

(defmethod emit ((acc access) stream)
  (-> acc expression (emit stream))
  (format stream ".")
  ;; fields can have casing, so sometimes
  ;; I need to just use a string-string
  ;; as opposed to a quoted string
  (if (stringp (-> acc ident))
      (format stream "~a" (-> acc ident))
      (-> acc ident (emit stream))))

(defmethod emit ((dn delay-1) stream)
  (-> dn lhs (emit stream)))

(defmethod emit :after ((dn delay-1) stream)
  (format stream "'"))

(defmethod emit ((args list) stream)
  (loop
   :for exprs
   :on args
   :do (-> exprs first (emit stream))
   :while (rest exprs)
   :do (format stream
               ", ")))


(defmethod emit :before ((args list) stream)
  (format stream "("))
(defmethod emit :after ((args list) stream)
  (format stream ")"))

(defmethod emit :before ((args parens-block) stream)
  (format stream "("))
(defmethod emit :after ((args parens-block) stream)
  (format stream ")"))


(defmethod emit ((dia diagram) stream)
  (loop
   :for exprs
   :on (expressions dia)
   :do (-> exprs first (emit stream))
   :while (rest exprs)
   :do (format stream
                 " ~A "
                 (->> dia
                   binary-op
                   (getf block-diagram-ops)))))

(defn-inline built-inp ((sym symbol))
    boolean
  (or (eql sym 'f/funcall)
      (eql sym '<->)
      (eql sym '->)
      (eql sym 'splt)
      (eql sym 'mrg)
      (eql sym '~)
      (eql sym 'acc)
      (eql sym 'env)
      (eql sym 'delay-1)))

(defun should-funcallp (element)
  (not (or (built-inp (car element))
           (not (symbolp (car element))))))

(defun expand-tup (tup)
  (cond
    ((listp tup)
     (cond
       ((= (length tup) 2)
        (bind (((signifier signified) tup))
          (if (listp signified)
              (if (should-funcallp signified)
                  (list 'f/def signifier
                        (cons 'f/funcall signified))
                  (cons 'f/def tup))
              (cons 'f/def tup))))
       (t (cons 'f/defun tup))))

    (t
     (list 'f/expand tup))))

(defmacro faust-syntax! (&body program)
  `(macrolet ((f/expand (arg)
                (cond
                  ((symbolp arg)
                   `',arg)
                  ((and (listp arg)
                        (-> arg first symbolp)
                        (-> arg first built-inp))
                   arg)
                  ;; ((and (listp arg)
                  ;;       (-> arg first symbolp)
                  ;;       (-> arg first built-inp not))
                  ;;  `(list ',(cons 'f/funcall arg)))
                  ((listp arg)
                   `(list
                     ,@(mapcar (lambda (arg)
                                 (if (and (listp arg)
                                          (-> arg first symbolp)
                                          (-> arg first built-inp not))
                                     (cons 'f/funcall arg)
                                     (list 'f/expand arg)))
                               arg)))
                  (t  arg)))
              (delay-1 (lhs)
                  `(make-instance 'delay-1
                                  :lhs (f/expand ,lhs)
                                  :rhs nil))
              (delay-n (lhs rhs)
                  `(make-instance 'delay-n
                                  :lhs (f/expand ,lhs)
                                  :rhs (f/expand ,rhs)))

                (-> (&body ops)
                  `(make-instance 'diagram
                                  :binary-op :series
                                  :expressions (f/expand ,ops)))
                (<-> (&body ops)
                  `(make-instance 'diagram
                                  :binary-op :parallel
                                  :expressions (f/expand ,ops)))
                (splt (&body ops)
                  `(make-instance 'diagram
                                  :binary-op :split
                                  :expressions (f/expand ,ops)))
                (mrg (&body ops)
                  `(make-instance 'diagram
                                  :binary-op :merge
                                  :expressions (f/expand ,ops)))
                (~ (&body ops)
                  `(make-instance 'diagram
                                  :binary-op :recur
                                  :expressions (f/expand ,ops)))

                (acc (expr ident)
                  `(make-instance 'access
                                  :expression (f/expand ,expr)
                                  :ident (f/expand ,ident)))
                (decl (key val)
                  `(make-instance 'decl
                                  :key ',key
                                  :val ,val))
                (env (&body bindings)
                  `(make-instance 'env-block
                                 :definitions
                                 (list ,@(mapcar
                                          #'expand-tup
                                          bindings))))
                (f/import (filename)
                  `(make-instance 'fileimport
                                  :filename (list ,filename)))
                (f/def (id expr)
                  `(make-instance 'simple-def
                                  :identifier (f/expand ,id)
                                  :expression (f/expand ,expr)))
                (f/funcall (identifier &body args)
                  `(make-instance 'function-application
                                  :identifier (f/expand ,identifier)
                                  :arguments (f/expand ,args)))
                (! (identifier &body args)
                  `(make-instance 'function-application
                                  :identifier (f/expand ,identifier)
                                  :arguments (f/expand ,args)))
                (f/defun (identifier args bindings &body body)
                  (if bindings
                      `(make-instance 'function-def
                                      :identifier (f/expand ,identifier)

                                      :enviro (make-instance 'with
                                                             :definitions
                                                             (list ,@(mapcar
                                                                      #'expand-tup
                                                                      bindings)))
                                      :arguments (f/expand ,args)
                                      :expression (f/expand ,@body))
                      `(make-instance 'function-def
                                      :identifier (f/expand ,identifier)
                                      :arguments (f/expand ,args)
                                      :enviro nil
                                      :expression (f/expand ,@body)))))
       (let ((*print-case* :downcase))
         (emit (make-instance 'program
                              :statements (list ,@program))
               *faust-output*)
         (get-output-stream-string *faust-output*))))
