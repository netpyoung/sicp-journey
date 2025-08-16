#lang sicp
;; file: 4_10.rkt

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (all-except "../allcode/ch4-4.1.1-mceval.rkt" eval))

;; 기존 eval과 apply 코드는 그대로 두고 Scheme의 새로운 문법(syntax) 을 설계하고 구현하라.
;; define의 문법을 clojure 처럼 def / defn으로 변경.
;; -- scheme
;; (define x 10)
;; (define (foo a b c)
;;   (* a b c))
;;
;; -- clojure
;; (def x 10)
;; (defn foo [a b c]
;;   (* a b c))


(define (definition? exp)
  (or 
   (tagged-list? exp 'def)
   (tagged-list? exp 'defn)))

(define (definition-variable exp)
  (if (symbol? (cadr exp))
      (cadr exp)
      (caadr exp)))

(check-equal? (definition-variable '(define (foo a b c)
                                      (* a b c)))
              'foo)

(define (definition-variable2 exp)
  (if (tagged-list? exp 'def)
      (second exp)
      (second exp)))

(check-equal? (definition-variable '(defn foo [a b c]
                                      (* a b c)))
              'foo)

(define (definition-value exp)
  (if (symbol? (cadr exp))
      (caddr exp)
      (make-lambda (cdadr exp)
                   (cddr exp))))

(check-equal? (definition-value '(define (foo a b c)
                                   (* a b c)))
              '(lambda (a b c) (* a b c)))

(define (definition-value2 exp)
  (if (tagged-list? exp 'def)
      (caddr exp)
      (make-lambda (third exp)
                   (rest (rest (rest exp))))))

(check-equal? (definition-value2 '(defn foo [a b c]
                                    (* a b c)))
              '(lambda (a b c) (* a b c)))

(define (eval-definition exp env)
  (define-variable! (definition-variable2 exp)
    (eval (definition-value2 exp) env)
    env)
  'ok)

;; racket모듈 특성상 동일한 코드를 다시 override할 필요가 있음.
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
(override-eval! eval)



(define env2 (setup-environment))
(define-variable! '* (list 'primitive *) env2)
(check-equal? (eval '(defn foo [a b c]
                       (* a b c))
                    env2)
              'ok)
(check-equal? (eval '(foo 2 3 4) env2)
              24)

(check-equal? (eval '(def x 10) env2)
              'ok)

(check-equal? (eval 'x env2)
              10)