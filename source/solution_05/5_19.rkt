#lang sicp
;; file: 5_19.rkt
;; 5_15 / 5_16 / 5_17 / 5_19

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix racket: racket))
(#%require threading)

#|
(set-breakpoint ⟨machine⟩ ⟨label⟩ ⟨n⟩)    : 1. label에서 n만큼 떨어진 곳에 breakpoint 설정
(proceed-machine ⟨machine⟩)               ; 2. 실행 이어가기
(cancel-breakpoint ⟨machine⟩ ⟨label⟩ ⟨n⟩) ; 3. breakpoint 제거
(cancel-all-breakpoints ⟨machine⟩)        ; 4. 모든 breakpoints 제거
|#

#|

1.
- n번째 찾는건 5_17 에서처럼 labels를 들고있다가 거기서 인덱스 만큼 떨어진 곳에 instruction을 찾을 수 있을거임.
- breakpoint table같은걸 만들어서 거기에 해당 instruction을 키로 해서 넣으면 될듯.
- 머신을 실행을 지속시키는것은 (execute) 루프
- breakpoint를 만나면 루프를 중지시키면 됨.


2.
- proceed-machine은 단순이 execute를 시켜주면 알아서 진행될꺼임.
- 단 첫 실행시 breakpoint 우회 방법 필요.

3.
- 1.에서 처럼 labels에서 instruction을 찾은 후 breakpoint 테이블에서 지우면 될꺼고

4.
- breakpoint 테이블 자체를 클리어 시키면 됨.

|#

(racket:require (racket:only-in "../allcode/ch5.rkt"
                                figure-5-11
                                figure-5-12))
(racket:require "../allcode/ch5-regsim.rkt")
(racket:require (racket:only-in "5_12.rkt"
                                make-set))
(reset!)

(define (assemble controller-text machine)
  (extract-labels controller-text
                  (lambda (insts labels)
                    (update-insts! insts labels machine)
                    (list insts labels))))
(override-assemble! assemble)

(define (set-breakpoint machine label n)
  ((machine 'set-breakpoint) label n))

(define (proceed-machine machine)
  (machine 'proceed-machine))

(define (cancel-breakpoint machine label n)
  ((machine 'cancel-breakpoint) label n))

(define (cancel-all-breakpoints machine)
  (machine 'cancel-all-breakpoints))

(define (nth lst n)
  (cond ((null? lst) (error "Index out of bounds"))
        ((< n 0) (error "Index cannot be negative"))
        ((= n 0) (car lst))
        (else (nth (cdr lst) (- n 1)))))

(define (find-inst labels in-label-name in-n)
  (if (null? labels)
      nil
      (let* ((label (first labels))
             (label-name (first label))
             (insts (rest label)))
        (if (eq? in-label-name label-name)
            (nth insts in-n)
            (find-inst (rest labels) in-label-name in-n)))))

(define (make-new-machine)
  (let ((pc (make-register 'pc))
        (flag (make-register 'flag))
        (stack (make-stack))
        (the-instruction-sequence '())
        (breakpoint-set (make-set)) ; added: 5_19
        (the-labels nil)            ; added: 5_19
        )
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
      ;; before: 5-19
      ;; (define (execute)
      ;;   (let ((insts (get-contents pc)))
      ;;     (if (null? insts)
      ;;         'done
      ;;         (begin
      ;;           ((instruction-execution-proc (car insts)))
      ;;           (execute)))))
      ;; after: 5-19
      (define (execute is-breakable-flag)
        (let ((insts (get-contents pc)))
          (if (null? insts)
              'done
              (begin
                (let ((inst (car insts)))
                  (if (and is-breakable-flag ((breakpoint-set 'contains?) inst))
                      '**break**
                      (begin
                        ((instruction-execution-proc (car insts)))
                        (execute true))))))))
      
      (define (dispatch message)
        (cond ((eq? message 'start)
               (set-contents! pc the-instruction-sequence)
               (execute true))
              ((eq? message 'install-instruction-sequence)
               ;; before: 5-19
               ;; (lambda (seq)
               ;;   (set! the-instruction-sequence seq))
               ;; after: 5-19
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

              ;; added: 5-19
              ((eq? message 'set-breakpoint)
               (lambda (label-name n)
                 (let ((inst (find-inst the-labels label-name n)))
                   (if (not (null? inst))
                       (begin
                         ((breakpoint-set 'add) inst)
                         (list '**break-marked**
                               'lable: label-name
                               ':idx   n
                               'inst:  (first inst)))))))
              ((eq? message 'proceed-machine)
               (execute false))
              ((eq? message 'cancel-breakpoint)
               (lambda (label-name n)
                 (let ((inst (find-inst the-labels label-name n)))
                   (if (null? inst)
                       (list 'cancel-breakpoint
                             'fail-to-find-inst
                             'lable: label-name
                             ':idx   n)
                       (if (not ((breakpoint-set 'contains?) inst))
                           (list 'cancel-breakpoint '**break-already-canceled**
                                 'lable: label-name
                                 ':idx   n
                                 'inst:  (first inst))
                           (let ((deleted-set ((breakpoint-set 'del) inst)))
                             (list 'cancel-breakpoint '**break-canceled**
                                   'lable: label-name
                                   ':idx   n
                                   'inst:  (first inst))))))))
              ((eq? message 'cancel-all-breakpoints)
               (set! breakpoint-set (make-set))
               '**cancel-all-breakpoints**)
              
              (else (error "Unknown request -- MACHINE" message))))
      dispatch)))

(override-make-new-machine! make-new-machine)

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
    (set-breakpoint 'test-b 4)
    (check-equal? '(**break-marked** lable: test-b :idx 4 inst: (assign b (reg t)))))

(~> gcd-machine
    (set-register-contents! 'a 206)
    (check-equal? 'done))
(~> gcd-machine
    (set-register-contents! 'b 40)
    (check-equal? 'done))

(~> gcd-machine
    (start)
    (check-equal? '**break**))

(~> gcd-machine
    (get-register-contents 'a)
    (check-equal? 40))
(~> gcd-machine
    (get-register-contents 'b)
    (check-equal? 40))
(~> gcd-machine
    (get-register-contents 't)
    (check-equal? 6))

(~> gcd-machine
    (proceed-machine)
    (check-equal? '**break**))

(~> gcd-machine
    (get-register-contents 'a)
    (check-equal? 6))
(~> gcd-machine
    (get-register-contents 'b)
    (check-equal? 6))
(~> gcd-machine
    (get-register-contents 't)
    (check-equal? 4))

(~> gcd-machine
    (set-register-contents! 'a 40)
    (check-equal? 'done))
(~> gcd-machine
    (set-register-contents! 'b 40)
    (check-equal? 'done))
(~> gcd-machine
    (set-register-contents! 't 6)
    (check-equal? 'done))

(~> gcd-machine
    (proceed-machine)
    (check-equal? '**break**))

(~> gcd-machine
    (get-register-contents 'a)
    (check-equal? 6))

(~> gcd-machine
    (cancel-breakpoint 'test-c 1)
    (check-equal? '(cancel-breakpoint fail-to-find-inst lable: test-c :idx 1)))
(~> gcd-machine
    (cancel-breakpoint 'test-b 4)
    (check-equal? '(cancel-breakpoint **break-canceled** lable: test-b :idx 4 inst: (assign b (reg t)))))
(~> gcd-machine
    (cancel-breakpoint 'test-b 4)
    (check-equal? '(cancel-breakpoint **break-already-canceled** lable: test-b :idx 4 inst: (assign b (reg t)))))
#;(~> gcd-machine
    (cancel-all-breakpoints)
    (check-equal? '**cancel-all-breakpoints**))

(~> gcd-machine
    (proceed-machine)
    (check-equal? 'done))

(~> gcd-machine
    (get-register-contents 'a)
    (check-equal? 2))
