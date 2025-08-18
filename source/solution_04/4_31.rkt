#lang sicp
;; file: 4_31.rkt
;; 4_30

(#%require rackunit)
(#%require threading)
(#%require profile)
(#%require "../allcode/helper/my-util.rkt")

(#%require (prefix racket: racket))
(racket:require (racket:rename-in "../allcode/ch4-4.2.2-leval.rkt"
                                  (_eval-sequence lazy:eval-sequence)))

;; TODO
;; define 문법을 확장하여, 바로 평가할지, lazy-evalution인지, lazy evaluation + memoize인지 설정할 수 있도록 만들어라.

;; |---|--------------------------|
;; | f | 함수이름                 | 
;; | a | 바로 평가                | 
;; | b | lazy evaluation          | 
;; | c | 바로 평가                | 
;; | d | lazy evaluation + memoize| 
'(define (f a (b lazy) c (d lazy-memo))
   ...)

;; eval해서 eval-definition쪽은 그냥 symbol리스트를 저장하는거니 eval함수 수정은 아니고
;; (define (f a (b lazy) c (d lazy-memo)) true)
;; env=> #0=(((f ... )
;;            (procedure (a (b lazy) c (d lazy-memo)) (true) #0#)
;;            ...
;;          ))
;; 4_30과 같이 apply쪽에보면 eval-sequence / list-of-delayed-args / procedure-parameters를 고쳐야 한다.
;; 그리고 force-it 하는 부분도, eager/ lazy / lazy-memo부분을 나누어야한다.

'(define (apply procedure arguments env)
   (cond ((primitive-procedure? procedure)
          (apply-primitive-procedure
           procedure
           (list-of-arg-values arguments env)))
         ((compound-procedure? procedure)
          (eval-sequence                              ; <<<< 이 부분: eval-sequence
           (procedure-body procedure)
           (extend-environment
            (procedure-parameters procedure)          ; <<<< 이 부분: procedure-parameters
            (list-of-delayed-args arguments env)      ; <<<< 이 부분: list-of-delayed-args
            (procedure-environment procedure))))
         (else
          (error
           "Unknown procedure type -- APPLY" procedure))))

(define (procedure-parameters procedure)
  ;; (procedure-parameters '(procedure (a (b lazy) c (d lazy-memo)) (true) 'blabla-env))
  ;; => (a b c d)
  (define (darg->var darg)
    (if (list? darg)
        (first darg)
        darg))
  (let ((define-args (second procedure)))
    (map darg->var define-args)))

(define (procedure-parameter-annotations procedure)
  ;; (procedure-parameter-annotations '(procedure (a (b lazy) c (d lazy-memo)) (true) 'blabla-env))
  ;; => (eager lazy eager lazy-memo)
  (define (darg->annot darg)
    (if (list? darg)
        (second darg)
        'eager))
  (let ((define-args (second procedure)))
    (map darg->annot define-args)))

(define (delay-memo-it exp env)
  (list 'thunk-memo exp env))

;; list-of-delayed-args는 annotation다룰 자리가 없으니 list-of-new-define-args로 대처
(define (list-of-new-define-args arguments annotations env)
  ;; (list-of-new-define-args '(1 2 3 4) '(eager lazy eager lazy-memo) 'blabla-env)
  ;;=> (1 (thunk 2 blabla-env) 3 (thunk-memo 4 blabla-env))
  (define (box annot arg env)
    (cond ((eq? annot 'eager)
           (actual-value arg env))
          ((eq? annot 'lazy)
           (delay-it arg env))
          ((eq? annot 'lazy-memo)
           (delay-memo-it arg env))
          (else
           (error "annot != (eager|lazy|lazy-memo)" annot arg))))
  (define (iter acc args annots env)
    (if (null? args)
        (reverse acc)
        (let ((boxed (box (first annots) (first args) env)))
          (iter (cons boxed acc) (rest args) (rest annots) env))))
  (iter '() arguments annotations env))

(define (thunk-memo? obj)
  (tagged-list? obj 'thunk-memo))

(define (force-it-brand-new obj)
  (cond ((thunk? obj)
         (actual-value (thunk-exp obj) (thunk-env obj)))
        ((thunk-memo? obj)
         (let ((result (actual-value
                        (thunk-exp obj)
                        (thunk-env obj))))
           (set-car! obj 'evaluated-thunk)
           (set-car! (cdr obj) result)  ; replace exp with its value
           (set-cdr! (cdr obj) '())     ; forget unneeded env
           result))
        ((evaluated-thunk? obj)
         (thunk-value obj))
        (else obj)))

(define (apply-30 procedure arguments env)
  (cond ((primitive-procedure? procedure)
         (apply-primitive-procedure
          procedure
          (list-of-arg-values arguments env)))
        ((compound-procedure? procedure)
         (eval-sequence                                                                        ; <<<<
          (procedure-body procedure)
          (extend-environment
           (procedure-parameters procedure)                                                    ; <<<<
           (list-of-new-define-args arguments (procedure-parameter-annotations procedure) env) ; <<<<
           (procedure-environment procedure))))
        (else
         (error
          "Unknown procedure type -- APPLY" procedure))))

(override-procedure-parameters! procedure-parameters)
(override-force-it! force-it-brand-new)
(override-apply! apply-30)

(define env1 (setup-environment))

(~> '(define (id x)
       x)
    (actual-value env1)
    (check-equal? 'ok))
(~> '(begin
       (define var-d 0)
       (define var-c 0)
       
       (define var-b 0)
       (define var-a 0)
       
       )
    (actual-value env1)
    (check-equal? 'ok))

(~> '(define (f a (b lazy) c (d lazy-memo))
       (set! var-a a)
       (set! var-b b)
       (set! var-c c)
       (set! var-d d)
       (+ a b c d))
    (actual-value env1)
    (check-equal? 'ok))

(~> '(f (id 1) (id 2) (id 3) (id 4))
    (actual-value env1)
    (check-equal? 10))

;; env1
;; #0=(((... var-a var-b var-c var-d ...)
;;      ...
;;      1
;;      (thunk 2 #0#)
;;      3
;;      (evaluated-thunk 4)
;;      ...))

(~> '(f (id 1) (id 2) (id 3) (id 4))
    (actual-value env1)
    (check-equal? 10))

;; env1
;; #0=(((... var-a var-b var-c var-d ...)
;;      ...
;;      1
;;      (thunk (id 2) #0#)
;;      3
;;      (evaluated-thunk 4)
;;      ...))

(~> '(define (g a (b lazy) c (d lazy-memo))
       (set! var-a a)
       (set! var-b b)
       (set! var-c c)
       (set! var-d d)
       true)
    (actual-value env1)
    (check-equal? 'ok))

(~> '(g (id 1) (id 2) (id 3) (id 4))
    (actual-value env1)
    (check-equal? true))

;; env1
;; #0=(((... var-a var-b var-c var-d ...)
;;       ...
;;       1
;;      (thunk (id 2) #0#)
;;      3
;;      (thunk-memo (id 4) #0#)
;;      ...))