#lang sicp
;; file: 4_05.rkt

(#%require (prefix racket/ racket))
(#%require "../allcode/ch4-4.1.1-mceval.rkt")
(#%require rackunit)

;; expand-clauses의 (sequence->exp (cond-actions first)) 부분을 수정하면 된다.

(define first car)
(define rest cdr)
(define second cadr)
(define third caddr)

(define (cond->if exp)
  (expand-clauses (cond-clauses exp)))
 
(define (expand-clauses clauses)
  (if (null? clauses)
      'false                          ; no else clause
      (let ((first (car clauses))
            (rest (cdr clauses)))
        (if (cond-else-clause? first)
            (if (null? rest)
                (sequence->exp (cond-actions first))
                (error "ELSE clause isn't last -- COND->IF"
                       clauses))
            ;; Before:
            ;; (make-if (cond-predicate first)
            ;;             (sequence->exp (cond-actions first))
            ;;             (expand-clauses rest))
            ;; After:
            (if (=>sequence? first)
                (make-if (cond-predicate first)
                         (expend=>sequence first)
                         (expand-clauses rest))
                (make-if (cond-predicate first)
                         (sequence->exp (cond-actions first))
                         (expand-clauses rest)))))))


(define (=>sequence? clause)
  (eq? (second clause) '=>))

(define (expend=>sequence clause)
  (list (third clause) (first clause)))

(check-equal? (expend=>sequence '((assoc 'b '((a 1) (b 2))) => cadr))
              '(cadr (assoc 'b '((a 1) (b 2)))))

(check-equal? (cond->if '(cond ((assoc 'b '((a 1) (b 2))) => cadr)
                               (else false)))
              '(if (assoc 'b '((a 1) (b 2)))
                   (cadr (assoc 'b '((a 1) (b 2))))
                   false))



;;==== additional test
(check-equal? (cond->if '(cond ((= 1 1) true)
                               (else false)))
              '(if (= 1 1)
                   true
                   false))

(check-equal? (cond->if '(cond ((assoc 'b '((a 1) (b 2))) => cadr)
                               ((assoc 'b '((a 1) (b 2))) => cadr)))
              '(if (assoc 'b '((a 1) (b 2)))
                   (cadr (assoc 'b '((a 1) (b 2))))
                   (if (assoc 'b '((a 1) (b 2)))
                       (cadr (assoc 'b '((a 1) (b 2))))
                       false)))



;; eval test -----------------------

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
        ((application? exp)
         (apply (eval (operator exp) env)
                (list-of-values (operands exp) env)))
        (else
         (error "Unknown expression type -- EVAL" exp))))


(define env2 (setup-environment))
(define-variable! '+ (list 'primitive +) env2)
(define-variable! 'assoc (list 'primitive assoc) env2)
(define-variable! 'cadr (list 'primitive cadr) env2)

(check-equal? (eval '(cond ((assoc 'b '((a 1) (b 2))) => cadr)
                           (else false)) env2)
              2)