#lang sicp
;; file: 4_59.rkt
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.4.4.1-query.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))


;; 쿼리 만들어보기

(define rows
  '(
    ;; (meeting {부서} ({요일} {시간}))
    (meeting accounting (Monday 9am))
    (meeting administration (Monday 10am))
    (meeting computer (Wednesday 3pm))
    (meeting administration (Friday 1pm))

    ;; 모든 사원 참석.
    (meeting whole-company (Wednesday 4pm))
    ))

;; a. 금요일 아침에 Ben은 그 날에 있는 모든 회의를 찾으려 한다.
(~> microshaft-data-base
    (append rows)
    (initialize-data-base))

(~> '(meeting ?division (Friday ?time))
    (run)
    (check-equal? '((meeting administration (Friday 1pm)))))

;; b. 자기 이름으로 자기가 참석해야할 모든 회의를 뽑는 룰을 만들어라.
(define rule-meeting-time
  '(rule (meeting-time ?person ?day-and-time)
         (and (job ?person (?division . ?title))
              (or (meeting ?division ?day-and-time)
                  (meeting whole-company ?day-and-time))))
  )

(~> microshaft-data-base
    (append rows)
    (append (list rule-meeting-time))
    (initialize-data-base))

;; c. 수요일에 Alyssa는 그 날 참석해야할 회의를 찾으려 한다.

(~> '(and (meeting ?div (Wednesday . ?time))
          (meeting-time (Hacker Alyssa P) (Wednesday . ?time)))
    (run)
    (check-equal? '((and (meeting whole-company (Wednesday 4pm))
                         (meeting-time (Hacker Alyssa P) (Wednesday 4pm)))
                    (and (meeting computer (Wednesday 3pm))
                         (meeting-time (Hacker Alyssa P) (Wednesday 3pm))))))