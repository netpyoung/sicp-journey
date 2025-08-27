#lang sicp
;; file: 5_09.rkt

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix racket: racket))
(#%require threading)

#|
machine operation을 다룰때 (constant / register 뿐만 아니라) label에도 다룰 수 있도록 되었는데,
expression을 처리하는 프로시져를 수정하여  constant / register 에만 사용 가능하도록 조건을 강제해라.
|#

(racket:require (racket:rename-in "../allcode/ch5-regsim.rkt"
                                  (_make-operation-exp origin-make-operation-exp)))

(define (is-operation-operand-exp? exp)
  (cond ((constant-exp? exp)
         true)
        ((register-exp? exp)
         true)
        ((label-exp? exp)
         false)
        (else
         false)))

(define (make-operation-exp exp machine labels operations)
  (let ((op (lookup-prim (operation-exp-op exp) operations))
        (aprocs
         (map (lambda (e)
                ;; before
                ;; (make-primitive-exp e machine labels)
                ;;
                ;; after
                (if (not (is-operation-operand-exp? e))
                    (error "is not operation operand exp:" e)
                    (make-primitive-exp e machine labels))
                )
              (operation-exp-operands exp))))
    (lambda ()
      (apply op (map (lambda (p) (p)) aprocs)))))

(override-make-operation-exp! make-operation-exp)


(check-exn
 #rx"is not operation operand exp: \\(label hello\\)"
 (lambda ()
  
   (make-machine
    '(a b c x)
    (list (list '+ +))
    '(
      hello
     
      (assign x (const 1))
     
      (assign a (op +) (reg x) (reg x))
      (assign b (op +) (const 1) (const 2))
      (assign c (op +) (label hello) (label hello))
     
      ))
   ))