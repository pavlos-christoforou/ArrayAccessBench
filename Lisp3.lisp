(defpackage #:mem-test
  (:nicknames :mt)
  (:use #:cl))

(declaim (optimize (speed 3) (safety 0) (space 0) (debug 0)))

(in-package #:mem-test)
(export '(run))

(sb-alien:define-alien-type mp-limb-t sb-alien:unsigned-int)
(sb-alien:define-alien-type mp-bitcnt-t sb-alien:unsigned-long)
(sb-alien:define-alien-type mpz-struct
				   (sb-alien:struct nil
						   (mp-alloc sb-alien:int)
						   (mp-size sb-alien:int)
						   (mp-d mp-limb-t)))

(sb-alien:define-alien-type mpz-ptr (* mpz-struct))
(sb-alien:define-alien-type mpz-srcptr (* mpz-struct))

(declaim (inline mpz-init-set-si))
(sb-alien:define-alien-routine ("__gmpz_init_set_si" mpz-init-set-si)
					  sb-alien:void
					  (a mpz-ptr)
					  (b sb-alien:long))


(declaim (inline mpz-init))
(sb-alien:define-alien-routine ("__gmpz_init" mpz-init)
					  sb-alien:void
					  (a mpz-ptr))

(declaim (inline mpz-get-si))
(sb-alien:define-alien-routine ("__gmpz_get_si" mpz-get-si)
					  sb-alien:long
					  (a mpz-srcptr))

(declaim (inline mpz-set-si))
(sb-alien:define-alien-routine ("__gmpz_set_si" mpz-set-si)
					  sb-alien:void
					  (a mpz-ptr)
					  (b sb-alien:long))

(declaim (inline mpz-add))
(sb-alien:define-alien-routine ("__gmpz_add" mpz-add)
					  sb-alien:void
					  (a mpz-ptr)
					  (b mpz-srcptr)
					  (c mpz-srcptr))


(defvar *libgmp-so* (sb-alien:load-shared-object "libgmp.so"))
(defvar *buy-cost*)
(defvar *sell-cost*)
(defvar *to-add*)

(defun init-bignums ()
  (setf *buy-cost* (sb-alien:make-alien mpz-struct))
  (setf *sell-cost* (sb-alien:make-alien mpz-struct))
  (setf *to-add* (sb-alien:make-alien mpz-struct)))

(defun cleanup-bignums ()
  (sb-alien:free-alien *buy-cost*)
  (sb-alien:free-alien *sell-cost*)
  (sb-alien:free-alien *to-add*))


(defconstant +NUM_RECORDS+ (* 50 1000 100))

(defstruct lisp-memory-trade (trade-id 0 :type fixnum) (client-id 0 :type fixnum) (venue-code 0 :type fixnum) (instrument-code 0 :type fixnum) (price 0 :type fixnum) (quantity 0 :type fixnum) (side #\x :type character))
(declaim (vector trades))
(defvar trades (make-array +NUM_RECORDS+ :element-type 'lisp-memory-trade) )


(defun prep-trades ()
  (dotimes (i +NUM_RECORDS+)
    (setf (aref trades i) (make-lisp-memory-trade) )))


(defun init-trades ()
          (dotimes (i +NUM_RECORDS+)
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
    (start-t (get-internal-run-time)))
     (progn
      (init-trades)
      (mpz-init *buy-cost*)
      (mpz-init *sell-cost*)
      (mpz-init *to-add*)
      (dotimes (i +NUM_RECORDS+)
         (let ((trade-ref (aref trades i)))
          (progn 
           (mpz-set-si *to-add* (* (lisp-memory-trade-price trade-ref) (lisp-memory-trade-quantity trade-ref)))
           (if (equal (lisp-memory-trade-side trade-ref) #\B)
              (mpz-add *buy-cost* *buy-cost* *to-add*)
              (mpz-add *sell-cost* *sell-cost* *to-add*)))))   
      (format t "~d duration ~d ms~%" run-num (- (get-internal-run-time) start-t) )
      (format t "buycost = ~d sellCost = ~d~%" (mpz-get-si *buy-cost*) (mpz-get-si *sell-cost*)))))

(defun run ()
  (prep-trades)
  (init-bignums)
  (time(loop for i from 0 to 5 do (perf-run i)))
  (cleanup-bignums))
