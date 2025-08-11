#lang sicp

#;(#%require errortrace)
;; file: 4_08.rkt
;; 4_06 cont


;; 기존 let->combination
;; 
;; (let ((a 1) (b 2)) (+ a b)) => ((lambda (a b) (+ a b)) 1 2)
;;
;; (let <var> <bindings> <body>) 형태를 지원할 수 있도록 수정하해야함.
;;
;; 간단한 named-let expression이 다음과 같다고 하면,
;;
;; (let hello ((a 1) (b 2))
;;   (+ a b))
;;
;; a) lambda와 define사용.
;; ((lambda ()
;;    (define (hello a b)
;;      (+ a b))
;;    (hello 1 2)))
;;
(#%require (prefix racket/ racket))
(#%require (rename "4_06.rkt" let->combination-normal let->combination))
(#%require rackunit)
(racket/provide
 make-define
 let->combination)
(define first car)
(define rest cdr)
(define second cadr)
(define third caddr)

(define (make-define func-name args body)
  (append (list 'define (append (list func-name) args)) body))

(check-equal? (make-define 'hello '(a b) '(1 2 3 4 5))
              '(define (hello a b) 1 2 3 4 5))

(define (let-named->combination let-clause)
  (let* ((bindings (third let-clause))
         (func-name (second let-clause))
         (vars (map first bindings))
         (exps (map second bindings))
         (body (rest (rest (rest let-clause)))))
    (list (make-lambda '()
                       (list (make-define func-name vars body)
                             (append (list func-name) exps))))))
    

(define (let->combination let-clause)
  (if (symbol? (second let-clause))
      (let-named->combination let-clause)      
      (let->combination-normal let-clause)))


(check-equal? (let->combination '(let ((a 1) (b 2)) (+ a b)))
              '((lambda (a b) (+ a b)) 1 2))

(check-equal? (let->combination '(let hello ((a 1) (b 2))
                                   (+ a b)))
              '((lambda ()
                  (define (hello a b)
                    (+ a b))
                  (hello 1 2))))

;; eval이 let구문을 처리할 수 있도록 수정 ---------------
(#%require "../allcode/ch4-4.1.1-mceval.rkt")

(define (let? exp) (tagged-list? exp 'let))
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
        ((let? exp) (eval (let->combination exp) env)) ;; <<--- 추가.
        ((application? exp)
         (apply (eval (operator exp) env)
                (list-of-values (operands exp) env)))
        (else
         (error "Unknown expression type -- EVAL" exp))))
(override-eval! eval)

(define env2 (setup-environment))
(define-variable! '+ (list 'primitive +) env2)
(define-variable! '- (list 'primitive -) env2)
(define-variable! '= (list 'primitive =) env2)

(check-equal? (eval '(let hello ((a 1) (b 2))
                       (+ a b))
                    env2)
              3)

(check-equal? (eval '(define (fib n)
                       (let fib-iter ((a 1)
                                      (b 0)
                                      (count n))
                         (if (= count 0)
                             b
                             (fib-iter (+ a b) 
                                       a 
                                       (- count 1)))))
                    env2)
              'ok)
(check-equal? (eval '(fib 10) env2) 55)