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

(hash-ref measurements '(1 0))
; (define data
  ; (list*->array
    ; (map parse-line (drop-while (curryr starts-with? "WATCH") (port->lines)))
    ; (λ (x) (or (number? x) (string? x)))))

; (array-fold data (λ (a i) (array->vector a)))
