#lang sicp
;; file: 4_18.rkt
;; 4_06 / 4_16 / 4_20 cont

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix racket: racket))
(#%require (prefix trace: racket/trace))

(racket:require (racket:rename-in "../allcode/ch4-4.1.1-mceval.rkt"
                                  (_make-procedure origin/make-procedure)
                                  (_procedure-body origin/procedure-body)))
(racket:require (racket:prefix-in ex4_06/ "4_06.rkt"))
(racket:require (racket:prefix-in ex4_16/ "4_16.rkt"))

;; - before
;; (lambda <vars>
;;  (define u <e1>)
;;  (define v <e2>)
;;  <e3>)
;;
;; - 본문방식
;; (lambda <vars>
;;  (let ((u '*unassigned*)
;;        (v '*unassigned*))
;;    (set! u <e1>)
;;    (set! v <e2>)
;;    <e3>)))
;;
;; - 이번 문제 방식
;;   - 여기서 a와 b는 인터프리터가 새로 생성한 변수명으로, 사용자의 원래 프로그램에는 등장하지 않는다.
;; (lambda <vars>
;;  (let ((u '*unassigned*)
;;        (v '*unassigned*))
;;    (let ((a <e1>)
;;          (b <e2>))
;;      (set! u a)
;;      (set! v b))
;;    <e3>))
;;
;; 3.5.4의 solve는
;; (define (solve f y0 dt)
;;  (define y (integral (delay dy) y0 dt))
;;  (define dy (stream-map f y))
;;  y)
;;
;; - 본문방식이면
;; (let ((y '*unassigned*)
;;       (dy '*unassigned*))
;;   (set! y (integral (delay dy) y0 dt))
;;   (set! dy (stream-map f y))          ; <---- dy에 제대로 된 값이 저장된다.
;;   (+ u v x)))
;;
;; - 이번 문제 방식에서는 이렇게 변환된다.
;; (let ((y '*unassigned*)
;;       (dy '*unassigned*))
;;   (let ((a (integral (delay dy) y0 dt))
;;         (b (stream-map f y)))         ; <---- b에 (stream-map f '*unassigned*)라는 올바르지 않은 값이 저장되고, 4_16을 구현했으면 y를 가져다 쓰는 순간 에러.
;;     (set! y a)
;;     (set! dy b))                      ; <---- 최종적으로 dy에 제대로 되지않은 b값이 저장된다.
;;   (+ u v x)))


(define (filter predicate sequence)
  (cond ((null? sequence) nil)
        ((predicate (car sequence))
         (cons (car sequence)
               (filter predicate 
                       (cdr sequence))))
        (else  (filter predicate 
                       (cdr sequence)))))

(define (take n lst)
  (define (iter n lst acc)
    (cond
      ((or (<= n 0) (null? lst))
       (reverse acc))
      (else
       (iter (- n 1) (cdr lst) (cons (car lst) acc)))))
  (iter n lst '()))


(define (complement f)
  (lambda (x)
    (not (f x))))

(define (make-let bindings body)
  ;; (make-let '((a 1)) '((+ a 2)))
  ;; => (let ((a 1)) (+ a 2))
  (append (list 'let bindings) body))

(define (scan-out-defines-4_18 body)
  (let ((defs (filter definition? body)))
    (if (null? defs)
        body
        (let* ((body-without-defs (filter (complement definition?) body))
               (vars (map definition-variable defs))
               (vals (map definition-value defs))
               (len (length vars))
               (var2 (take len '(a b c d e f g)))
               (bindings (map (lambda (x) (list x ''*unassigned*)) vars))
               (bindings2 (map (lambda (x y) (list x y)) var2 vals))
               (assigns (map (lambda (x y) (list 'set! x y)) vars var2)))
          (list (make-let bindings
                          (append (list (make-let bindings2
                                                  assigns))
                                  body-without-defs)))))))


(check-equal? (scan-out-defines-4_18 (lambda-body '(lambda (x)
                                                     (define u 1)
                                                     (define v (+ 2 u))
                                                     (+ u v x))))
              '((let ((u '*unassigned*)
                      (v '*unassigned*))
                  (let ((a 1)
                        (b (+ 2 u)))
                    (set! u a)
                    (set! v b))
                  (+ u v x))))



(define env2 (setup-environment))
(define env3 (setup-environment))
(define-variable! '+ (list 'primitive +) env2)
(define-variable! '+ (list 'primitive +) env3)

(override-lookup-variable-value! ex4_16/lookup-variable-value)

(around
 (begin
   (define (make-procedure parameters body env)
     ;; 4_06에서 ((let? exp) (eval (let->combination exp) env)) 을
     ;; 추가 했다면.
     ;; (list 'procedure parameters (scan-out-defines-4_18 body) env)
     ;;
     ;; 추가하지 않았다면,
     (list 'procedure parameters
           (map (lambda (x)
                  (if (ex4_06/let? x)
                      (ex4_06/let->combination x)
                      x))
                (scan-out-defines-4_18 body))
           env))
   (override-make-procedure! make-procedure)
   (override-procedure-body! origin/procedure-body))
  
 
 (test-case "make-procedure"
            (check-equal? (eval '(define (hello x)
                                   (define u 1)
                                   (define v (+ 2 u))
                                   (+ u v x))
                                env2)
                          'ok)

            (check-exn #rx"Unssigned variable u"
                       (lambda ()
                         (eval '(hello 3) env2)))
            )
 (begin
   (override-make-procedure! origin/make-procedure)
   (override-procedure-body! origin/procedure-body)))