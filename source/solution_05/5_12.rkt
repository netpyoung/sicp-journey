#lang sicp
;; file: 5_12.rkt
;; ref:
;;    - Figure 5.11: A recursive factorial machine.
;;    - Figure 5.12: Controller for a machine to compute Fibonacci numbers.

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix racket: racket))
(#%require threading)

(racket:provide
 make-set
 make-kv-set)

#|
어셈블러를 확장하여 기계 모델에 다음 정보를 저장하도록 하세요:

1. 모든 명령어의 목록(중복 제거, 명령어 유형(assign, goto 등)으로 정렬됨).
2. 진입점(entry point)을 저장하는 데 사용되는 레지스터의 목록(중복 없이, goto 명령어에서 참조된 레지스터).
3. save되거나 restore되는 레지스터의 목록(중복 없이).
4. 각 레지스터에 대해, 해당 레지스터에 할당되는 소스(source)의 목록(중복 없이).
  - 예를 들어, 그림 5.11의 팩토리얼 기계에서 레지스터 val의 소스는 (const 1)과 ((op *) (reg n) (reg val))입니다.

기계의 메시지 패싱 인터페이스를 확장하여 이 새로운 정보에 접근할 수 있도록 하세요.
분석기를 테스트하기 위해 그림 5.12의 피보나치 기계를 정의하고, 생성한 목록들을 확인하세요.
|#

(define figure-5-11
  ;; factorial
  '(controller
    (assign continue (label fact-done))     ; set up final return address
    
    fact-loop
    (test (op =) (reg n) (const 1))
    (branch (label base-case))
    ;; Set up for the recursive call by saving n and continue.
    ;; Set up continue so that the computation will continue
    ;; at after-fact when the subroutine returns.
    (save continue)
    (save n)
    (assign n (op -) (reg n) (const 1))
    (assign continue (label after-fact))
    (goto (label fact-loop))
    
    after-fact
    (restore n)
    (restore continue)
    (assign val (op *) (reg n) (reg val))   ; val now contains n(n-1)!
    (goto (reg continue))                   ; return to caller
    
    base-case
    (assign val (const 1))                  ; base case: 1!=1
    (goto (reg continue))                   ; return to caller
    fact-done))

(define figure-5-12
  ;; fib
  '(controller
    (assign continue (label fib-done))
    fib-loop
    (test (op <) (reg n) (const 2))
    (branch (label immediate-answer))
    ;; set up to compute Fib(n-1)
    (save continue)
    (assign continue (label afterfib-n-1))
    (save n)                           ; save old value of n
    (assign n (op -) (reg n) (const 1)); clobber n to n-1
    (goto (label fib-loop))            ; perform recursive call
    afterfib-n-1                         ; upon return, val contains Fib(n-1)
    (restore n)
    (restore continue)
    ;; set up to compute Fib(n-2)
    (assign n (op -) (reg n) (const 2))
    (save continue)
    (assign continue (label afterfib-n-2))
    (save val)                         ; save Fib(n-1)
    (goto (label fib-loop))
    afterfib-n-2                         ; upon return, val contains Fib(n-2)
    (assign n (reg val))               ; n now contains Fib(n-2)
    (restore val)                      ; val now contains Fib(n-1)
    (restore continue)
    (assign val                        ; Fib(n-1)+Fib(n-2)
            (op +) (reg val) (reg n)) 
    (goto (reg continue))              ; return to caller, answer is in val
    immediate-answer
    (assign val (reg n))               ; base case: Fib(n)=n
    (goto (reg continue))
    fib-done))


#|
중복 안되며서 추가가능한 자료구조가 필요함.
set / 그리고 kv-set

1~4 이름 짓고
1. instruction-set
2. entry-register-set
3. save-restore-register-set
4. register-source-kv-set

그리고 controller-text처리하는 곳을 따라가야함

- 호출부 make-machine
- 정보 저장하려면 make-new-machine
- 그리고 참고용 install-instruction-sequence를 처리하는
  -(assemble controller-text machine)함수를 보면 extract-labels로 insts를 얻어올 수 있음.
|#



