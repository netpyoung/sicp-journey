#lang sicp
;; file: 4_17.rkt
;; 4_06 cont
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix racket: racket))
(#%require (prefix trace: racket/trace))
(racket:require (racket:rename-in "../allcode/ch4-4.1.1-mceval.rkt"
                                  (_make-procedure origin/make-procedure)
                                  (_procedure-body origin/procedure-body)))
(racket:require (racket:prefix-in ex4_06/ "4_06.rkt"))
;; 본문에 나온 <e3>을 평가할때의 environment를 다이어그램으로 그려라
;;
;; 첫번째 방식
;; (lambda (x)
;;   (define u 1)    ; 실행 시, 현재 프레임에 u를 만들고 값 1 할당
;;   (define v 2)    ; 실행 시, 현재 프레임에 v를 만들고 값 2 할당
;;   (+ u v x))
;; 
;; Global Env
;;    |
;;    v
;; +----------------+
;; | proc           | --> [params: (x) body: ...] Env=Global
;; +----------------+
;;                      \
;;                       v
;;              +------------------+
;;              | Frame F1         |   (procedure call frame)
;;              +------------------+
;;              | x = ARG          |
;;              | u = 1            |
;;              | v = 2            |
;;              +------------------+
;;                   |
;;       e3: (+ u v x)  ; lookup all in F1

;;
;; 두번째 방식(변환된 방식)
;; (lambda (x)
;;   (let ((u '*unassigned*)
;;         (v '*unassigned*))
;;     (set! u 1)
;;     (set! v 2)
;;     (+ u v x)))
;; 
;; 
;; Global Env
;;    |
;;    v
;; +----------------+
;; | proc           | --> [params: (x) body: let ...] Env=Global
;; +----------------+
;;                      \
;;                       v
;;              +----------------+
;;              | Frame F1       |   (procedure call frame)
;;              +----------------+
;;              | x = ARG        |
;;              +----------------+
;;                   |
;;                   v
;;              +------------------+
;;              | Frame F2         |   (let frame)
;;              +------------------+
;;              | u = *unassigned* |
;;              | v = *unassigned* |
;;              +------------------+
;;       set! u 1
;;       set! v 2
;;       e3: (+ u v x)  ; u,v in F2, x in F1
;;

;;
;; 변환된 프로그램에서 왜 추가 프레임(extra frame)이 생기는가?
;; => let이 lambda로 변환되면서 frame이 생성

;; 왜 이 차이가 동작에 영향을 주지 않는가?
;; => 값을 참조하는 시점에는 이미 초기화 되어있음.

;; 추가 프레임을 만들지 않고, 내부 정의에 대해 "동시(simultaneous)" 스코프 규칙을 인터프리터가 구현하도록 하는 방법을 설계하라.
;; simultaneous 발음
;; 미국식 ˌsaɪ.məlˈteɪ.niəs / 사이멀테이니어스
;; 영국식 ˌsɪm.əlˈteɪ.ni.əs / 시멀테이니어스
;;
;; simultaneous 방식( 두번째와 비슷하지만 추가 프레임 생성 안함.)
;; (lambda (x)
;;   (define u '*unassigned*)
;;   (define v '*unassigned*)
;;   (set! u (+ v 1))
;;   (set! v 2)
;;   (+ u v x))
;; 
;; Global Env
;;    |
;;    v
;; +----------------+
;; | proc           | --> [params: (x) body: ...] Env=Global
;; +----------------+
;;                      \
;;                       v
;;              +------------------+
;;              | Frame F1         |   (procedure call frame)
;;              +------------------+
;;              | x = ARG          |
;;              | u = *unassigned* |
;;              | v = *unassigned* |
;;              +------------------+
;;                   |
;;       set! u 1
;;       set! v 2
;;       e3: (+ u v x)  ; lookup all in F1
;;

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

(define (scan-out-defines-simultaneous body)
  (let ((defs (filter definition? body)))
    (if (null? defs)
        body
        (let* ((vars (map definition-variable defs))
               (vals (map definition-value defs))
               (unassigns-defs (map (lambda (var) (list 'define var ''*unassigned*)) vars))
               (assigns (map (lambda (x y) (list 'set! x y)) vars vals))
               (body-without-defs (filter (complement definition?) body)))
          ;; 현재 프레임에 바인딩 추가만 하고 let은 안 씀
          (append
           unassigns-defs
           assigns
           body-without-defs)))))

(check-equal? (scan-out-defines-simultaneous (lambda-body '(lambda (x)
                                                             (define u (+ v 1))
                                                             (define v 2)
                                                             (+ u v x))))
              '((define u '*unassigned*)
                (define v '*unassigned*)
                (set! u (+ v 1))
                (set! v 2)
                (+ u v x)))

(define env2 (setup-environment))
(define-variable! '+ (list 'primitive +) env2)


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
                (scan-out-defines-simultaneous body))
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
                          '((define u '*unassigned*)
                            (define v '*unassigned*)
                            (set! u 1)
                            (set! v 2)
                            (+ u v x)))
            (check-equal? (eval '(hello 3) env2)
                          6)
            )
 (begin
   (override-make-procedure! origin/make-procedure)
   (override-procedure-body! origin/procedure-body)))