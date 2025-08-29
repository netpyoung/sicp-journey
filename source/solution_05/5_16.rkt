#lang sicp
;; file: 5_16.rkt

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix racket: racket))
(#%require threading)


#|
연습문제 5.16: 시뮬레이터를 확장하여 명령어 추적 기능을 제공하시오.
 즉, 각 명령어가 실행되기 전에 시뮬레이터가 해당 명령어의 텍스트를 출력하도록 하시오.
 머신 모델이 trace-on과 trace-off 메시지를 수락하여 추적 기능을 켜고 끌 수 있도록 하시오.
|#

(racket:require (racket:only-in "../allcode/ch5.rkt"
                                figure-5-11
                                figure-5-12))

(racket:require "../allcode/ch5-regsim.rkt")


(define (make-new-machine-5-16)
  (let ((pc (make-register 'pc))
        (flag (make-register 'flag))
        (stack (make-stack))
        (the-instruction-sequence '())
        (is-trace-on false))
    (let ((the-ops
           (list (list 'initialize-stack
                       (lambda () (stack 'initialize)))
                 ;;**next for monitored stack (as in section 5.2.4)
                 ;;  -- comment out if not wanted
                 (list 'print-stack-statistics
                       (lambda () (stack 'print-statistics)))

                 ;; added : 5-16
                 (list 'trace-on
                       (lambda ()
                         (set! is-trace-on true)))
                 (list 'trace-off
                       (lambda ()
                         (set! is-trace-on false)))))
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
                (if is-trace-on
                    (begin
                      (newline)
                      (display (first (first insts)))))
                ((instruction-execution-proc (first insts)))
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


(override-make-new-machine! make-new-machine-5-16)

(define dummy-machine
  (make-machine
   '(x y)
   '()
   '((assign x (const 1))
     (assign y (const 2))

     (perform (op trace-on))
     (assign x (const 1))
     (assign y (const 2))
     
     (perform (op trace-off))
     (assign x (const 1))
     (assign y (const 2))
     )
   ))

(check-output?
 "
(assign x (const 1))
(assign y (const 2))
(perform (op trace-off))"
 
 (start dummy-machine))