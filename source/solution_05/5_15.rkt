#lang sicp
;; file: 5_15.rkt

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix racket: racket))
(#%require threading)


#|
연습문제 5.15: 레지스터 머신 시뮬레이션에 명령어 카운팅 기능을 추가하시오.
즉, 머신 모델이 실행된 명령어의 수를 추적하도록 하시오.
머신 모델의 인터페이스를 확장하여 명령어 카운트 값을 출력하고 카운트를 0으로 재설정하는 새로운 메시지를 수락하도록 하시오.
|#

(racket:require (racket:only-in "../allcode/ch5.rkt"
                                figure-5-11
                                figure-5-12))

(racket:require "../allcode/ch5-regsim.rkt")
#;(override-make-stack! make-stack-5-2-4)

(define (make-new-machine-5-15)
  (let ((pc (make-register 'pc))
        (flag (make-register 'flag))
        (stack (make-stack))
        (the-instruction-sequence '())
        (instruction-count 0))
    (let ((the-ops
           (list (list 'initialize-stack
                       (lambda () (stack 'initialize)))
                 ;;**next for monitored stack (as in section 5.2.4)
                 ;;  -- comment out if not wanted
                 (list 'print-stack-statistics
                       (lambda () (stack 'print-statistics)))

                 ;; added : 5-15
                 (list 'initialize-instruction-count
                       (lambda ()
                         (set! instruction-count 0)))
                 (list 'print-instruction-count
                       (lambda ()
                         (newline)
                         (display (list 'print-instruction-count  '= instruction-count))))))
          (register-table
           (list (list 'pc pc) (list 'flag flag))))
      (define (allocate-register name)
        (if (assoc name register-table)
            (error "Multiply defined register: " name)
            (set! register-table
                  (cons (list name (make-register name))
                        register-table)))
        'register-allocated)
      (define (lookup-register name)
        (let ((val (assoc name register-table)))
          (if val
              (cadr val)
              (error "Unknown register:" name))))
      (define (execute)
        (let ((insts (get-contents pc)))
          (if (null? insts)
              'done
              (begin
                ((instruction-execution-proc (car insts)))
                ;; added: 5-15
                (set! instruction-count (inc instruction-count))
                (execute)))))
      (define (dispatch message)
        (cond ((eq? message 'start)
               (set-contents! pc the-instruction-sequence)
               (execute))
              ((eq? message 'install-instruction-sequence)
               (lambda (seq) (set! the-instruction-sequence seq)))
              ((eq? message 'allocate-register) allocate-register)
              ((eq? message 'get-register) lookup-register)
              ((eq? message 'install-operations)
               (lambda (ops) (set! the-ops (append the-ops ops))))
              ((eq? message 'stack) stack)
              ((eq? message 'operations) the-ops)
              (else (error "Unknown request -- MACHINE" message))))
      dispatch)))


(override-make-new-machine! make-new-machine-5-15)

(define dummy-machine
  (make-machine
   '(x y)
   '()
   '((assign x (const 1))                          ; 0 -> 1
     (assign y (const 2))                          ; 1 -> 2

     (perform (op print-instruction-count))        ; 출력(2) -> 3
     (perform (op print-instruction-count))        ; 출력(3) -> 4

     (perform (op initialize-instruction-count))   ; reset(0) -> 1
     
     (perform (op print-instruction-count))        ; 출력(1) -> 2
     )
   ))

(check-output?
 "
(print-instruction-count = 2)
(print-instruction-count = 3)
(print-instruction-count = 1)"
 
 (start dummy-machine))
