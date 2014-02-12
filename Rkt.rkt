#lang typed/racket
(require racket/performance-hint)
(define: *NUM_RECORDS* : Integer 5000000)


(struct: rkt-mem-trade ([trade-id : Integer] [client-id : Integer] [venue-id : Integer]
                                             [instrument-code : Integer] [price : Integer] [quantity : Integer] 
                                             [side : Char])
  #:mutable) 


(define trades (make-vector *NUM_RECORDS* [rkt-mem-trade 1 1 1 1 1 1 #\a])) 

(: pack ( (Listof Char) -> Integer))
(define (pack vals) 2)

(define (init-trades)
    (for ([i (in-range 0 *NUM_RECORDS*)])
      (let ([trade-ref (vector-ref trades i)])
        (begin (set-rkt-mem-trade-trade-id! trade-ref i)
               (set-rkt-mem-trade-client-id! trade-ref 1)
               (set-rkt-mem-trade-venue-id! trade-ref 123)
               (set-rkt-mem-trade-instrument-code! trade-ref 321)
               (set-rkt-mem-trade-price! trade-ref i)
               (set-rkt-mem-trade-quantity! trade-ref i)
               (if (odd? i)
                   (set-rkt-mem-trade-side! trade-ref #\S)
                   (set-rkt-mem-trade-side! trade-ref #\B))))))

(define-inline (perform-run run-num) 
  (let (
        [start-t (current-inexact-milliseconds)]
        [buy-cost 0]
        [sell-cost 0])
    (begin
      (init-trades)
      (for ([i (in-range 0 *NUM_RECORDS*)])
        (let ([trade-ref (vector-ref trades i)])
          (if (equal? (rkt-mem-trade-side trade-ref) #\B)
              (set! buy-cost (+ buy-cost (* (rkt-mem-trade-price trade-ref) (rkt-mem-trade-quantity trade-ref))))
              (set! sell-cost (+ sell-cost (* (rkt-mem-trade-price trade-ref) (rkt-mem-trade-quantity trade-ref)))))))
      (printf "Run ~v had duration of ~v seconds~%" run-num (- (current-inexact-milliseconds) start-t) )
      (printf "buycost = ~v sellCost = ~v ~%" buy-cost sell-cost))))

(define (run)
  (time(for ([i (in-range 0 5)]) (perform-run i))))

(run)
