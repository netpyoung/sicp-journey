#lang sicp
;; file: 4_29.rkt
(#%require rackunit)
(#%require threading)
(#%require profile)
(#%require (prefix racket: racket))
(racket:require (racket:prefix-in lazy: "../allcode/ch4-4.2.2-leval.rkt"))

;;
;; count/id는 4_27에서 정의된것.
;;
;; non-memoizing버전과 memoizing 버전의 결과값을 비교해라.
;;

;; non-memoizing 버전에서는 (thunk exp env) 들만 있고, 매 force-it시 thunk에서 값을 계산을 한다.
'(define (force-it-non-memoizing obj)
   (if (thunk? obj)
       (actual-value (thunk-exp obj) (thunk-env obj))
       obj))

;; 반면 memoizing버전에서는 (evaluated-thunk result) 라는게 있어, (thunk exp env) 를 한번 계산하고 캐쉬비슷하게 저장해서 다시 쓴다.
'(define (force-it-memoizing obj)
   (cond ((thunk? obj)
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

;; non-memoizing 버전
(lazy:override-force-it! lazy:force-it-non-memoizing)
(define env1 (lazy:setup-environment))
(~> '(define count 0)
    (lazy:actual-value env1)
    (check-eq? 'ok))

(~> '(define (id x)
       (set! count (+ count 1))
       x)
    (lazy:actual-value env1)
    (check-eq? 'ok))

(~> '(define (square x)
       (* x x))
    (lazy:actual-value env1)
    (check-eq? 'ok))

;; non-memoizing에서는 (id 10)이 캐쉬되지 안아 square에서 2번 호출되어 count수도 두번 증가한다.
(~> '(square (id 10))          
    (lazy:actual-value env1)
    (check-eq? 100))

(~> 'count
    (lazy:actual-value env1)
    (check-eq? 2))


;; memoizing 버전
(lazy:override-force-it! lazy:force-it-memoizing)
(define env2 (lazy:setup-environment))
(~> '(define count 0)
    (lazy:actual-value env2)
    (check-eq? 'ok))

(~> '(define (id x)
       (set! count (+ count 1))
       x)
    (lazy:actual-value env2)
    (check-eq? 'ok))

(~> '(define (square x)
       (* x x))
    (lazy:actual-value env2)
    (check-eq? 'ok))

;; memoizing에서는 (id 10)이 한번 호출되어 캐쉬되어 square에서 (* x x)라도 count수는 한번만 증가한다.
(~> '(square (id 10))
    (lazy:actual-value env2)
    (check-eq? 100))

(~> 'count
    (lazy:actual-value env2)
    (check-eq? 1))