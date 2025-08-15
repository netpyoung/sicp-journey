#lang sicp
;; file: 4_23.rkt
(#%require (prefix racket/ racket))
(#%require (prefix trace/ racket/trace))
(#%require rackunit)
(racket/require "4_06.rkt")
(racket/require (racket/except-in "../allcode/ch4-4.1.1-mceval.rkt" eval))
(racket/require (racket/rename-in "../allcode/ch4-4.1.7-analyzingmceval.rkt"
                                  (_analyze origin/analyze)
                                  (_analyze-sequence origin/analyze-sequence)))
;;
;; Q. analyze-sequence의 본문 버전과, Alyssa의 버전을 비교. expr가 2개인 경우, 1개인 경우 어떻게 돌아가는지 비교해라.
;;
;; ver. Original
(define (analyze-sequence-original exps)
  (define (sequentially proc1 proc2)
    (lambda (env)
      (proc1 env)
      (proc2 env)))
  (define (loop first-proc rest-procs)
    (if (null? rest-procs)
        first-proc
        (loop (sequentially first-proc (car rest-procs))
              (cdr rest-procs))))
  (let ((procs (map analyze exps)))
    (if (null? procs)
        (error "Empty sequence -- ANALYZE"))
    (loop (car procs) (cdr procs))))

;; ver. Alyssa P. Hacker
(define (analyze-sequence-alyssa exps)
  (define (execute-sequence procs env)
    (cond ((null? (cdr procs))
           ((car procs) env))
          (else
           ((car procs) env)
           (execute-sequence (cdr procs) env))))
  (let ((procs (map analyze exps)))
    (if (null? procs)
        (error "Empty sequence -- ANALYZE"))
    (lambda (env)
      (execute-sequence procs env))))


;; 2개 버전, 1개 버전을 비교하라 했지만, 2개 보다 3개가 좀 더 알기 편할꺼임.
;;
;; 3개버전이라고 하면 procs가 (a1 a2 a3)가 되고
;;
;; ver. Original
;; procs의 리스트 순회를 미리 해버림 없음. lambda로 펼쳐져 있게됨.
;; (lambda (env)
;;   ((lambda (env)
;;      (a1 env)
;;      (a2 env))
;;    env)
;;  (a3 env))
;;
;; ver. Alyssa P. Hacker
;; execute-sequence를 통한 procs 리스트 순회를 하게됨.
;; (lambda (env)
;;   처음꺼 꺼내오고(execute-sequence)
;;   (a1 env)
;;   다음꺼 꺼내오고(execute-sequence)
;;   (a2 env)
;;   다음꺼 꺼내오고(execute-sequence)
;;   (a3 env)
;;   )
;;
;; 1개버전이라고 하면 procs가 (a1)가 되고
;;
;; ver. Original
;; 1개인 경우 그냥 원래것이 빠져나오게 됨.
;; a1
;;
;; ver. Alyssa P. Hacker
;; execute-sequence를 통한 procs 리스트 순회를 하게됨.
;; (lambda (env)
;;   처음꺼 꺼내오고(execute-sequence)
;;   (a1 env)
;;   )

