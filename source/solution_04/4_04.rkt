#lang sicp
;; file: 4_04.rkt

(#%require (prefix racket/ racket))
(#%require "../allcode/ch4-4.1.1-mceval.rkt")
(#%require rackunit)

;; Install and and or as new special forms
;;
(define first car)
(define rest cdr)

(define (eval exp env)
  (cond ((self-evaluating? exp) exp)
        ((variable? exp) (lookup-variable-value exp env))
        ((quoted? exp) (text-of-quotation exp))
        ((assignment? exp) (eval-assignment exp env))
        ((definition? exp) (eval-definition exp env))
        ((if? exp) (eval-if exp env))
        ((lambda? exp)
         (make-procedure (lambda-parameters exp)
                         (lambda-body exp)
                         env))
        ((begin? exp) 
         (eval-sequence (begin-actions exp) env))
        ((cond? exp) (eval (cond->if exp) env))

        ;; 여기에 and/or 를 넣어주자.
        ((and? exp) (builtin-and exp env))
        ((or?  exp) (builtin-or  exp env))
        
        ((application? exp)
         (apply (eval (operator exp) env)
                (list-of-values (operands exp) env)))
        (else
         (error "Unknown expression type -- EVAL" exp))))

(define (and? exp) (tagged-list? exp 'and))
(define (or?  exp) (tagged-list? exp 'or))

(define (builtin-and exp env)
  (define (iter env fst rst)
    (if (false? (lookup-variable-value fst env))
        false
        (if (null? rst)
            true
            (iter env (first rst) (rest rst)))))
  (let ((args (rest exp))) ; '(and 1 2 3) => '(1 2 3)
    (iter env (first args) (rest args))))

(define (builtin-or  exp env)
  (define (iter env fst rst)
    (if (true? (lookup-variable-value fst env))
        true
        (if (null? rst)
            false
            (iter env (first rst) (rest rst)))))
  (let ((args (rest exp))) ; '(or 1 2 3) => '(1 2 3)
    (iter env (first args) (rest args))))


(check-eq? (eval '(and true true true) (setup-environment)) true)
(check-eq? (eval '(and false true true) (setup-environment)) false)
(check-eq? (eval '(and true false true) (setup-environment)) false)
(check-eq? (eval '(and true true false) (setup-environment)) false)

(check-eq? (eval '(or false false false) (setup-environment)) false)
(check-eq? (eval '(or true false false) (setup-environment)) true)
(check-eq? (eval '(or false true false) (setup-environment)) true)
(check-eq? (eval '(or false false true) (setup-environment)) true)

(define env1 (setup-environment))
(define-variable! 'a true env1)
(check-eq? (eval '(or false false a) env1) true)

;; Derived expressions.
;; 4.1.2Representing Expressions
;;  - Derived expressions
;; (cond ((> x 0) x)
;;       ((= x 0) (display 'zero) 0)
;;       (else (- x)))
;;
;; (if (> x 0)
;;     x
;;     (if (= x 0)
;;         (begin (display 'zero) 0)
;;         (- x)))
;;
;; - cond는 if로 변환하여 계산됨
;;   -cond는 if로부터 파생된(derived) 표현식임)
;;
;; and / or 역시 if 로 변환하여 계산할 수 있음.
;(set! eval 1)


(define (expand-and clauses)
  (if (null? clauses)
      'true
      (let ((fst (car clauses))
            (rst (cdr clauses)))
        (make-if fst
                 (expand-and rst)
                 'false))))

(define (expand-or clauses)
  (if (null? clauses)
      'false
      (let ((fst (car clauses))
            (rst (cdr clauses)))
        (make-if fst
                 'true
                 (expand-or rst)))))

(define (builtin-and-derived exp env) (eval (expand-and (rest exp)) env))
(define (builtin-or-derived  exp env) (eval (expand-or  (rest exp)) env))

(set! builtin-and builtin-and-derived)
(set! builtin-or  builtin-or-derived)

(check-equal? (expand-and '(1 2 3)) '(if 1 (if 2 (if 3 true false) false) false))
(check-equal? (expand-or  '(1 2 3)) '(if 1 true (if 2 true (if 3 true false))))

(check-eq? (eval '(and true true true) (setup-environment)) true)
(check-eq? (eval '(and false true true) (setup-environment)) false)
(check-eq? (eval '(and true false true) (setup-environment)) false)
(check-eq? (eval '(and true true false) (setup-environment)) false)

(check-eq? (eval '(or false false false) (setup-environment)) false)
(check-eq? (eval '(or true false false) (setup-environment)) true)
(check-eq? (eval '(or false true false) (setup-environment)) true)
(check-eq? (eval '(or false false true) (setup-environment)) true)

(define env2 (setup-environment))
(define-variable! 'a true env2)
(check-eq? (eval '(or false false a) env2) true)