#lang rackjure

(require string-util)

(define header (read-line))

(define (parse-line l)
  (map
    (λ (val) (if-let [parsed-num (string->number val)] parsed-num val))
    (string-split (string-trim l #px"(LOG|WATCH): ") "|")))

(define watches 
  (for/hasheq ([l (in-lines)] #:break (starts-with? l "LOG"))
    (match-let ([(list watch-id watch-name ...) (parse-line l)])
      (values watch-id watch-name))))

(define measurements
  (for/fold ([ms (make-immutable-hasheq (map (λ (k) (cons k '())) (hash-keys watches)))])
            ([l (sequence-map parse-line (in-lines))]) 
    (hash-update ms (second l) (curry cons l))))

measurements
