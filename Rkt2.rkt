#lang typed/racket
(require racket/performance-hint)
(define: *NUM_RECORDS* : Integer (* 50 1000 444))


(struct: rkt-mem-trade ([trade-id : Integer] [client-id : Integer] [venue-id : Integer]
                                             [instrument-code : Integer] [price : Integer] [quantity : Integer] 
                                             [side : Char])
  #:mutable) 

(define (make-trade i) (rkt-mem-trade 1 1 1 1 1 1 #\a))

(define: trades : (Vectorof rkt-mem-trade) (build-vector *NUM_RECORDS* make-trade)) 

(define (init-trades)
    (for ([i (in-range 0 *NUM_RECORDS*)])
        (begin (set-rkt-mem-trade-trade-id! (vector-ref trades i) i)
               (set-rkt-mem-trade-client-id! (vector-ref trades i) 1)
               (set-rkt-mem-trade-venue-id! (vector-ref trades i) 123)
               (set-rkt-mem-trade-instrument-code! (vector-ref trades i) 321)
               (set-rkt-mem-trade-price! (vector-ref trades i) i)
               (set-rkt-mem-trade-quantity! (vector-ref trades i) i)
               (if (odd? i)
                   (set-rkt-mem-trade-side! (vector-ref trades i) #\S)
                   (set-rkt-mem-trade-side! (vector-ref trades i) #\B)))))

(define-inline (perform-run run-num) 
  (let (
        [start-t (current-inexact-milliseconds)]
        [buy-cost 0]
        [sell-cost 0])
    (begin
      (init-trades)
      (for ([i (in-range 0 *NUM_RECORDS*)])    
          (if (equal? (rkt-mem-trade-side (vector-ref trades i)) #\B)
              (set! buy-cost (+ buy-cost (* (rkt-mem-trade-price (vector-ref trades i)) (rkt-mem-trade-quantity (vector-ref trades i)))))
              (set! sell-cost (+ sell-cost (* (rkt-mem-trade-price (vector-ref trades i)) (rkt-mem-trade-quantity (vector-ref trades i)))))))
      (printf "Run ~v had duration ~v ms~%" run-num (inexact->exact (floor (- (current-inexact-milliseconds) start-t))) )
      (printf "buycost = ~v sellCost = ~v ~%" buy-cost sell-cost))))

(define (run)
  (time(for ([i (in-range 0 5)]) (perform-run i))))

(run)
