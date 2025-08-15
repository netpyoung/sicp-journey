#lang sicp
;; file: 4_16.rkt
;; 4_06 / 4_18 cont

(#%require rackunit)
(#%require "../helper/my-util.rkt")
(#%require (prefix racket: racket))
(#%require (prefix trace: racket/trace))

(racket:require (racket:rename-in "../allcode/ch4-4.1.1-mceval.rkt"
                                  (_lookup-variable-value origin/lookup-variable-value)
                                  (_make-procedure origin/make-procedure)
                                  (_procedure-body origin/procedure-body)))
(racket:provide
 lookup-variable-value
 scan-out-defines)
;;
;; 1. lookup-variable-value 함수를 고쳐서 변수의 값이 심볼 *unassigned* 면 오류를 내도록 한다.
;;

(define (lookup-variable-value var env)
  (define (env-loop env)
    (define (scan vars vals)
      (cond ((null? vars)
             (env-loop (enclosing-environment env)))
            ((eq? var (car vars))
             ;; - before
             ;; (car vals)
             ;;
             ;; - after
             (let ((found (car vals)))
               (if (eq? found '*unassigned*)
                   (error "Unssigned variable" var)
                   found)))
            (else (scan (cdr vars) (cdr vals)))))
    (if (eq? env the-empty-environment)
        (error "Unbound variable" var)
        (let ((frame (first-frame env)))
          (scan (frame-variables frame)
                (frame-values frame)))))
  (env-loop env))

(override-lookup-variable-value! lookup-variable-value)


(define env1 (setup-environment))
(check-exn #rx"Unbound variable x"
           (lambda () (lookup-variable-value 'x env1)))
(check-equal? (eval '(define x '*unassigned*) env1)
              'ok)
(check-exn #rx"Unssigned variable x"
           (lambda () (lookup-variable-value 'x env1)))

;;
;; 2. procedure body를 받아(lambda로 시작하는) 앞에 본것처럼 내부에 define이 없도록 변환과정을 거쳐 반환하는 scan-out-defines를 작성해라.
;;
;; - before
;; (lambda <vars>
;;  (define u <e1>)
;;  (define v <e2>)
;;  <e3>)
;;
;; - after
;; (lambda <vars>
;;  (let ((u '*unassigned*)
;;        (v '*unassigned*))
;;    (set! u <e1>)
;;    (set! v <e2>)
;;    <e3>)))
(define (filter predicate sequence)
  (cond ((null? sequence) nil)
        ((predicate (car sequence))
         (cons (car sequence)
               (filter predicate 
                       (cdr sequence))))
        (else  (filter predicate 
                       (cdr sequence)))))

(define (complement f)
  (lambda (x)
    (not (f x))))

(define (make-let bindings body)
  ;; (make-let '((a 1)) '((+ a 2)))
  ;; => (let ((a 1)) (+ a 2))
  (append (list 'let bindings) body))

(define (scan-out-defines body)
  (let ((defs (filter definition? body)))
    (if (null? defs)
        body
        (let* ((body-without-defs (filter (complement definition?) body))
               (vars (map definition-variable defs))
               (vals (map definition-value defs))
               (bindings (map (lambda (x) (list x ''*unassigned*)) vars))
               (assigns (map (lambda (x y) (list 'set! x y)) vars vals)))
          (list (make-let bindings
                          (append assigns body-without-defs)))))))


(check-equal? (scan-out-defines (lambda-body '(lambda (x)
                                                (define u 1)
                                                (define v 2)
                                                (+ u v x))))
              '((let ((u '*unassigned*)
                      (v '*unassigned*))
                  (set! u 1)
                  (set! v 2)
                  (+ u v x))))

;;
;; 3. scan-out-defines 을 인터프리터안에 넣는데,
;;    - make-procedure 쪽이 좋을까 procedure-body 쪽이 좋을까?
;;       make-procedure 쪽
;;    - 그리고 그 이유는?
;;       eval타임인가 apply타임인가 문제인데,
;;      인터프리터 구현체가 eval타임에서 구문을 확장하고 apply를 돌며 실제 scheme쪽 apply를 호출.
;;      eval타임에서 구문을 확장해 나갈때 같이 확장해 놓는게 좋다.

;; === make-procedure
;; (define (make-procedure parameters body env)
;;   (list 'procedure parameters body env))
;; 
;; (define (eval exp env)
;;   (cond (
;;          ...
;;          ((lambda? exp)
;;           (make-procedure (lambda-parameters exp) ; <-----------------------
;;                           (lambda-body exp)
;;                           env))
;;          ...
;;          )))
;; 
;; === procedure-body
;; (define (procedure-body p) (caddr p)) ;; third
;; 
;; (define (apply procedure arguments)
;;    (cond ((primitive-procedure? procedure)
;;          (apply-primitive-procedure procedure arguments))
;;         ((compound-procedure? procedure)
;;          (eval-sequence
;;           (procedure-body procedure) ; <-----------------------
;;           (extend-environment
;;            (procedure-parameters procedure)
;;            arguments
;;            (procedure-environment procedure))))
;;         (else
;;          (error
;;           "Unknown procedure type -- APPLY" procedure))))

;; 수정한다면,
(racket:require (racket:prefix-in ex4_06/ "4_06.rkt"))
(define third caddr)
(define env2 (setup-environment))
(define env3 (setup-environment))
(define-variable! '+ (list 'primitive +) env2)
(define-variable! '+ (list 'primitive +) env3)

(around
 (begin
   (define (make-procedure parameters body env)
     ;; 4_06에서 ((let? exp) (eval (let->combination exp) env)) 을
     ;; 추가 했다면.
     ;; (list 'procedure parameters (scan-out-defines body) env)
     ;;
     ;; 추가하지 않았다면,
     (list 'procedure parameters
           (map (lambda (x)
                  (if (ex4_06/let? x)
                      (ex4_06/let->combination x)
                      x))
                (scan-out-defines body))
           env))
   (override-make-procedure! make-procedure)
   (override-procedure-body! origin/procedure-body))
  
 
 (test-case "make-procedure"
            (check-equal? (eval '(define (hello x)
                                   (define u 1)
                                   (define v 2)
                                   (+ u v x))
                                env2)
                          'ok)

            ;; hello body의 define이 lambda로 풀어진 상태로 저장되어 있다.
            (check-equal? (third (lookup-variable-value 'hello env2))
                          '(((lambda (u v)
                               (set! u 1)
                               (set! v 2)
                               (+ u v x))
                             '*unassigned*
                             '*unassigned*)))
            (check-equal? (eval '(hello 3) env2)
                          6)
            )
 (begin
   (override-make-procedure! origin/make-procedure)
   (override-procedure-body! origin/procedure-body)))

(around
 (begin
   (define (procedure-body p)
     (scan-out-defines (third p)))
   (override-make-procedure! origin/make-procedure)
   (override-procedure-body! procedure-body))
 
 (test-case "procedure-body"
            (check-equal? (eval '(define (hello x)
                                   (define u 1)
                                   (define v 2)
                                   (+ u v x))
                                env3)
                          'ok)

            ;; hello body의 define이 lambda로 풀어지지 않은 상태로 저장되어 있다.
            (check-equal? (third (lookup-variable-value 'hello env3))
                          '((define u 1)
                            (define v 2)
                            (+ u v x)))
            
            ;; application평가시에 scan-out-defines이 일어남
            (check-equal? (eval '(hello 3) env3)
                          6)
            )
 (begin
   (override-make-procedure! origin/make-procedure)
   (override-procedure-body! origin/procedure-body)))


(override-lookup-variable-value! origin/lookup-variable-value)
