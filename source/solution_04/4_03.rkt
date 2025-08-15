#lang sicp
;; file: 4_03.rkt

(#%require rackunit)
(#%require "../helper/my-util.rkt")
(#%require "../allcode/ch4-4.1.1-mceval.rkt")
(#%require "../allcode/ch3-3.3.3.rkt")

;; eval을 data-directed style 로 고쳐라
;; 그 후 Exercise 2.73 와 비교해보자
;;
;; 챕터 2.4.3에 data-directed style이 나온다.
;;
;; == basic style
;; (define (deriv exp var)
;;   (cond ((number? exp) ...)
;;         ((variable? exp)  ...)
;;         ((sum? exp) ...)
;;         ((product? exp) ...)
;;         (else  ...)
;;   ))
;; == data-directed style
;; (define (deriv exp var)
;;    (cond ((number? exp) ...)
;;          ((variable? exp)  ...)
;;          (else
;;            ((get 'deriv (operator exp)) (operands exp) var))
;;     ))
;;

;; eval에서 ***로 마크한 조건들이 data-directed style로 바뀌기 좋은 형태이다.
;;
;; (define (eval exp env)
;;   (cond ((self-evaluating? exp) ; 숫자? / 문자열?
;;         ((variable? exp)        ; symbol? 이면
;;     *** ((quoted? exp)          ; quote 로 시작
;;     *** ((assignment? exp)      ; set! 으로 시작
;;     *** ((definition? exp)      ; define 으로 시작
;;     *** ((if? exp)              ; if 로 시작
;;     *** ((lambda? exp)          ; lambda 로 시작
;;     *** ((begin? exp)           ; begin 으로 시작
;;     *** ((cond? exp)            ; cond 로 시작
;;         ((application? exp)     ; pair? 이면 함수 호출
;;         (else
;;   ))
;;
;;
;; (define (eval exp env)
;;   (cond ((self-evaluating? exp) ; 숫자? / 문자열?
;;         ((variable? exp)        ; symbol? 이면
;;     *** ((started-with-builtin-tag? exp)
;;     ***  ((get-tagged-func exp) exp env))
;;         ((application? exp)     ; pair? 이면 함수 호출
;;         (else
;;   ))
;;
;; 그리고 각 함수들에 대해 (tagged-func-name> exp env) 이런 식으로 정규화를 시켜줘야 한다.

(define (eval exp env)
  (cond ((self-evaluating? exp) exp)
        ((variable? exp) (lookup-variable-value exp env))
        ((started-with-builtin-tag? exp)
         ((get-tagged-func exp) exp env))   
        ((application? exp)
         (apply (eval (operator exp) env)
                (list-of-values (operands exp) env)))
        (else
         (error "Unknown expression type -- EVAL" exp))))

(define (started-with-builtin-tag? exp)
  (if (not (pair? exp))
      false
      (not (null? (get-tagged-func exp)))))

(define (get-tagged-func exp)
  (let ((tag (first exp)))
    (get tag 'built-in)))

(define (tagged-func-quote  exp env) (text-of-quotation exp))
(define (tagged-func-assign exp env) (eval-assignment exp env))
(define (tagged-func-define exp env) (eval-definition exp env))
(define (tagged-func-if     exp env) (eval-if exp env))
(define (tagged-func-lambda exp env) (make-procedure (lambda-parameters exp) (lambda-body exp) env))
(define (tagged-func-begin  exp env) (eval-sequence (begin-actions exp) env))
(define (tagged-func-cond   exp env) (eval (cond->if exp) env))

(put 'quote  'built-in tagged-func-quote)
(put 'assign 'built-in tagged-func-assign)
(put 'define 'built-in tagged-func-define)
(put 'if     'built-in tagged-func-if)
(put 'lambda 'built-in tagged-func-lambda)
(put 'begin  'built-in tagged-func-begin)
(put 'cond   'built-in tagged-func-cond)
