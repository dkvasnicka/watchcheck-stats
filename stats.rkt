#lang racket

(require string-util
         rackjure/conditionals
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

(let* ([m (hash-ref measurements-as-arrays '(1 0))]
       [times (timestamps m)]
       [minmax-diffs (array- (array-axis-max times 0) (array-axis-min times 0))])
  (~r
    (/
      (*
        (array-ref (array-axis-fold minmax-diffs 0 -) #[])
        (/ 86400000 (array-ref minmax-diffs #[1])))
      1000)
    #:precision 1))
