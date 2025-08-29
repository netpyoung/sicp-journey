#lang racket

(#%require rackunit)
(provide (all-defined-out))

(define-syntax (overridable-define stx)
  (syntax-case stx ()
    ;; 함수 정의
    [(_ (fname arg ...) body ...)
     (let* ([fname-sym (syntax->datum #'fname)]
            [internal-name (datum->syntax stx (string->symbol (string-append "_" (symbol->string fname-sym))) #'fname)]
            [override-name (datum->syntax stx (string->symbol (string-append "override-" (symbol->string fname-sym) "!")) #'fname)])
       (with-syntax ([iname internal-name]
                     [oname override-name])
         #'(begin
             (define (iname arg ...) body ...)
             (define fname iname)
             (define (oname func) (set! fname func)))))]

    ;; 값 정의
    [(_ fname value)
     (let* ([fname-sym (syntax->datum #'fname)]
            [internal-name (datum->syntax stx (string->symbol (string-append "_" (symbol->string fname-sym))) #'fname)]
            [override-name (datum->syntax stx (string->symbol (string-append "override-" (symbol->string fname-sym) "!")) #'fname)])
       (with-syntax ([iname internal-name]
                     [oname override-name])
         #'(begin
             (define iname value)
             (define fname iname)
             (define (oname new-value) (set! fname new-value)))))]))

;; (overridable-define (hello x)
;;   (+ x 1))
;; ==>
;; (define (_hello x)
;;   (+ x 1)
;; (define hello _hello)
;; (define (override-hello! func)
;;   (set! hello func))


(define-syntax-rule
  (check-output? expected body ...)
  (let ([actual (with-output-to-string (lambda () body ...))])
    (check-equal? actual expected)))