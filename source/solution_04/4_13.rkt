#lang sicp
;; file: 4_13.rkt
;; 4_12

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix racket: racket))
(racket:require "../allcode/ch4-4.1.1-mceval.rkt")

;; scheme에서 define해서 정의한 변수를 지울 수 없음.
;;
;; 1-1. make-unbound! 함수를 만들어 env에서 지울 수 있도록 만들자.
;;
;; 1-2. first-frame에서만 지우면 되는가?
;;
;; - 현재 스코프(첫 프레임)내에서 선언 삭제가 됨으로, 직관적.
;; - 첫 번째 프레임만 뒤지면 되니 탐색이 빠르고 코드가 단순함.
;; - 상위 프레임에 중복된 이름은 살아있음.
;;
;; 앞선 define-variable!도 현재 스코프(첫 프레임)에서만 선언하고 있음.
;;
;; 초판 1985년: SICP
;; 초판 1991년: EOPL Essentials of Programming Languages by Daniel P. Friedman, Mitchell Wand, and Christopher T. Haynes.
;; 초판 1996년: PLP Programming Language Pragmatics by Michael L Scott - https://www.cs.rochester.edu/~scott/pragmatics/
;; 초판 2002년: TaPL Types and Programming Languages by Benjamin C. Pierce - https://www.cis.upenn.edu/~bcpierce/tapl/index.html
;;  etc. https://softwarefoundations.cis.upenn.edu/


(define (lookup-variable-vars-vals var env)
  ;; 함수 모양이 맘에 안들지만, 일단 기존 코드 모양의 수정을 최소화하겠다.
  ;; values도 있으나, 그냥 list로 감싸겠다. - https://docs.racket-lang.org/reference/values.html
  (define (env-loop env)
    (define (scan vars vals)
      (cond ((null? vars)
             (env-loop (enclosing-environment env)))
            ((eq? var (car vars))
             (list vars vals))   ; <<------------ 찾으면 (vars vals)를 반환한다.
            (else (scan (cdr vars) (cdr vals)))))
    (if (eq? env the-empty-environment)
        (list nil nil)          ; <<------------ 못찾으면 (nil nil)을 반환한다.
        (let ((frame (first-frame env)))
          (scan (frame-variables frame)
                (frame-values frame)))))
  (env-loop env))

(define (make-unbound! env var is-toplevel-only)
  (define (which-env env is-toplevel-only)
    (if (not is-toplevel-only)
        env
        (let* ((frame (first-frame env))
               (search-env (extend-environment (frame-variables frame) (frame-values frame) the-empty-environment)))
          search-env)))
  (let* ((frame (first-frame env))
         (search-env (which-env env is-toplevel-only))
         (vars-vals (lookup-variable-vars-vals var search-env))
         (vars (first vars-vals))
         (vals (second vars-vals)))
    (if (null? vals)
        nil
        (begin
          (let ((rst (rest vars)))
            (set-car! vars (first rst))
            (set-cdr! vars (rest rst)))
          (let ((rst (rest vals)))
            (set-car! vals (first rst))
            (set-cdr! vals (rest rst)))))))

#;(define env1 (setup-environment))

#;(let ((frame (first-frame env1)))
    frame)
;; testing =======================================
(define env1 (setup-environment))
(check-equal? (lookup-variable-value 'car env1)
              (list 'primitive car))
(check-exn #rx"Unbound variable x"
           (lambda () (lookup-variable-value 'x env1)))
(check-exn #rx"Unbound variable -- SET! x"
           (lambda () (set-variable-value! 'x 1 env1)))
(define-variable! 'x 5 env1)
(check-equal? (lookup-variable-value 'x env1)
              5)
(set-variable-value! 'x 1 env1)
(check-equal? (lookup-variable-value 'x env1)
              1)
(make-unbound! env1 'x #t)
(check-exn #rx"Unbound variable x"
           (lambda () (lookup-variable-value 'x env1)))

(check-equal? env1 (setup-environment))
