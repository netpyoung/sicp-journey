#lang sicp
;; file: 4_56.rkt
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.4.4.1-query.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))


;; 쿼리 만들어보기

(initialize-data-base microshaft-data-base)

;; (and
;; (or
;; (not
;; (lisp-value {predicate} {arg0} ... {argn})


;; 1. Ben Bitdiddle가 관리하는 모든 사람의 이름과 주소
(~> '(and (supervisor ?name (Bitdiddle Ben))
          (address ?name ?address))
    (run)
    (check-equal? '(
                    (and (supervisor (Tweakit Lem E) (Bitdiddle Ben))
                         (address (Tweakit Lem E) (Boston (Bay State Road) 22)))
                    (and (supervisor (Fect Cy D) (Bitdiddle Ben))
                         (address (Fect Cy D) (Cambridge (Ames Street) 3)))
                    (and (supervisor (Hacker Alyssa P) (Bitdiddle Ben))
                         (address (Hacker Alyssa P) (Cambridge (Mass Ave) 78)))
                    )))


;; 2. Ben Bitdiddle 보다 salary가 적은 사람들과 급여. 그리고 Ben Bitdiddle의 급여.
(~> '(and (salary (Bitdiddle Ben) ?ben-salary)
          (salary ?name ?amount)
          (lisp-value < ?amount ?ben-salary))
    (run)
    (check-equal? '(
                    (and (salary (Bitdiddle Ben) 60000)
                         (salary (Aull DeWitt) 25000)
                         (lisp-value < 25000 60000))
                    (and (salary (Bitdiddle Ben) 60000)
                         (salary (Cratchet Robert) 18000)
                         (lisp-value < 18000 60000))
                    (and (salary (Bitdiddle Ben) 60000)
                         (salary (Reasoner Louis) 30000)
                         (lisp-value < 30000 60000))
                    (and (salary (Bitdiddle Ben) 60000)
                         (salary (Tweakit Lem E) 25000)
                         (lisp-value < 25000 60000))
                    (and (salary (Bitdiddle Ben) 60000)
                         (salary (Fect Cy D) 35000)
                         (lisp-value < 35000 60000))
                    (and (salary (Bitdiddle Ben) 60000)
                         (salary (Hacker Alyssa P) 40000)
                         (lisp-value < 40000 60000))
                    )))

;; 3. computer 부서에 속하지 않은 사람이 관리하는 모든 사람들 그리고 관리자. 이름과 job 포함.
(~> '(and (job ?supervisor-name (computer . ?x))
          (supervisor ?name ?supervisor-name)
          (job ?name . ?y)
          )
    (run)
    (check-equal? '(
                    (and (job (Hacker Alyssa P) (computer programmer))
                         (supervisor (Reasoner Louis) (Hacker Alyssa P))
                         (job (Reasoner Louis) (computer programmer trainee)))
                    (and (job (Bitdiddle Ben) (computer wizard))
                         (supervisor (Tweakit Lem E) (Bitdiddle Ben))
                         (job (Tweakit Lem E) (computer technician)))
                    (and (job (Bitdiddle Ben) (computer wizard))
                         (supervisor (Fect Cy D) (Bitdiddle Ben))
                         (job (Fect Cy D) (computer programmer)))
                    (and (job (Bitdiddle Ben) (computer wizard))
                         (supervisor (Hacker Alyssa P) (Bitdiddle Ben))
                         (job (Hacker Alyssa P) (computer programmer)))
                    )))