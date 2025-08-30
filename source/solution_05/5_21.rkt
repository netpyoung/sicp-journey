#lang sicp
;; file: 5_21.rkt
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix racket: racket))
(#%require threading)

#|

연습문제 5.21: 다음 프로시저에 대한 레지스터 머신 구현
리스트 구조 메모리 연산이 머신 기본 연산(primitive)으로 사용 가능하다고 가정하고, 아래 프로시저에 대한 레지스터 머신을 구현하시오.

1. 재귀적 count-leaves:
(define (count-leaves tree)
  (cond ((null? tree) 0)
        ((not (pair? tree)) 1)
        (else 
         (+ (count-leaves (car tree))
            (count-leaves (cdr tree))))))

2. 명시적 카운터를 사용한 재귀적 count-leaves:
(define (count-leaves tree)
  (define (count-iter tree n)
    (cond ((null? tree) n)
          ((not (pair? tree)) (+ n 1))
          (else 
           (count-iter 
            (cdr tree)
            (count-iter (car tree) 
                        n)))))
  (count-iter tree 0))
|#

#|
1번은 figure 5.12와 닮아 있음.


|#

(racket:require "../allcode/ch5-regsim.rkt")
(override-make-stack! make-stack-5-2-4)

(define (count-leaves-v1 tree)
  (cond ((null? tree) 0)
        ((not (pair? tree)) 1)
        (else 
         (+ (count-leaves-v1 (car tree))
            (count-leaves-v1 (cdr tree))))))

(define (count-leaves-v2 tree)
  (define (count-iter tree n)
    (cond ((null? tree) n)
          ((not (pair? tree)) (+ n 1))
          (else 
           (count-iter 
            (cdr tree)
            (count-iter (car tree) 
                        n)))))
  (count-iter tree 0))

(define sample-tree
  '((1 (2 3 (4 5)) (6 7)) (8 (9 (10 (11) 12)))))

(check-equal? (count-leaves-v1 sample-tree)
              12)
(check-equal? (count-leaves-v2 sample-tree)
              12)

;; v1 =====================================================================

(define controller-count-leaves-v1
  '(BEGIN
    
    (assign continue (label END))
    
    LOOP
    (test (op null?) (reg tree))             ; cond - ((null? tree) 0)
    (branch
     (label CASE-0))
    (assign temp1 (op pair?) (reg tree))     ; cond - ((not (pair? tree)) 1)
    (test (op not) (reg temp1))
    (branch
     (label CASE-1))
    
    (save continue)
    (assign continue (label AFTER-car-tree))
    (save tree)
    (assign tree (op car) (reg tree))        ; prepare : (count-leaves (car tree))
    (goto
     (label LOOP))                           ; do      : (count-leaves (car tree))

    AFTER-car-tree
    (restore tree)
    (restore continue)
    (assign tree (op cdr) (reg tree))        ; prepare : (count-leaves (cdr tree))
    (save continue)
    (assign continue (label AFTER-cdr-tree))
    (save val)                               ; save    : (count-leaves (car tree))
    (goto
     (label LOOP))                           ; do      : (count-leaves (cdr tree))

    AFTER-cdr-tree
    (assign tree (reg val))                  ; save    : (count-leaves (cdr tree))
    (restore val)                            ; restore : (count-leaves (car tree))
    (restore continue)
    (assign val (op +) (reg val) (reg tree)) ; cond - (+ (count-leaves-v1 (car tree))
    ;           (count-leaves-v1 (cdr tree)))
    (goto
     (reg continue))
    
    CASE-0
    (assign val (const 0))
    (goto
     (reg continue))

    CASE-1
    (assign val (const 1))
    (goto
     (reg continue))
    
    END))

(define machine-count-leaves-v1
  (make-machine
   '(tree temp1 continue val)
   (list (list 'null? null?)
         (list 'pair? pair?)
         (list 'not not)
         (list '+ +)
         (list 'car car)
         (list 'cdr cdr)
         )
   controller-count-leaves-v1
   ))

(~> machine-count-leaves-v1
    (set-register-contents! 'tree sample-tree)
    (check-equal? 'done))

(~> machine-count-leaves-v1
    (start)
    (check-equal? 'done))

(~> machine-count-leaves-v1
    (get-register-contents 'val)
    (check-equal? 12))

(check-output?
 "
(total-pushes = 80 maximum-depth = 18)"
 
 ((machine-count-leaves-v1 'stack) 'print-statistics))

;; v2 =====================================================================

(define controller-count-leaves-v2
  '(BEGIN
    
    (assign continue (label END))
    (assign n (const 0))                   ; (count-iter tree 0)
    
    LOOP
    (test (op null?) (reg tree))           ; cond - ((null? tree) n)
    (branch
     (label CASE-n))
    (assign temp1 (op pair?) (reg tree))   ; cond - ((not (pair? tree)) (+ n 1))
    (test (op not) (reg temp1))
    (branch
     (label CASE-n+1))

    ;; (count-iter (cdr tree)
    ;;             (count-iter (car tree)  n))))))
    (save continue)
    (assign continue (label AFTER-car-tree))
    (save tree)
    (assign tree (op car) (reg tree))
    (goto
     (label LOOP))

    AFTER-car-tree
    (restore tree)
    (restore continue)
    (assign tree (op cdr) (reg tree))
    (assign n (reg val))
    (goto
     (label LOOP))

    
    CASE-n
    (assign val (reg n))
    (goto
     (reg continue))

    CASE-n+1
    (assign val (op +) (reg n) (const 1))
    (goto
     (reg continue))
    
    END))


(define machine-count-leaves-v2
  (make-machine
   '(tree n temp1 continue val)
   (list (list 'null? null?)
         (list 'pair? pair?)
         (list 'not not)
         (list '+ +)
         (list 'car car)
         (list 'cdr cdr)
         )
   controller-count-leaves-v2
   ))

(~> machine-count-leaves-v2
    (set-register-contents! 'tree sample-tree)
    (check-equal? 'done))

(~> machine-count-leaves-v2
    (start)
    (check-equal? 'done))

(~> machine-count-leaves-v2
    (get-register-contents 'val)
    (check-equal? 12))

(check-output?
 "
(total-pushes = 40 maximum-depth = 10)"
 
 ((machine-count-leaves-v2 'stack) 'print-statistics))