(defpackage #:mem-test
  (:nicknames :mt)
  (:use #:cl))

(declaim (optimize (speed 3) (safety 0) (space 0) (debug 0)))

(in-package #:mem-test)
(export '(run))

(defparameter *NUM_RECORDS* (* 50 1000 444))

(defstruct lisp-memory-trade (trade-id 0) (client-id 0) (venue-code 0) (instrument-code 0) (price 0) (quantity 0) (side #\x))
(defvar trades (make-array *NUM_RECORDS* :element-type 'lisp-memory-trade) )

(defun prep-trades ()
  (dotimes (i *NUM_RECORDS*)
    (setf (aref trades i) (make-lisp-memory-trade) )))

(defun init-trades ()
          (dotimes (i *NUM_RECORDS*)
            (let ((trade-ref (aref trades i)))
              (progn (setf (lisp-memory-trade-trade-id trade-ref) i)
                     (setf (lisp-memory-trade-client-id trade-ref) 1)
                     (setf (lisp-memory-trade-venue-code trade-ref) 123)
                     (setf (lisp-memory-trade-instrument-code trade-ref) 321)
                     (setf (lisp-memory-trade-price trade-ref) i)
                     (setf (lisp-memory-trade-quantity trade-ref) i)
                     (if (oddp i)
                       (setf (lisp-memory-trade-side trade-ref) #\S)
                       (setf (lisp-memory-trade-side trade-ref) #\B))))))

(defun perf-run (run-num)
  (let (
    (start-t (get-internal-run-time))
    (buy-cost 0)
    (sell-cost 0))
      (progn
      (init-trades)
      (dotimes (i *NUM_RECORDS*)
         (let ((trade-ref (aref trades i)))
           (if (equal (lisp-memory-trade-side trade-ref) #\B)
              (setf buy-cost (+ buy-cost (* (lisp-memory-trade-price trade-ref) (lisp-memory-trade-quantity trade-ref))))   
              (setf sell-cost (+ sell-cost (* (lisp-memory-trade-price trade-ref) (lisp-memory-trade-quantity trade-ref))))))) 
      (format t "~d duration ~d ms~%" run-num (- (get-internal-run-time) start-t) )
      (format t "buycost = ~d sellCost = ~d~%" buy-cost sell-cost))))

(defun run ()
  (prep-trades)
  (time(loop for i from 0 to 5 do (perf-run i))))