(define (make-set)
  (define (set-init!)
    (list 'set))
  (define (contains? set x)
    (member x (rest set)))
  (define (add! set x)
    (if (contains? set x)
        set
        (let ((y (rest set)))
          (set-cdr! set (cons x (rest set)))
          set)))
  
  (let ((s (set-init!)))
    (define (add x)
      (add! s x))
    (define (set)
      s)
    (define (dispatch message)
      (cond ((eq? message 'set) (set))
            ((eq? message 'add) add)
            (else (error "Unknown request -- SET" message))))
    dispatch))

(define my-set (make-set))
(check-equal? (my-set 'set) '(set))
(check-equal? ((my-set 'add) 1) '(set 1))
(check-equal? ((my-set 'add) 2) '(set 2 1))
(check-equal? ((my-set 'add) 2) '(set 2 1))

(define (make-kv-set)
  (define (kv-set-init!)
    (list 'kv-set))

  (define (contains? lst x)
    (member x lst))

  (define (kv-set-add! kv-set key value)
    (let ((rest-kv-set (rest kv-set)))
      (if (null? rest-kv-set)
          (begin
            (set-cdr! kv-set (list (list key (list value))))
            kv-set)
          (let loop ((current rest-kv-set))
            (cond
              ((null? current)
               (set-cdr! (last-pair rest-kv-set)
                         (list (list key (list value))))
               kv-set)
              (else
               (let* ((key-set (first current))
                      (k (first key-set))
                      (values (second key-set)))
                 (if (eq? k key)
                     (begin
                       (if (not (contains? values value))
                           (set-car! (rest key-set) (cons value values)))
                       kv-set)
                     (loop (rest current))))))))))

  (define (last-pair lst)
    (if (null? (rest lst))
        lst
        (last-pair (rest lst))))

  (let ((s (kv-set-init!)))
    (define (add k v)
      (kv-set-add! s k v))
    (define (set)
      s)
    (define (dispatch message)
      (cond ((eq? message 'add) add)
            ((eq? message 'set) (set))
            (else (error "Unknown request -- KV-SET" message))))
    dispatch))

(define my-kv-set (make-kv-set))
(check-equal? (my-kv-set 'set) '(kv-set))
(check-equal? ((my-kv-set 'add) 'k1 1) '(kv-set (k1 (1))))
(check-equal? ((my-kv-set 'add) 'k1 2) '(kv-set (k1 (2 1))))
(check-equal? ((my-kv-set 'add) 'k1 2) '(kv-set (k1 (2 1))))

;; ===========
(racket:require (racket:rename-in "../allcode/ch5-regsim.rkt"))

(define (make-new-machine)
  (let ((pc (make-register 'pc))
        (flag (make-register 'flag))
        (stack (make-stack))
        (the-instruction-sequence '())
        (instruction-set nil)                  ; 1.
        (entry-register-set nil)               ; 2.
        (save-restore-register-set nil)        ; 3.
        (register-source-kv-set (make-kv-set)) ; 4.
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

              ((eq? message 'instruction-set)           instruction-set)           ; 1.
              ((eq? message 'entry-register-set)        entry-register-set)        ; 2.
              ((eq? message 'save-restore-register-set) save-restore-register-set) ; 3.
              ((eq? message 'register-source-kv-set)    register-source-kv-set)    ; 4.
              
              ((eq? message 'install-instruction-set)            ; 1.
               (lambda (instructions)
                 (set! instruction-set instructions)))
              ((eq? message 'install-entry-register-set)         ; 2.
               (lambda (registers)
                 (set! entry-register-set registers)))
              ((eq? message 'install-save-restore-register-set)  ; 3.
               (lambda (save-restore-registers)
                 (set! save-restore-register-set save-restore-registers)))
              ((eq? message 'install-register-source-kv-set)     ; 4.
               (lambda (register-source-list)
                 (map (lambda (x)
                        (let ((k (first x))
                              (v (second x)))
                          ((register-source-kv-set 'add) k v)))
                      register-source-list)
                 (register-source-kv-set 'set)))
              
              
              ((eq? message 'operations) the-ops)
              (else (error "Unknown request -- MACHINE" message))))
      dispatch)))
(override-make-new-machine! make-new-machine)


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


(define (get-all-instructions controller-text)
  (~> controller-text
      (extract-labels 
       (lambda (insts labels)
         (~>> insts
              (map first)
              (map (lambda (x) (first x))))))
      (remove-duplicates)))

(define (get-entry-registers controller-text)
  (~> controller-text
      (extract-labels
       (lambda (insts labels)
         (~>> insts
              (map first)
              (filter (lambda (x)
                        (eq? 'goto (first x))))
    
              (flatmap (lambda (x)
                         (filter (lambda (xx)
                                   (register-exp? xx))
                                 x)))
              (map second)
              (remove-duplicates))))))

(define (get-save-restore-registers controller-text)
  (~>  controller-text
       (extract-labels
        (lambda (insts labels)
          (~>>  insts
                (map first)
                (filter (lambda (x)
                          (or (eq? 'save (first x))
                              (eq? 'restore (first x)))))
                (map second ))))
       (remove-duplicates)))
(define (get-register-source-list controller-text)
  (~> controller-text
      (extract-labels 
       (lambda (insts labels)
         (~>> insts
              (map first)
              (filter (lambda (x)
                        (eq? 'assign (first x))))
              (map rest)
              )))
      (~>> 
       (map (lambda (x)
              (let ((reg (first x))
                    (source (rest x)))
                (list reg source)))))))
(check-equal?
 ; 1. all-instructions
 '(assign test branch save goto restore)
 
 (~> figure-5-11
     (rest)
     (get-all-instructions)))

(check-equal?
 ; 2. entry-register-set
 '(continue)

 (~> figure-5-11
     (rest)
     (get-entry-registers)))

(check-equal?
 ; 3. save-restore-registers
 '(continue n)
 
 (~>  figure-5-11
      (rest)
      (get-save-restore-registers)))

(check-equal?
 ; 4. register-source-list
 '((continue ((label fact-done)))
   (n ((op -) (reg n) (const 1)))
   (continue ((label after-fact)))
   (val ((op *) (reg n) (reg val)))
   (val ((const 1))))

 (~> figure-5-11
     (rest)
     (get-register-source-list)))


(define (make-machine register-names ops controller-text)
  (let ((machine (make-new-machine)))
    (for-each (lambda (register-name)
                ((machine 'allocate-register) register-name))
              register-names)
    ((machine 'install-operations) ops)    
    ((machine 'install-instruction-sequence)
     (assemble controller-text machine))
    
    ((machine 'install-instruction-set)           ; 1.
     (get-all-instructions controller-text))
    ((machine 'install-entry-register-set)        ; 2.
     (get-entry-registers controller-text))
    ((machine 'install-save-restore-register-set) ; 3.
     (get-save-restore-registers controller-text))
    ((machine 'install-register-source-kv-set)    ; 4.
     (get-register-source-list controller-text))
    
    machine))

(override-make-machine! make-machine)

(define machine-figure-5-11
  (make-machine
   '(n val continue)
   (list (list '= =)
         (list '- -)
         (list '* *))
   (rest figure-5-11)))

(check-equal? (machine-figure-5-11 'instruction-set)
              '(assign test branch save goto restore))
(check-equal? (machine-figure-5-11 'entry-register-set)
              '(continue))
(check-equal? (machine-figure-5-11 'save-restore-register-set)
              '(continue n))
(check-equal? ((machine-figure-5-11 'register-source-kv-set) 'set)
              '(kv-set
                (continue (((label after-fact))
                           ((label fact-done))))
                (n        (((op -) (reg n) (const 1))))
                (val      (((const 1))
                           ((op *) (reg n) (reg val))))))

(define machine-figure-5-12
  (make-machine
   '(n val continue)
   (list (list '< <)
         (list '- -)
         (list '+ +))
   (rest figure-5-12)))

(check-equal? (machine-figure-5-12 'instruction-set)
              '(assign test branch save goto restore))
(check-equal? (machine-figure-5-12 'entry-register-set)
              '(continue))
(check-equal? (machine-figure-5-12 'save-restore-register-set)
              '(continue n val))
(check-equal? ((machine-figure-5-12 'register-source-kv-set) 'set)
              '(kv-set
                (continue (((label afterfib-n-2))
                           ((label afterfib-n-1))
                           ((label fib-done))))
                (n        (((reg val))
                           ((op -) (reg n) (const 2))
                           ((op -) (reg n) (const 1))))
                (val      (((reg n))
                           ((op +) (reg val) (reg n))))))