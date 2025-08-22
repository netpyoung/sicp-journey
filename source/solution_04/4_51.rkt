#lang sicp
;; file: 4_51.rkt
;; 4_51 / 4_52 / 4_53
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.3.3-ambeval.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

(racket:provide
 ;;    ((permutation-set? exp) (analyze-permutation-set exp))   ;**
 permutation-set? analyze-permutation-set)

;; 실패로 끝나더라도 값을 유지하는, permutation-set! 구현하라.
;;
;; permanent-set! 말고 set! 을 썼다면 어 떤 값이 나오는가?
;;

(define (permutation-set? exp)
  (tagged-list? exp 'permanent-set!))

(define (analyze-permutation-set exp)
  (let ((var (assignment-variable exp))
        (vproc (analyze (assignment-value exp))))
    (lambda (env succeed fail)
      (vproc env
             ;; before: analyze-assignment
             ;; (lambda (val fail2)        ; *1*
             ;;   (let ((old-value (lookup-variable-value var env)))
             ;;     (set-variable-value! var val env)
             ;;     (succeed 'ok
             ;;              (lambda ()    ; *2*
             ;;                (set-variable-value! var old-value env)
             ;;                (fail2)))))
             ;;
             ;; after: analyze-permutation-set
             ;; analyze-assignment에서 old-value를 저장해서 덮어쓰는 로직 제거.
             (lambda (val fail2)
               (set-variable-value! var val env)
               (succeed 'ok fail2))
             fail))))

(define (analyze exp)
  (cond ((self-evaluating? exp) 
         (analyze-self-evaluating exp))
        ((quoted? exp) (analyze-quoted exp))
        ((variable? exp) (analyze-variable exp))
        ((assignment? exp) (analyze-assignment exp))
        ((permutation-set? exp) (analyze-permutation-set exp))   ;**
        ((definition? exp) (analyze-definition exp))
        ((if? exp) (analyze-if exp))
        ((lambda? exp) (analyze-lambda exp))
        ((begin? exp) (analyze-sequence (begin-actions exp)))
        ((cond? exp) (analyze (cond->if exp)))
        ((let? exp) (analyze (let->combination exp)))
        ((amb? exp) (analyze-amb exp))
        ((application? exp) (analyze-application exp))
        (else
         (error "Unknown expression type -- ANALYZE" exp))))

(override-analyze! analyze)

;; ======================================

(define env3 (setup-environment))
(~> '(begin
       (define (require p)
         (if (not p)
             (amb)))
       (define (an-element-of items)
         (require (not (null? items)))
         (amb (car items) (an-element-of (cdr items))))
       )
    (run env3)
    (check-equal? 'ok))

(~> '(begin
       ;; set! 테스트
       (define count 0)
       
       (let ((x (an-element-of '(a b c)))
             (y (an-element-of '(a b c))))
         
         (set! count (+ count 1)) ;;(permanent-set! count (+ count 1))
         (require (not (eq? x y)))
         (list x y count)))
    (runs env3)
    (check-equal? '((a b 1) (a c 1) (b a 1) (b c 1) (c a 1) (c b 1)))
    )


(~> '(begin
       ;; permanent-set! 테스트
       
       (define count 0)
       
       (let ((x (an-element-of '(a b c)))
             (y (an-element-of '(a b c))))
         (permanent-set! count (+ count 1))
         (require (not (eq? x y)))
         (list x y count)))
    (runs env3)
    (check-equal? '((a b 2) (a c 3) (b a 4) (b c 6) (c a 7) (c b 8))))