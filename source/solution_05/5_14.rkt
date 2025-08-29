#lang sicp
;; file: 5_14.rkt
;; ref:
;; figure-5-11
;; figure-5-4

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix racket: racket))
(#%require threading)


#|

1. figure-5-11에 대해 다양한 n에 대한 필요한 푸시 횟수와 최대 스택 깊이를 측정하시오.

2. 임의의 n > 1 에 대해, n! 을 계산할 때 사용되는 총 푸시 연산 횟수와 최대 스택 깊이에 대한 n 의 함수로서의 공식을 구하라.
   - 각각은 n의 선형 함수이며, 따라서 두 개의 상수로 결정된다는 점에 유의하시오.
   - 통계 정보를 출력하려면, 팩토리얼 기계에 스택을 초기화하고 통계를 출력하는 명령어를 추가해야 합니다.
 
3. 또한, 기계를 수정하여 n 값을 반복적으로 읽고, 팩토리얼을 계산하며, 결과를 출력하도록 할 수 있습니다(그림 5.4의 GCD 기계에서 했던 것처럼).
   - 이렇게 하면 get-register-contents, set-register-contents!, start를 반복적으로 호출하지 않아도 됩니다.
|#

(racket:require (racket:only-in "../allcode/ch5.rkt"
                                figure-5-11
                                figure-5-12))

(racket:require "../allcode/ch5-regsim.rkt")



(override-make-stack! make-stack-5-2-4)

(define (run-machine-figure-5-11 n)
  
  (define machine-figure-5-11
    (make-machine
     '(n continue val)
     (list (list '= =)
           (list '- -)
           (list '* *))
     (rest figure-5-11)))

  (~> machine-figure-5-11
      (set-register-contents! 'n n))
  (~> machine-figure-5-11
      (start))
  ((machine-figure-5-11 'stack) 'print-statistics))


(check-output?
 "\n(total-pushes = 2 maximum-depth = 2)"
 ;; n 2
 ;; p 2
 ;; d 2

 (run-machine-figure-5-11 2))

(check-output?
 "\n(total-pushes = 8 maximum-depth = 8)"
 ;; n 5
 ;; p 8
 ;; d 8

 (run-machine-figure-5-11 5))

(check-output?
 "\n(total-pushes = 18 maximum-depth = 18)"
 ;; n 10
 ;; p 18
 ;; d 18
 
 (run-machine-figure-5-11 10))


#|

따라서 p = d = 2n - 2

|#

(define figure-5-11-loop
  ;; factorial
  '(controller
    (perform (op initialize-stack))         ; ** 5.14
    (assign n (op read))                    ; ** 5.14
    
    (assign continue (label fact-done))     ; set up final return address
    
    fact-loop
    (test (op =) (reg n) (const 1))
    (branch (label base-case))
    ;; Set up for the recursive call by saving n and continue.
    ;; Set up continue so that the computation will continue
    ;; at after-fact when the subroutine returns.
    (save continue)
    (save n)
    (assign n (op -) (reg n) (const 1))
    (assign continue (label after-fact))
    (goto (label fact-loop))
    
    after-fact
    (restore n)
    (restore continue)
    (assign val (op *) (reg n) (reg val))   ; val now contains n(n-1)!
    (goto (reg continue))                   ; return to caller
    
    base-case
    (assign val (const 1))                  ; base case: 1!=1
    (goto (reg continue))                   ; return to caller

    fact-done
    (perform (op print-stack-statistics))   ; ** 5.14
    (goto (label controller))               ; ** 5.14
    ))

(define (run-machine-figure-5-11-loop)
  (define machine-figure-5-11-loop
    (make-machine
     '(n continue val)
     (list (list '= =)
           (list '- -)
           (list '* *)
           (list 'read read)               ; ** 5.14
           )
     figure-5-11-loop))

  (~> machine-figure-5-11-loop
      (start)))

;; 루프 실행
;; (run-machine-figure-5-11-loop)