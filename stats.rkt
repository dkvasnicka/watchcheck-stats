#lang racket

(require string-util
         rackjure/conditionals
         math/statistics
         srfi/1
         math/array)

(define header (read-line))

(define (parse-line l)
  (map
    (λ (val)
      (if-let [parsed-num (string->number (string-trim val))]
              parsed-num
              val))
    (take (cdr (cdr (string-split l #px"[:|]"))) 6)))

(define measurements
  (for/fold ([m (hash)])
            ([l (in-lines)] #:unless (starts-with? l "WATCH"))
    (let ([row (parse-line l)])
      (hash-update m (take row 2) (curry cons row) '()))))

(define measurements-as-arrays
  (for/hash ([(k v) (in-hash measurements)])
    (values k
            (list*->array
              v
              (λ (x) (or (number? x) (string? x)))))))

(define (timestamps m)
  (array-lazy
    (array-slice-ref
      m
      (list
        (:: 0 (vector-ref (array-shape m) 0))
        '(2 3)))))

(define (compute-daily-precision m)
  (let* ([times (timestamps m)]
         [minmax-diffs (array- (array-axis-max times 0) (array-axis-min times 0))]
         [m-weight (array-ref minmax-diffs #[1])])
    (values
      (/
        (*
          (array-ref (array-axis-fold minmax-diffs 0 -) #[])
          (/ 86400000 m-weight))
        1000)
      m-weight)))

(define weighted-deviations
  (for/fold ([stats (hash)])
    ([(k m) (in-hash measurements-as-arrays)]
      #:unless (<= (vector-ref (array-shape m) 0) 1))
    (let-values ([(daily-deviation weight) (compute-daily-precision m)])
      (hash-update stats
                   (car k)
                   (match-lambda
                     [(list devs weights) (list (cons daily-deviation devs)
                                                (cons weight weights))])
                   '(() ())))))

(for ([(watch-id wdev) (in-hash weighted-deviations)])
  (displayln
    (format "~a: ~a" watch-id (~r (apply mean wdev) #:precision 1))))
