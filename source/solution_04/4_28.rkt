#lang sicp
;; file: 4_28.rkt

;;
;; 예전에는 그냥 eval했는데 왜 이젠 actual-value로 쓰는가?
;;
;; ch4-4.1.1-mceval
'(define (eval exp env)
   (cond (...
          ((application? exp)
           (apply (eval (operator exp) env)
                  (list-of-values (operands exp) env)))
          ...)))
'(define (list-of-values exps env)
   (if (no-operands? exps)
       '()
       (cons (eval (first-operand exps) env)
             (list-of-values (rest-operands exps) env))))

'(define (apply procedure arguments)
   (cond ((primitive-procedure? procedure)
          (apply-primitive-procedure procedure arguments))
         ((compound-procedure? procedure)
          (eval-sequence
           (procedure-body procedure)
           (extend-environment
            (procedure-parameters procedure)
            arguments
            (procedure-environment procedure))))
         (else
          (error
           "Unknown procedure type -- APPLY" procedure))))
;; (+ 1 2 3)
;; apply (eval + env) ((eval 1 env) (eval 2 env) (eval 3 env)) 이런 식
;; r5rs:apply + (1 2 3)

;; ch4-4.2.2-leval
'(define (eval exp env)
   (cond (...
          ((application? exp)             ; clause from book
           (apply (actual-value (operator exp) env)
                  (operands exp)
                  env))
          ...)))

'(define (actual-value exp env)
   (force-it (eval exp env)))

'(define (apply procedure arguments env)
   (cond ((primitive-procedure? procedure)
          (apply-primitive-procedure
           procedure
           (list-of-arg-values arguments env))) ; changed
         ((compound-procedure? procedure)
          (eval-sequence
           (procedure-body procedure)
           (extend-environment
            (procedure-parameters procedure)
            (list-of-delayed-args arguments env) ; changed
            (procedure-environment procedure))))
         (else
          (error
           "Unknown procedure type -- APPLY" procedure))))

'(define (list-of-arg-values exps env)
   (if (no-operands? exps)
       '()
       (cons (actual-value (first-operand exps) env)
             (list-of-arg-values (rest-operands exps)
                                 env))))

'(define (list-of-delayed-args exps env)
   (if (no-operands? exps)
       '()
       (cons (delay-it (first-operand exps) env)
             (list-of-delayed-args (rest-operands exps)
                                   env))))
;; (+ 1 2 3)
;; apply (actual-value + env) (1 2 3)
;; r5rs:apply (actual-value + env) ((actual-value 1 env) (actual-value 2 env) (actual-value 3 env))
