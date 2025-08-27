#lang sicp
;; file: 5_06.rkt

;; ref:
;;   - Figure 5.12
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)

#|
Ben Bitdiddle 은 피보나치 머신의 컨트롤러 시퀀스에 불필요한 save와 restore 명령이 포함되어 있으며,
이를 제거하면 더 빠른 머신을 만들 수 있는 것을 알아차렸습니다.
이 명령들은 어디에 있습니까?
|#

(#%require "../allcode/ch5-regsim.rkt")

'(define (fib n)
   (if (< n 2) 
       n 
       (+ (fib (- n 1)) (fib (- n 2)))))


(define fib-controller
  '(controller
    (assign continue
            (label fib-done))
   
    fib-loop
    (test (op <) (reg n) (const 2))
    (branch (label immediate-answer))
    ;; set up to compute Fib(n - 1)
    (save continue)                                          ; - save1   continue
    (assign continue
            (label afterfib-n-1))
    (save n)           ; save old value of n                 ; - save2   n
    (assign n 
            (op -)
            (reg n)
            (const 1)) ; clobber n to n-1
    (goto 
     (label fib-loop)) ; perform recursive call
   
    afterfib-n-1 ; upon return, val contains Fib(n - 1)
    (restore n)                                             ; - restore1 n
    ;;(restore continue)                                      ; - restore2 continue <<------
    ;; set up to compute Fib(n - 2)
    (assign n (op -) (reg n) (const 2))
    ;;(save continue)                                         ; - save3    continue  <<------
    (assign continue
            (label afterfib-n-2))
    (save val)         ; save Fib(n - 1)                    ; - save4    val
    (goto (label fib-loop))
   
    afterfib-n-2 ; upon return, val contains Fib(n - 2)
    (assign n 
            (reg val)) ; n now contains Fib(n - 2)
    (restore val)      ; val now contains Fib(n - 1)        ; - restore3 val
    (restore continue)                                      ; - restore4 continue
    (assign val        ; Fib(n - 1) + Fib(n - 2)
            (op +) 
            (reg val)
            (reg n))
    (goto              ; return to caller,
     (reg continue))   ; answer is in val
   
    immediate-answer
    (assign val 
            (reg n))   ; base case: Fib(n) = n
    (goto
     (reg continue))
   
    fib-done))

(define fib-machine
  (make-machine
   '(n continue val)
   (list (list '< <)
         (list '- -)
         (list '+ +))
   (rest fib-controller)
   ))

(define (fib n)
  (set-register-contents! fib-machine 'n n)
  (start fib-machine)
  (get-register-contents fib-machine 'val))

(check-equal? (fib 0)
              0)
(check-equal? (fib 1)
              1)
(check-equal? (fib 2)
              1)
(check-equal? (fib 3)
              2)
(check-equal? (fib 10)
              55)