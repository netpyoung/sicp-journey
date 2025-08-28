#lang sicp
;; file: 5_11.rkt
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix racket: racket))
(#%require threading)

#|
a)

(restore y)는 스택에 저장된 마지막 값을, 그 값이 어떤 레지스터에서 왔는지 상관없이 y에 넣습니다.
이것이 우리 시뮬레이터의 동작 방식입니다.
이 동작을 활용하여 5.1.4의 피보나치 머신(그림 5.12)에서 하나의 명령어를 제거하는 방법을 보여주세요.
|#

(racket:require (racket:rename-in "../allcode/ch5-regsim.rkt"
                                  (_make-save origin-make-save)
                                  (_make-restore origin-make-restore)))


(define (dummy-machine-maker)
  (make-machine
   '(x y)
   '()
   '((assign x (const 1))
     (assign y (const 2))

     (save y)
     (save x)
     (restore y)
     )
   ))

(define dummy-machine (dummy-machine-maker))

(~> dummy-machine
    (start)
    (check-equal? 'done))
(~> dummy-machine
    (get-register-contents 'x)
    (check-equal? 1))
(~> dummy-machine
    (get-register-contents 'y)
    (check-equal? 1))



;; a) (restore y)는 스택에 마지막 저장한 값으로 y를 설정.

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
    (restore continue)                                      ; - restore2 continue
    ;; set up to compute Fib(n - 2)
    (assign n (op -) (reg n) (const 2))
    (save continue)                                         ; - save3    continue
    (assign continue
            (label afterfib-n-2))
    (save val)         ; save Fib(n - 1)                    ; - save4    val
    (goto (label fib-loop))
   
    afterfib-n-2 ; upon return, val contains Fib(n - 2)

    ;; before a)
    ;; (assign n (reg val)) ; n now contains Fib(n - 2)
    ;; (restore val)      ; val now contains Fib(n - 1)        ; - restore3 val
    ;;
    ;; after a)
    (restore n) ; <<<<<<<
    
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

#|
b)

(restore y)는 스택에 저장된 마지막 값을 y에 넣지만, 그 값이 y에서 저장된 경우에만 해당됩니다.
그렇지 않으면 오류를 표시합니다.
시뮬레이터를 이 방식으로 동작하도록 수정하세요.
save를 변경하여 값과 함께 레지스터 이름을 스택에 저장해야 합니다.
|#

(define (make-save-b inst machine stack pc)
  (let* ((reg-name (stack-inst-reg-name inst))
         (reg (get-register machine reg-name)))
    (lambda ()
      (push stack (cons reg-name (get-contents reg)))
      (advance-pc pc))))

(define (make-restore-b inst machine stack pc)
  (let* ((restore-reg-name (stack-inst-reg-name inst))
         (reg (get-register machine restore-reg-name)))
    (lambda ()
      (let* ((poped (pop stack))
             (pop-reg-name (first poped))
             (pop-reg-val  (rest poped)))
        (if (not (eq? restore-reg-name pop-reg-name))
            (error "restore-reg-name:" restore-reg-name 'pop-reg-name: pop-reg-name))
        (set-contents! reg pop-reg-val)
        (advance-pc pc)))))

(override-make-save! make-save-b)
(override-make-restore! make-restore-b)


(set! dummy-machine (dummy-machine-maker))
(check-exn
 #rx"restore-reg-name: y pop-reg-name: x"
 (lambda ()
   (start dummy-machine)))

#|
c)

(restore y)는 y 이후에 다른 레지스터들이 저장되고 복원되지 않았더라도, y에서 저장된 마지막 값을 y에 넣습니다.
시뮬레이터를 이 방식으로 동작하도록 수정하세요.
각 레지스터에 별도의 스택을 연결해야 합니다.
initialize-stack 작업이 모든 레지스터 스택을 초기화하도록 해야 합니다.
|#
(reset!)


(define (kv-stack-init!)
  (list 'kv-stack))

(define (kv-stack-push! kv-pop key new-value)
  
  (define (last-pair lst)
    (if (null? (rest lst))
        lst
        (last-pair (rest lst))))
  
  (let ((rest-kv-pop (rest kv-pop)))
    (if (null? rest-kv-pop)
        (begin
          (set-cdr! kv-pop (list (list key (list new-value))))
          kv-pop)
        (let loop ((current rest-kv-pop))
          (cond
            ((null? current)
             (set-cdr! (last-pair rest-kv-pop)
                       (list (list key (list new-value))))
             kv-pop)
            (else
             (let* ((key-stack (first current))
                    (k (first key-stack))
                    (stack (second key-stack)))
               (if (eq? k key)
                   (begin
                     (set-car! (rest key-stack) (cons new-value stack))
                     kv-pop)
                   (loop (rest current))))))))))

(define (kv-stack-pop! kv-pop key)
  (let ((rest-kv-pop (rest kv-pop)))
    (let loop ((current rest-kv-pop))
      (cond
        ((null? current)
         (error "Key not found:" key))
        (else
         (let* ((key-stack (first current))
                (k (first key-stack))
                (stack (second key-stack)))
           (if (eq? k key)
               (if (null? (second key-stack))
                   (error "Value list is empty for key:" key)
                   (let ((value (first stack)))
                     (set-car! (rest key-stack) (rest stack))
                     value))
               (loop (rest current)))))))))


(define (make-stack-c)
  (let ((s (kv-stack-init!)))
    (define (push x)
      (let ((k (first x))
            (v (rest x)))
        (kv-stack-push! s k v)))
    (define (pop k)
      (kv-stack-pop! s k))
    (define (initialize)
      (set! s (kv-stack-init!))
      'done)
    (define (dispatch message)
      (cond ((eq? message 'push) push)
            ((eq? message 'pop) pop)
            ((eq? message 'initialize) (initialize))
            (else (error "Unknown request -- STACK"
                         message))))
    dispatch))

(define (make-save-c inst machine stack pc)
  (let* ((reg-name (stack-inst-reg-name inst))
         (reg (get-register machine reg-name)))
    (lambda ()
      (push stack (cons reg-name (get-contents reg)))
      (advance-pc pc))))

(define (make-restore-c inst machine stack pc)
  (let* ((restore-reg-name (stack-inst-reg-name inst))
         (reg (get-register machine restore-reg-name)))
    (lambda ()
      ;; (pop stack) 함수를 호출하는 곳이 여기에만 있음.
      ;; (pop stack)함수를 override 할 수 있게 수정하는 대신
      ;; (stack 'pop)으로 직접 콜하는 방식으로 대신함.
      (let* ((poped ((stack 'pop) restore-reg-name)))
        (set-contents! reg poped)
        (advance-pc pc)))))

(override-make-stack! make-stack-c)
(override-make-save! make-save-c)
(override-make-restore! make-restore-c)

(set! dummy-machine (dummy-machine-maker))

(~> dummy-machine
    (start)
    (check-equal? 'done))
(~> dummy-machine
    (get-register-contents 'x)
    (check-equal? 1))
(~> dummy-machine
    (get-register-contents 'y)
    (check-equal? 2))