#lang sicp
;; file: 5_17.rkt
;; 5_15 / 5_16 / 5_17 / 5_19

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix racket: racket))
(#%require threading)


#|
연습문제 5.17: 연습문제 5.16의 명령어 추적 기능을 확장하여,
명령어를 출력하기 전에 시뮬레이터가 컨트롤러 시퀀스에서 해당 명령어 바로 앞에 오는 레이블을 출력하도록 하시오.
이 작업이 명령어 카운팅(연습문제 5.15)과 간섭하지 않도록 주의해서 구현해야 합니다.
시뮬레이터가 필요한 레이블 정보를 유지하도록 해야 합니다.
|#

#|
extract-labels
 text를 insts랑 labels로 분리.

insts : ((insruction) ...)
labels: ((labelA instruction-A1 instruction-A2 ...) (labelB instruction-B1 instruction-B2 ...) ...)

assemble에서
  insts: ((insruction) ...)
  update-insts!
  insts : ((instruction . func) ...)
  insts가 바뀌면서 메모리를 공유하는 labels도 따라 바뀐다.
  labels: ((labelA (instruction-A1 . func) (instruction-A2 . func) ...) ...)
|#

#|
기존 코드에서 pc가 어셈의 instruction pointer처럼 index기반으로 동작했으면, 수정하기 보다 편했으려나...
인덱스 기반으로 싹 바꿀 마음도 있었지만, 대대적 수정이 있을꺼라 패스.

assemble / extract-labels / update-insts!에서 instruction안에 label정보를 찡겨 넣을까 생각해 봤지만,
대신 labels를 머신에 찡겨넣고, labels에서 instruction을 찾는 방식이 좋겠다.


- extract-labels에서 나온 labels 구조가 좀 골때림.
  - 처음에는 각 labels마다 instruction을 담는줄 알아서 find시 첫번째 label만 나오길레 이상해서 보니
  - labels 아레로 나온 Instruction전부를 포함하는 구조로 됨.
  - 그래서 미리 reverse를 시켜 줘서 find가 잘 찾도록 수정
|#


(racket:require (racket:only-in "../allcode/ch5.rkt"
                                figure-5-11
                                figure-5-12))

(racket:require "../allcode/ch5-regsim.rkt")

(override-make-stack! make-stack-5-2-4)

(define (assemble controller-text machine)
  (extract-labels controller-text
                  (lambda (insts labels)
                    (update-insts! insts labels machine)
                    (list insts labels))))

(override-assemble! assemble)

(define (contains? lst x)
  (cond ((null? lst) false)
        ((equal? x (first lst)) true)
        (else (contains? (rest lst) x))))

(define (find-label-name labels instruction)
  (if (null? labels)
      '**non-label-name**
      (let* ((label (first labels))
             (label-name (first label))
             (insts (rest label)))
        (if (contains? insts instruction)
            label-name
            (find-label-name (rest labels) instruction)))))

(define (make-new-machine-5-17)
  (let ((pc (make-register 'pc))
        (flag (make-register 'flag))
        (stack (make-stack))
        (the-instruction-sequence '())
        (instruction-count 0) ; added : 5-15
        (is-trace-on false)   ; added : 5-16
        (the-labels nil)      ; added : 5-17
        )
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
                         (display (list 'print-instruction-count  '= instruction-count))))
                 ;; added : 5-16
                 (list 'trace-on
                       (lambda ()
                         (set! is-trace-on true)))
                 (list 'trace-off
                       (lambda ()
                         (set! is-trace-on false)))
                 ))
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
                ;; added : 5-17
                (if is-trace-on
                    (begin
                      (newline)
                      (let ((label-name (find-label-name the-labels (first insts))))
                        (display (list "==========================" label-name)))))
                
                ;; added : 5-16
                (if is-trace-on
                    (begin
                      (newline)
                      (display (first (first insts)))))
                
                ((instruction-execution-proc (car insts)))
                
                ;; added: 5-15
                (set! instruction-count (inc instruction-count))
                (execute)))))
      (define (dispatch message)
        (cond ((eq? message 'start)
               (set-contents! pc the-instruction-sequence)
               (execute))
              ((eq? message 'install-instruction-sequence)
               ;; before: 5-17
               ;; (lambda (seq)
               ;;   (set! the-instruction-sequence seq))
               ;; after: 5-17
               (lambda (insts-labels)
                 (let ((seq (first insts-labels))
                       (labels (second insts-labels)))
                   (set! the-instruction-sequence seq)
                   (set! the-labels (reverse labels)) ; // reverse를 한 것에 주의.
                   ))
               )
              ((eq? message 'allocate-register) allocate-register)
              ((eq? message 'get-register) lookup-register)
              ((eq? message 'install-operations)
               (lambda (ops) (set! the-ops (append the-ops ops))))
              ((eq? message 'stack) stack)
              ((eq? message 'operations) the-ops)
              (else (error "Unknown request -- MACHINE" message))))
      dispatch)))

(override-make-new-machine! make-new-machine-5-17)

(define dummy-machine
  (make-machine
   '(x y)
   '()
   '(label-A
     (assign x (const 1))
     (assign y (const 2))

     label-B
     (perform (op trace-on))
     (assign x (const 1))
     label-C
     (assign y (const 2))
     (save x)
     (restore x)
     
     label-D
     (perform (op trace-off))
     (assign x (const 1))
     (assign y (const 2))
     )
   ))

(check-output?
   "
(========================== label-B)
(assign x (const 1))
(========================== label-C)
(assign y (const 2))
(========================== label-C)
(save x)
(========================== label-C)
(restore x)
(========================== label-D)
(perform (op trace-off))
(total-pushes = 1 maximum-depth = 1)"
 
   (start dummy-machine)
   ((dummy-machine 'stack) 'print-statistics))