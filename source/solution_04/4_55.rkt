#lang sicp
;; file: 4_55.rkt
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.4.4.1-query.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

(initialize-data-base microshaft-data-base)
;;  (query-driver-loop)
(~> '(job ?x (computer programmer))
    (run)
    (check-equal? '((job (Fect Cy D) (computer programmer))
                    (job (Hacker Alyssa P) (computer programmer)))))

;; 쿼리 만들어보기
;;
;; (address    {이름}     {주소})
;; (job        {이름}     ({부서} . {타이틀}))
;; (salary     {이름}     {급여})
;; (supervisor {하급자}   {상급자})
;; (can-do-job {상위직업} {하위직업})

;; 1. Ben Bitdiddle가 관리하는 모든 사람들
(~> '(supervisor ?name (Bitdiddle Ben))
    (run)
    (check-equal? '(
                    (supervisor (Tweakit Lem E) (Bitdiddle Ben))
                    (supervisor (Fect Cy D) (Bitdiddle Ben))
                    (supervisor (Hacker Alyssa P) (Bitdiddle Ben))
                    )))


;; 2. accounting 부서의 모든 사람들의 이름과 직업;
(~> '(job ?name (accounting . ?job))
    (run)
    (check-equal? '(
                    (job (Cratchet Robert) (accounting scrivener))
                    (job (Scrooge Eben) (accounting chief accountant))
                    )))

;; 3. Slumerville에 살고 있는 사람들의 이름과 주소
(~> '(address ?name (Slumerville . ?address))
    (run)
    (check-equal? '(
                    (address (Aull DeWitt) (Slumerville (Onion Square) 5))
                    (address (Reasoner Louis) (Slumerville (Pine Tree Road) 80))
                    (address (Bitdiddle Ben) (Slumerville (Ridge Road) 10))
                    )))