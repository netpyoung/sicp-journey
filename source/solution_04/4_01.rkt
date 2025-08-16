#lang sicp
;; file: 4_01.rkt
(#%require rackunit)
(#%require (prefix racket: racket))

(racket:require "../allcode/ch4-4.1.1-mceval.rkt")

;; 여기서의 cons는 left평가후 right를 평가한다.
(cons
 (begin (display "1") (newline) 1)
 (begin (display "2") (newline) 2))
;;>> 1
;;>> 2
;;=> (1 . 2)

;; cons의 구현과 상관없이, 순서를 강제하려면 cons에서 left/right를 계산하는게 아닌,
;; 미리 left/right를 계산해버리면 된다.
(let* ((left  (begin (display "1") (newline) 1))
       (right (begin (display "2") (newline) 2)))
  (cons left right))
;;>> 1
;;>> 2
;;=> (1 . 2)

(let* ((right (begin (display "2") (newline) 2))
       (left  (begin (display "1") (newline) 1)))
  (cons left right))
;;>> 2
;;>> 1
;;=> (1 . 2)

;; list-of-values 를 다시 작성하면
;; before
'(define (list-of-values exps env)
   (if (no-operands? exps)
       '()
       (cons (eval (first-operand exps) env)
             (list-of-values (rest-operand exps) env))))

;; after
(define (list-of-values exps env)
  (if (no-operands? exps)
      '()
      (let* ((left (eval (first-operand exps) env))
             (right (list-of-values (rest-operands exps) env)))
        (cons left right))))
