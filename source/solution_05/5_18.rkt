#lang sicp
;; file: 5_18.rkt
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix racket: racket))
(#%require threading)

#|
연습문제 5.18: 5.2.1절의 make-register 프로시저를 수정하여 레지스터를 추적할 수 있도록 하세요.

1. 레지스터는 추적을 켜고 끄는 메시지를 받아들여야 합니다.
2. 레지스터가 추적 중일 때, 레지스터에 값을 할당하면 레지스터의 이름, 기존 내용, 그리고 새로 할당되는 내용을 출력해야 합니다.
3. 기계 모델의 인터페이스를 확장하여 지정된 기계 레지스터에 대해 추적을 켜고 끌 수 있도록 하세요.

|#
(racket:require (racket:only-in "../allcode/ch5.rkt"
                                figure-5-11
                                figure-5-12))

(racket:require "../allcode/ch5-regsim.rkt")


(define (make-register name)
  (let ((contents '*unassigned*)
        (is-tracking false) ; added: 5-18 - 1.
        )
    (define (dispatch message)
      (cond ((eq? message 'get) contents)
            ((eq? message 'set)
             (lambda (value)
               ;; added: 5-18 - 2.
               (if is-tracking
                   (begin
                     (newline)
                     (display (list 'register "(" name ")" contents '>>>>> value))))
               (set! contents value)))
            ;; added: 5-18 - 1.
            ((eq? message 'set-is-tracking)
             (lambda (value) (set! is-tracking value)))
            (else
             (error "Unknown request -- REGISTER" message))))
    dispatch))

(override-make-register! make-register)

(define (make-new-machine)
  (let ((pc (make-register 'pc))
        (flag (make-register 'flag))
        (stack (make-stack))
        (the-instruction-sequence '()))
    (let ((the-ops
           (list (list 'initialize-stack
                       (lambda () (stack 'initialize)))
                 ;;**next for monitored stack (as in section 5.2.4)
                 ;;  -- comment out if not wanted
                 (list 'print-stack-statistics
                       (lambda () (stack 'print-statistics)))))
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
              ;; added: 5-18 - 3.
              ((eq? message 'register-track)
               (lambda (reg-name is-tracking)
                 (let ((reg (lookup-register reg-name)))
                   ((reg 'set-is-tracking) is-tracking))))
              (else (error "Unknown request -- MACHINE" message))))
      dispatch)))

(override-make-new-machine! make-new-machine)

(define dummy-machine
  (make-machine
   '(x y)
   '()
   '((assign x (const 1))
     (assign y (const 2))

     (assign x (reg y))
     (assign y (reg x))
     
     (assign x (const 3))
     )
   ))

(check-output?
 "
(register ( x ) *unassigned* >>>>> 1)
(register ( x ) 1 >>>>> 2)
(register ( x ) 2 >>>>> 3)"

 ((dummy-machine 'register-track) 'x true)
 (start dummy-machine))