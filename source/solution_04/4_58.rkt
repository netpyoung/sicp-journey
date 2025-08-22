#lang sicp
;; file: 4_58.rkt
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.4.4.1-query.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

;; 쿼리 만들어보기
;; 다음 조건을 만족하는 규칙을 정의하시오:
;; - 한 사람이 부서에서 "중요 인물(big shot)"로 간주되려면
;;   - 그 사람이 해당 부서에서 일하고,
;;   - 그 부서에서 일하는 상사가 없어야 한다.


(define rule-bigshot
  '(rule (bigshot ?person ?division)
         (and (job ?person (?division . ?title-1))               ;;  - 그 사람이 해당 부서에서 일하고,
              (not (and (job ?supervisor (?division . ?title-2)) ;;  - 그 부서에서 일하는 상사가 없어야 한다.
                        (supervisor ?person ?supervisor))))))

(~>> (list rule-bigshot)
     (append microshaft-data-base)
     (initialize-data-base))

(~> '(bigshot ?person ?division)
    (run)
    (check-equal? '((bigshot (Scrooge Eben) accounting)
                    (bigshot (Warbucks Oliver) administration)
                    (bigshot (Bitdiddle Ben) computer))))