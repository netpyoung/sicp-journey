#lang sicp
;; file: 4_24.rkt

;; 이전 버전의 evaluator와 이번 단락에서 소개한 버전(analyze)을 속도 측면에서 비교하기 위한 몇 가지 실험을 설계하고 수행하라.
;; 그 결과를 이용하여, 다양한 프로시저에 대해 분석 단계와 실행 단계 각각에 소요되는 시간의 비율을 추정하라.
(#%require profile)
(#%require (prefix racket: racket))
(racket:require (racket:rename-in "../allcode/ch4-4.1.1-mceval.rkt"
                                  (_eval origin/eval)))
(racket:require (racket:rename-in "../allcode/ch4-4.1.7-analyzingmceval.rkt"
                                  (eval next/eval)))

;; profile-thunk
;; https://docs.racket-lang.org/profile/index.html#%28def._%28%28lib._profile%2Fmain..rkt%29._profile-thunk%29%29

;; time - https://docs.racket-lang.org/reference/time.html#%28form._%28%28lib._racket%2Fprivate%2Fmore-scheme..rkt%29._time%29%29

;; current-inexact-monotonic-milliseconds - https://docs.racket-lang.org/reference/time.html#%28def._%28%28quote._~23~25kernel%29._current-inexact-monotonic-milliseconds%29%29
;; current-inexact-milliseconds
;; current-monotonic-nanoseconds -  https://docs.racket-lang.org/monotonic/index.html

(define expr
  
  '(define (fib n)
     (define (fib-iter a b count)
       (if (= count 0)
           b
           (fib-iter (+ a b) a (- count 1))))
     (fib-iter 1 0 n))

  )

(override-eval! origin/eval)
(define env2 (setup-environment))
(define-variable! '+ (list 'primitive +) env2)
(define-variable! '- (list 'primitive -) env2)
(define-variable! '= (list 'primitive =) env2)
(eval expr env2)
(profile-thunk
 (lambda ()
   
   (eval '(fib 5000) env2)
   )
 #:repeat 99)

(override-eval! next/eval)
(define env3 (setup-environment))
(define-variable! '+ (list 'primitive +) env3)
(define-variable! '- (list 'primitive -) env3)
(define-variable! '= (list 'primitive =) env3)
(eval expr env3) 
(profile-thunk
 (lambda ()
   (eval '(fib 5000) env3)
   )
 #:repeat 99)

(racket:time (eval '(fib 5000) env3))