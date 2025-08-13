#lang sicp
;; file: 4_12.rkt
;; 4_13

;; 주어진 함수들의 공통된 점을 묶어 추상화하고, 그 추상화를 이용하여 다시 정의하라.
;;
;; - define-variable!
;; - set-variable-value!
;; - lookup-variable-value 
;;
;; 3함수 모두 env를 돌며, variable의 찾음 여부에 따라 다른 동작들을 수행한다.
;; 종료조건은 var를 찾거나, env(frame list)를 모두 순회한 경우이다.
;; (단 define-variable!인 경우 첫번째 frame만 검사함. env(frame list)를 전부 순회하지 않음.
;;
;; 기타. env 는 [frame1 frame2 ..] 이다.

(#%require rackunit)
(#%require threading)
(#%require (prefix racket/ racket))

(racket/require (racket/rename-in "../allcode/ch4-4.1.1-mceval.rkt"
                                  (define-variable! origin/define-variable!)
                                  (set-variable-value! origin/set-variable-value!)
                                  (lookup-variable-value origin/lookup-variable-value)))
(racket/provide
 lookup-variable-values)
;; =======================================
(define first car)

(define (lookup-variable-values var env)
  ;; 함수 모양이 맘에 안들지만, 일단 기존 코드 모양의 수정을 최소화하겠다.
  (define (env-loop env)
    (define (scan vars vals)
      (cond ((null? vars)
             (env-loop (enclosing-environment env)))
            ((eq? var (car vars))
             vals)   ; <<------------ 찾으면 vals를 반환한다.
            (else (scan (cdr vars) (cdr vals)))))
    (if (eq? env the-empty-environment)
        nil          ; <<------------ 못찾으면 nil을 반환한다.
        (let ((frame (first-frame env)))
          (scan (frame-variables frame)
                (frame-values frame)))))
  (env-loop env))


(define (lookup-variable-value var env)
  (let ((vals (lookup-variable-values var env)))
    (if (null? vals)
        (error "Unbound variable" var)
        (first vals))))

(define (set-variable-value! var val env)
  (let ((vals (lookup-variable-values var env)))
    (if (null? vals)
        (error "Unbound variable -- SET!" var)
        (set-car! vals val))))

(define (define-variable! var val env)
  (let* ((frame (first-frame env))
         (toplevel-env (extend-environment (frame-variables frame) (frame-values frame) the-empty-environment))
         (vals (lookup-variable-values var toplevel-env)))
    (if (null? vals)
        (add-binding-to-frame! var val frame)
        (set-car! vals val))))

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