#lang sicp
;; file: 5_13.rkt

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix racket: racket))
(#%require threading)

(racket:provide
 make-machine-5-13)

#|
레지스터 목록을 make-machine에 인자로 넘기는 대신 컨트롤러 시퀀스를 사용하도록 해라.
 make-machine에서 레지스터를 미리 할당하는 대신, 명령어 조립 중에 레지스터가 처음 등장할 때 하나씩 할당할 수 있다.
|#
(racket:require (racket:only-in "../allcode/ch5.rkt"
                                figure-5-11
                                figure-5-12))

(racket:require "../allcode/ch5-regsim.rkt")

(define (contains? lst x)
  (cond ((null? lst) false)
        ((equal? x (first lst)) true)
        (else (contains? (rest lst) x))))

(define (remove-duplicates lst)
  (define (iter acc lst)
    (cond ((null? lst)
           (reverse acc))
          ((contains? acc (first lst))
           (iter acc (rest lst)))
          (else
           (iter (cons (first lst) acc) (rest lst)))))
  (iter '() lst))

(define (filter predicate sequence)
  (cond ((null? sequence) nil)
        ((predicate (car sequence))
         (cons (car sequence)
               (filter predicate (cdr sequence))))
        (else (filter predicate (cdr sequence)))))

(define (accumulate op initial sequence)
  (if (null? sequence)
      initial
      (op (car sequence)
          (accumulate op initial (cdr sequence)))))

(define (flatmap proc seq)
  (accumulate append nil (map proc seq)))

(define (get-all-registers controller-text)
  (~> controller-text
      (extract-labels
       (lambda (insts labels)
         (~>> insts
              (map first)
              (flatmap (lambda (x)
                         (filter (lambda (xx)
                                   (register-exp? xx))
                                 x)))
              (map second)
              (remove-duplicates))))))


(define (make-new-machine-5-13)
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
              ;; 5.13
              ;;
              ;; before
              ;; (error "Unknown register:" name)
              ;;
              ;; after
              ;; make-machine에서 레지스터를 미리 할당하는 대신,
              ;; 명령어 조립 중에 레지스터가 처음 등장할 때 하나씩 할당할 수 있다.
              (begin
                (allocate-register name)
                (lookup-register name)))))
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
              (else (error "Unknown request -- MACHINE" message))))
      dispatch)))

(define (make-machine-5-13 ops controller-text)
  (let ((machine (make-new-machine-5-13)))
    
    ;; NOTE(pyoung): 이런 식으로 먼저 구문 분석해서 레지스터를 미리 추가할 수 도 있다.
    ;; (let ((register-names (get-all-registers controller-text)))
    ;;   (for-each (lambda (register-name)
    ;;               ((machine 'allocate-register) register-name))
    ;;             register-names))
    
    ((machine 'install-operations) ops)    
    ((machine 'install-instruction-sequence)
     (assemble controller-text machine))
    machine))

(define machine-figure-5-11
  (make-machine-5-13
   (list (list '= =)
         (list '- -)
         (list '* *))
   (rest figure-5-11)))

(~> machine-figure-5-11
    (set-register-contents! 'n 10)
    (check-equal? 'done))
(~> machine-figure-5-11
    (start)
    (check-equal? 'done))
(~> machine-figure-5-11
    (get-register-contents 'val)
    (check-equal? 3628800))

(define machine-figure-5-12
  (make-machine-5-13
   (list (list '< <)
         (list '- -)
         (list '+ +))
   (rest figure-5-12)))

(~> machine-figure-5-12
    (set-register-contents! 'n 10)
    (check-equal? 'done))
(~> machine-figure-5-12
    (start)
    (check-equal? 'done))
(~> machine-figure-5-12
    (get-register-contents 'val)
    (check-equal? 55))