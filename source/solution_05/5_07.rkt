#lang sicp
;; file: 5_07.rkt
;; 5_04 / 5_07

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)

;; simulator를 사용해여 머신을 테스트라하(연습문제 5.4에서 디자인한)
(#%require "../allcode/ch5-regsim.rkt")
(#%require "5_04.rkt")

(define add-machine
  (make-machine
   ;; 레지스터 목록
   '(n val sum continue)

   ;; 연산 목록
   (list (list '+ +)
         (list '- -)
         (list '= =))
   
   ;; 컨트롤러
   '(
     #;(assign continue (label done))
     
     loop
     (test (op =) (reg n) (const 0))         ; if n == 0
     (branch (label done))                   ;    break
     (assign sum (op +) (reg sum) (reg val)) ; sum += val
     (assign n (op -) (reg n) (const 1))     ; n -= 1
     (goto (label loop))
     
     done)))

(~> add-machine
    (set-register-contents! 'val 3)
    (check-equal? 'done))
(~> add-machine
    (set-register-contents! 'n 5)
    (check-equal? 'done))
(~> add-machine
    (set-register-contents!'sum 0)  ; 결과 저장용
    (check-equal? 'done))
(~> add-machine
    (start)
    (check-equal? 'done))
(~> add-machine 
    (get-register-contents 'sum)
    (check-equal? 15))


(define gcd-machine
  (make-machine
   '(a b t)
   (list (list 'rem remainder) (list '= =))
   '(test-b
     (test (op =) (reg b) (const 0))
     (branch (label gcd-done))
     (assign t (op rem) (reg a) (reg b))
     (assign a (reg b))
     (assign b (reg t))
     (goto (label test-b))
     gcd-done)))

(~> gcd-machine
    (set-register-contents! 'a 206)
    (check-equal? 'done))
(~> gcd-machine
    (set-register-contents! 'b 40)
    (check-equal? 'done))
(~> gcd-machine 
    (start)
    (check-equal? 'done))
(~> gcd-machine 
    (get-register-contents 'a)  ; 결과: 2 (206과 40의 GCD)
    (check-equal? 2))

;; ================
(define expt-recur-machine
  (make-machine
   '(b n continue val)
   (list (list '= =)
         (list '- -)
         (list '* *))
   (rest expt-recur-controller)))

(define (expr-recur b n)
  (set-register-contents! expt-recur-machine 'b b)
  (set-register-contents! expt-recur-machine 'n n)
  (start expt-recur-machine)
  (get-register-contents expt-recur-machine 'val))


(check-equal? (expr-recur 2 0)
              1)
(check-equal? (expr-recur 2 10)
              1024)

;; ================
(define expt-iter-machine
  (make-machine
   '(b n counter product)
   (list (list '= =)
         (list '- -)
         (list '* *))
   (rest expt-iter-controller)
   ))

(define (expr-iter b n)
  (set-register-contents! expt-iter-machine 'b b)
  (set-register-contents! expt-iter-machine 'n n)
  (start expt-iter-machine)
  (get-register-contents expt-iter-machine 'product))

(check-equal? (expr-iter 2 0)
              1)
(check-equal? (expr-iter 2 10)
              1024)
