#lang sicp
;; file: 1_19.rkt
(#%require racket/trace)

;; 빈칸체우기
#|
T(a, b) - p/q에 대해서
a' = bq + aq + ap
b' = bp + aq

T(T(a, b)) - p/q에 대해서
a'' =         b'q +             a'q +             a'p
    = ((bp + aq)q + (bq + aq + ap)q + (bq + aq + ap)p
    =  bpq + aq^2 + bq^2 + aq^2 + aqp + bqp + aqp + ap^2
    = b(2qp + q^2)+    a(q^2 + p^2) +    a(2qp + q^2)
b'' =          b'p +             a'q
    =   (bp + aq)p + (bq + aq + ap)q
    =   bp^2 + aqp + bq^2 + aq^2 + aqp
    = b(p^2 + q^2) +    a(2qp + q^2)

p' = p^2 + q^2
q' = 2qp + q^2

|#


(define (fib-recur n)
  (cond ((= n 0) 0)
        ((= n 1) 1)
        (else (+ (fib-recur (- n 1))
                 (fib-recur (- n 2))))))

(define (fast-fib-iter n)
  (fib-iter 1 0 0 1 n))

(define (fib-iter a b p q count)
  (cond ((= count 0)
         b)
        ((even? count)
         (fib-iter a
                   b
                   (+ (* p p) (* q q))   ; p' = p^2 + q^2
                   (+ (* 2 p q) (* q q)) ; q' = 2qp + q^2
                   (/ count 2)))
        (else 
         (fib-iter (+ (* b q) (* a q) (* a p)) ; a = bq + aq + ap
                   (+ (* b p) (* a q))         ; b = bp + aq
                   p
                   q
                   (- count 1)))))
#|

| fib | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10|
|-----|---|---|---|---|---|---|---|---|---|---|---|
| res | 0 | 1 | 1 | 2 | 3 | 5 | 8 | 13| 21| 34| 55|

|#

(fib-recur 10)

(fast-fib-iter 10)

#|
(trace fib-iter)

>{fib-iter 1 0 0 1 10}
>{fib-iter 1 0 1 1 5}
>{fib-iter 2 1 1 1 4}
>{fib-iter 2 1 2 3 2}
>{fib-iter 2 1 13 21 1}
>{fib-iter 89 55 13 21 0}
<55
|#

