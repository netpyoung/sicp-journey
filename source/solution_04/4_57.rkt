#lang sicp
;; file: 4_57.rkt
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.4.4.1-query.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))


;; 쿼리 만들어보기

(initialize-data-base microshaft-data-base)
;; (rule {패턴} {질의문})

;; (rule (lives-near ?person-1 ?person-2)   : 주변에 사는가?
;; (rule (same ?x ?x))                      : 같은가?
;; (rule (wheel ?person)                    : supervisor의 supervisor
;; (rule (outranked-by ?staff-person ?boss) : ?boss가 관리하는 자(?staff-person)인가?

(~> '(lives-near ?x (Bitdiddle Ben))
    (run)
    (check-equal? '((lives-near (Aull DeWitt) (Bitdiddle Ben))
                    (lives-near (Reasoner Louis) (Bitdiddle Ben)))))

(~> '(and (job ?x (computer programmer))
          (lives-near ?x (Bitdiddle Ben)))
    (run)
    (check-equal? '()))


;;  정의한 규칙을 사용하여 다음을 찾는 질의를 작성하시오:
;; - 사람 1이 사람 2를 대체할 수 있으려면,
;;   - 사람 1이 사람 2와 같은 직업을 가지거나,
;;   - 사람 1의 직업을 가진 누군가가 사람 2의 직업도 수행할 수 있어야 하며,
;;   - 사람 1과 사람 2가 동일한 사람이 아니어야 한다.

(define rule-can-replace
  '(rule (can-replace ?person-Replacer ?person-Replaced)
         (and (job ?person-Replacer ?job-1)
              (job ?person-Replaced ?job-2)
              (or
               (same       ?job-1 ?job-2)      ;;   - 사람 1이 사람 2와 같은 직업을 가지거나,
               (can-do-job ?job-1 ?job-2)      ;;   - 사람 1의 직업을 가진 누군가가 사람 2의 직업도 수행할 수 있어야 하며,
               )
              (not (same ?person-Replacer ?person-Replaced)) ;;   - 사람 1과 사람 2가 동일한 사람이 아니어야 한다.
              )))

(~>> (list rule-can-replace)
     (append microshaft-data-base)
     (initialize-data-base))

;; a. Cy D. Fect을 대신할 수 있는 모든 사람들.
(~> '(can-replace ?person (Fect Cy D))
    (run)
    (check-equal? '(
                    (can-replace (Bitdiddle Ben) (Fect Cy D))
                    (can-replace (Hacker Alyssa P) (Fect Cy D))
                    )))

;; b. 보다 급여를 많이 받는 사람을 대신할 수 있는 후보목록(대체할 수 있는 사람과 대채자 그리고 급여와 같이)
(~> '(and (can-replace ?person-1 ?person-2)
          (salary ?person-1 ?salary-1)
          (salary ?person-2 ?salary-2)
          (lisp-value < ?salary-1 ?salary-2))
    (run)
    (check-equal? '((and (can-replace (Aull DeWitt) (Warbucks Oliver))
                         (salary (Aull DeWitt) 25000)
                         (salary (Warbucks Oliver) 150000)
                         (lisp-value < 25000 150000))
                    (and (can-replace (Fect Cy D) (Hacker Alyssa P))
                         (salary (Fect Cy D) 35000)
                         (salary (Hacker Alyssa P) 40000)
                         (lisp-value < 35000 40000)))))