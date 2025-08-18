#lang sicp
;; file: 4_30.rkt
;; 4_31

(#%require rackunit)
(#%require threading)
(#%require profile)
(#%require (prefix racket: racket))
(racket:require (racket:rename-in "../allcode/ch4-4.2.2-leval.rkt"
                                  (_eval-sequence lazy:eval-sequence)))

;;  Cy D. Fect (aka sideeffect)는 사이드 이펙트가 생길까 염려.
;; 그래서 eval-sequence시 마지막을 제외하고 강제로 actual-value로 값을 얻어와야 한다고 주장함.
(define (eval-sequence-cy exps env)
  (cond ((last-exp? exps)
         (eval (first-exp exps) env))
        (else
         ;; 기존
         ;; (eval (first-exp exps) env)
         ;;
         ;; 변경 eval을 actual-value로 변경
         (actual-value (first-exp exps) env)
         (eval-sequence-cy (rest-exps exps) env))))

;; 
;; a. for-each예를 들며, Ben Bitdiddle는 Cy가 틀렸다고 생각함. 원래 lazy:eval-sequence 이 맞다고 생각.
;; c. for-each예를 들며, Cy는 자신의 eval-sequence-cy도 잘 돌아간다고 주장.
(define expr-foreach '(define (for-each proc items)
                        (if (null? items)
                            'done
                            (begin (proc (car items))
                                   (for-each proc (cdr items))))))
(define expr-run-foreach '(for-each
                           (lambda (x) (newline) (display x))
                           (list 57 321 88)))

(test-case
 "a. Ben Bitdiddle의 주장 lazy:eval-sequence "
 
 (override-eval-sequence! lazy:eval-sequence)
 (define env1 (setup-environment))
 
 (~> expr-foreach
     (actual-value env1)
     (check-equal? 'ok))

 (let ([output (racket:with-output-to-string (lambda () (actual-value expr-run-foreach env1)))])
   (check-equal? output "\n57\n321\n88")))

(test-case
 "c. Cy D. Fect 의 주장 eval-sequence-cy "
 (override-eval-sequence!  eval-sequence-cy)
 (define env1 (setup-environment))
 
 (~> expr-foreach
     (actual-value env1)
     (check-equal? 'ok))

 (let ([output (racket:with-output-to-string (lambda () (actual-value expr-run-foreach env1)))])
   (check-equal? output "\n57\n321\n88")))

;;
;; b. 좀 더 복잡한 (p1 1) / (p2 1)의 실행 결과 비교.
(define expr-p1 '(define (p1 x)
                   (set! x (cons x '(2)))
                   x))

(define expr-p2 '(define (p2 x)
                   (define (p e)
                     e
                     x)
                   (p (set! x (cons x '(2))))))
(test-case
 "고치지 않으면? ( Ben Bitdiddle의 주장 lazy:eval-sequence )"
 (override-eval-sequence! lazy:eval-sequence)
 (define env1 (setup-environment))
 (~> expr-p1
     (actual-value env1)
     (check-equal? 'ok))
 (~> expr-p2
     (actual-value env1)
     (check-equal? 'ok))
 (~> '(p1 1)
     (actual-value env1)
     (check-equal? '(1 2)))
 ;; x가 set!되기전에 값을 유지하고있어서, set!이 된 값이 아닌 1이 반환됨.
 (~> '(p2 1)
     (actual-value env1)
     (check-equal? 1)))

(test-case
 "고치면? ( Cy D. Fect 의 주장 eval-sequence-cy )"
 (override-eval-sequence! eval-sequence-cy)
 (define env2 (setup-environment))
 (~> expr-p1
     (actual-value env2)
     (check-equal? 'ok))
 (~> expr-p2
     (actual-value env2)
     (check-equal? 'ok))
 (~> '(p1 1)
     (actual-value env2)
     (check-equal? '(1 2)))
 (~> '(p2 1)
     (actual-value env2)
     (check-equal? '(1 2))))

;; d. eval-sequcne를 어떻게 해야하나?
;;   1. Cy D. Fect (eval-sequcne-cy)
;;   2. 혹은  Ben Bitdiddle (lazy:eval-sequence)
;;   3. 아니면,  다른 방법?
;;
;; Cy D. Fect말도 사이드 이펙트를 피할 수 있지만, lazy함의 장점을 잃어버림.
;; Ben Bitdiddle의 lazy방식도 좋지만 (p2 1)와 같이 사이드 이팩트가 일어날 수 있음.
;; 다른 방법으로는, expr이 부수효과가 있으면 강제 평가하고 넘어가도록 짜면 피할 수 있음. 다만 부수효과 여부를 어떻게 판별할지가 관건.
