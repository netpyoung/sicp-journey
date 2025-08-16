#lang sicp
;; file: 4_11.rkt

(#%require rackunit)
(#%require threading)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix old: "../allcode/ch4-4.1.1-mceval.rkt"))

;; - 현재 frame형태
;;   - '((symbol-a symbol-b ...) value-a (primitive func-b) ...)
;; - 바꾸고자 하는 frame형태
;;   - '((symbol-a value-a) (symbol-b (primitive func-b)) ...)
;;
;; frame관련 함수들
;; - make-frame
;; - add-binding-to-frame!
;; - frame-variables
;; - frame-values

(define frame1 (old:make-frame '(a b) '(1 2)))
(check-equal? frame1
              '((a b) 1 2))
(old:add-binding-to-frame! 'c 3 frame1)
(check-equal? frame1
              '((c a b) 3 1 2))
(check-equal? (~> (old:make-frame '(a b) '(1 2))
                  (old:frame-variables))
              '(a b))

(check-equal? (~> (old:make-frame '(a b) '(1 2))
                  (old:frame-values))
              '(1 2))
(define (make-frame variables values)
  (map list variables values))

(define (add-binding-to-frame! var val frame)
  (let ((rst (rest frame))
        (var-val (list var val)))
    (set-cdr! frame (append rst (list var-val)))))

(define (frame-variables frame)
  (map first frame))
(define (frame-values frame)
  (map second frame))

(define frame2 (make-frame '(a b) '(1 2)))
(check-equal? frame2
              '((a 1) (b 2)))
(add-binding-to-frame! 'c 3 frame2)
(check-equal? frame2
              '((a 1) (b 2) (c 3)))
(check-equal? (~> (make-frame '(a b) '(1 2))
                  (frame-variables))
              '(a b))
(check-equal? (~> (make-frame '(a b) '(1 2))
                  (frame-values))
              '(1 2))