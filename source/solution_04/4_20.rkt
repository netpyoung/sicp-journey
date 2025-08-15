#lang sicp
;; file: 4_20.rkt
;; 4_17 / 4_18 / 4_21

(#%require rackunit)
(#%require "../helper/my-util.rkt")
(#%require (prefix racket: racket))
(racket:require (racket:rename-in "../allcode/ch4-4.1.1-mceval.rkt" (_eval origin/eval)))


;; | 구문       | 바인딩 생성 방식                  | 앞 변수 참조 | 상호/자기 참조 |
;; | -------- | ----------------------------------- | ------------ | -------------- |
;; | `let`    | 모든 값 먼저 계산 후 한 번에 바인딩 | ❌          | ❌            |
;; | `let*`   | 순차적으로 바인딩 생성              | ⭕          | ❌            |
;; | `letrec` | 이름만 먼저 바인딩 후 값 설정       | ⭕          | ⭕            |

;; letrec: let recursive

;;
;; a. letrec을 derived expression로 처리. 연습문제 4.18 처럼 변수는 let으로 생성, set!으로 설정하라.
;;
(#%require (only "4_06.rkt" let? let->combination))
(#%require (only "4_07.rkt" make-let ))

(define (letrec->let expr)
  (let* ((bindings (second expr))
         (body (rest (rest expr)))
         (vars (map first bindings))
         (new-bindings (map (lambda (x) (list x ''*unassigned*)) vars))
         (vals (map second bindings))
         (setter (map (lambda (x y) (list 'set! x y)) vars vals)))
    (make-let new-bindings (append setter body))))

(check-equal? (letrec->let
               '(letrec ((x 1))
                  (+ x 2)))
              '(let ((x '*unassigned*))
                 (set! x 1)
                 (+ x 2)))

(check-equal? (letrec->let
               '(letrec ((fact
                          (lambda (n)
                            (if (= n 1)
                                1
                                (* n (fact (- n 1)))))))
                  (fact 10)))
              '(let ((fact '*unassigned*))
                 (set! fact
                       (lambda (n)
                         (if (= n 1)
                             1
                             (* n (fact (- n 1))))))
                 (fact 10)))

(define (letrec? exp) (tagged-list? exp 'letrec))

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
        ((let? exp) (eval (let->combination exp) env))
        ((letrec? exp) (eval (letrec->let exp) env)) ;; <<--- 추가.
        ((application? exp)
         (apply (eval (operator exp) env)
                (list-of-values (operands exp) env)))
        (else
         (error "Unknown expression type -- EVAL" exp))))

(override-eval! eval)
(define env2 (setup-environment))
(define-variable! '+ (list 'primitive +) env2)
(define-variable! '- (list 'primitive -) env2)
(define-variable! '* (list 'primitive *) env2)
(define-variable! '= (list 'primitive =) env2)

(check-equal? (eval '(letrec ((x 1))
                       (+ x 2))
                    env2)
              3)

(check-eq? (eval '(letrec ((fact
                            (lambda (n)
                              (if (= n 1)
                                  1
                                  (* n (fact (- n 1)))))))
                    (fact 10))
                 env2)
           3628800)

(check-eq? (letrec ((fact
                     (lambda (n)
                       (if (= n 1)
                           1
                           (* n (fact (- n 1)))))))
             (fact 10))
           3628800)
;; 
;; b. (f 5)를 평가하는 동안 <rest of body of f>가 평가되는 환경(environment)을 나타내는
;; letrec버전 let버전에 대한  environment diagram을 그려라.
;; (odd?/even?은 이미 정의되어 있어, 오류를 확인하기 위해 odd?/even?을 new-odd?/new-even?으로 변경.)

;; let 버전
(define expr-v-let
  '(define (f x)
     ;; (f 5)
     ;; f 호출 환경 (x = 5)
     ;; ┌─────────────────────────────┐
     ;; │ f-frame                     │
     ;; │ x → 5                       │
     ;; └─────────────────────────────┘
     ;; 
     ;; let-frame
     ;; ┌─────────────────────────────┐
     ;; │ new-even? → <lambda>        │ << lambda를 정의시 new-odd?를 찾아보는데 정의가 되지않아 오류가 나타난다.
     ;; │ new-odd?                    |
     ;; └─────────────────────────────┘
     (let ((new-even?
            (lambda (n)
              (if (= n 0)
                  true
                  (new-odd? (- n 1))))) ; new-odd?: unbound identifier in: new-odd?
           (new-odd?
            (lambda (n)
              (if (= n 0)
                  false
                  (new-even? (- n 1))))))
       "<rest of body of f>"
       (new-even? x))))
(define env3 (setup-environment))
(define-variable! '+ (list 'primitive +) env3)
(define-variable! '- (list 'primitive -) env3)
(define-variable! '* (list 'primitive *) env3)
(define-variable! '= (list 'primitive =) env3)
(check-equal? (eval expr-v-let
                    env3)
              'ok)
(check-exn #rx"Unbound variable new-odd?"
           (lambda ()
             (eval '(f 5) env3)))


;; letrec 버전
(define expr-v-letrec
  '(define (f x)
     ;; (f 5)
     ;; f 호출 환경 (x = 5)
     ;; ┌─────────────────────────────┐
     ;; │ f-frame                      │
     ;; │ x → 5                        │
     ;; └─────────────────────────────┘
     ;; 
     ;; letrec-frame
     ;; ┌─────────────────────────────┐
     ;; │ new-even? → <unassigned>    │
     ;; │ new-odd?  → <unassigned>    │
     ;; └─────────────────────────────┘
     ;; set! new-even? <lambda>
     ;; set! new-odd?  <lambda>
     (letrec ((new-even?
               (lambda (n)
                 (if (= n 0)
                     true
                     (new-odd? (- n 1)))))
              (new-odd?
               (lambda (n)
                 (if (= n 0)
                     false
                     (new-even? (- n 1))))))
       "<rest of body of f>"
       (new-even? x))))

(define env4 (setup-environment))
(define-variable! '+ (list 'primitive +) env4)
(define-variable! '- (list 'primitive -) env4)
(define-variable! '* (list 'primitive *) env4)
(define-variable! '= (list 'primitive =) env4)
(check-equal? (eval expr-v-letrec
                    env4)
              'ok)
(check-eq? (eval '(f 5) env4)
           false)


(override-eval! origin/eval)
