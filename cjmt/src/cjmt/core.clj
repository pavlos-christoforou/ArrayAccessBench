(ns cjmt.core
  (:gen-class))

(set! *warn-on-reflection* true)
;(set! *unchecked-math* true)

(def ^:const NUM_RECORDS (* 50 1000 10))

(definterface IMemTest
  (^Long gtradeId []) (^Long gclientId []) (^Long gvenueId []) (^Long ginstrumentCode []) (^Long gprice []) 
  (^Long gquantity []) (^Character gside []) 
  (stradeId [^Long v]) (sclientId [^Long v]) (svenueId [^Long v]) (sinstrumentCode [^Long v]) (sprice [^Long v])
  (squantity [^Long v]) (sside [^Character v]))

(deftype CJMemTest [^:unsynchronized-mutable ^Long tradeId ^:unsynchronized-mutable ^Long clientId ^:unsynchronized-mutable ^Long venueId 
                   ^:unsynchronized-mutable ^Long instrumentCode ^:unsynchronized-mutable ^Long price ^:unsynchronized-mutable ^Long quantity 
                   ^:unsynchronized-mutable ^Character side]
  IMemTest
  (gtradeId [_] tradeId)(gclientId [_] clientId)(gvenueId [_] venueId)(ginstrumentCode [_] instrumentCode)
  (gprice [_] price)(gquantity [_] quantity)(gside [_] side)
  (stradeId [this v] (set! tradeId v)) (sclientId [this v] (set! clientId v)) (svenueId [this v] (set! venueId v))
  (sinstrumentCode [this v] (set! instrumentCode v))
  (sprice [this v] (set! price v)) (squantity [this v] (set! quantity v))(sside [this v] (set! side v)))

(def trades ^"[Ljava.lang.Object;" (make-array Object NUM_RECORDS))

(defn init-trades []
    (dotimes [i NUM_RECORDS]
      (let [trade-ref ^CJMemTest (aget ^"[Ljava.lang.Object;" trades i)]
        (do (.stradeId trade-ref i)
               (.sclientId trade-ref 1)
               (.svenueId trade-ref 123)
               (.sinstrumentCode trade-ref 321)
               (.sprice trade-ref i)
               (.squantity trade-ref i)
               (if (odd? i)
                   (.sside trade-ref \S)
                   (.sside trade-ref \B))))))

(defn perform-run [^Long run-num] 
  (let  [start-t (System/currentTimeMillis)]
    (do
      (def buy-cost (long 0))
      (def sell-cost (long 0))
      (init-trades)
      (dotimes [i NUM_RECORDS]
        (let [trade-ref ^CJMemTest (aget ^"[Ljava.lang.Object;" trades i)]
          (if (= (.gside trade-ref) \B)
              (def buy-cost (+ buy-cost (* (.gprice trade-ref) (.gquantity trade-ref)))) 
              (def sell-cost (+ sell-cost (* (.gprice trade-ref) (.gquantity trade-ref))))))) 
      ;(printf "Run %d had duration of %.6f seconds\n" run-num (- (System/currentTimeMillis) start-t) )
      (printf "Run %d had duration of " run-num)
      (print (- (System/currentTimeMillis) start-t))
      (println "ms")
      (printf "buycost = %d sellCost = %d \n" buy-cost sell-cost))))

(defn run []
  (dotimes [i NUM_RECORDS] (aset ^"[Ljava.lang.Object;" trades i (CJMemTest. 1 1 1 1 1 1 \a)))
  (dotimes [i 5] (perform-run i)))

(defn -main []
  (run))
