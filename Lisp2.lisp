(defpackage #:mem-test
  (:nicknames :mt)
  (:use #:cl))

(declaim (optimize (speed 3) (safety 0) (space 0) (debug 0)))

(in-package #:mem-test)
(export '(run))

(defparameter *NUM_RECORDS* (* 50 1000 444))

(defstruct lisp-memory-trade (trade-id 0) (client-id 0) (venue-code 0) (instrument-code 0) (price 0) (quantity 0) (side #\x))
(defvar trades (make-array *NUM_RECORDS* :initial-element (make-lisp-memory-trade) :element-type 'lisp-memory-trade) )

(defun init-trades ()
          (dotimes (i *NUM_RECORDS*)
              (progn (setf (lisp-memory-trade-trade-id (aref trades i)) i)
                     (setf (lisp-memory-trade-client-id (aref trades i)) 1)
                     (setf (lisp-memory-trade-venue-code (aref trades i)) 123)
                     (setf (lisp-memory-trade-instrument-code (aref trades i)) 321)
                     (setf (lisp-memory-trade-price (aref trades i)) i)
                     (setf (lisp-memory-trade-quantity (aref trades i)) i)
                     (if (oddp i)
                       (setf (lisp-memory-trade-side (aref trades i)) #\S)
                       (setf (lisp-memory-trade-side (aref trades i)) #\B)))))

(defun perf-run (run-num)
  (let (
    (start-t (get-internal-run-time))
    (buy-cost 0)
    (sell-cost 0))
      (progn
      (init-trades)
      (dotimes (i *NUM_RECORDS*)
           (if (equal (lisp-memory-trade-side (aref trades i)) #\B)
              (setf buy-cost (+ buy-cost (* (lisp-memory-trade-price (aref trades i)) (lisp-memory-trade-quantity (aref trades i)))))
              (setf sell-cost (+ sell-cost (* (lisp-memory-trade-price (aref trades i)) (lisp-memory-trade-quantity (aref trades i)))))))
      (format t "~d duration ~d ms~%" run-num (- (get-internal-run-time) start-t) )
      (format t "buycost = ~d sellCost = ~d~%" buy-cost sell-cost))))

(defun run ()
  (time(loop for i from 0 to 5 do (perf-run i))))
