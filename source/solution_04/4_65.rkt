#lang sicp
;; file: 4_65.rkt
;; 4_65 / 4_66

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.4.4.1-query.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

;; Q. 왜 (Warbucks Oliver)가 4번 나오는가?
;;
;; supervisor관계도를 나타내면
;;
;; (Warbucks Oliver)               -- 0
;; ├─ (Bitdiddle Ben)              -- 1
;; │  ├─ (Hacker Alyssa P)         -- 2 **
;; │  │  └─ (Reasoner Louis)       -- 3
;; │  ├─ (Fect Cy D)               -- 2 **
;; │  └─ (Tweakit Lem E)           -- 2 **
;; ├─ (Scrooge Eben)               -- 1
;; │  └─ (Cratchet Robert)         -- 2 **
;; └─ (Aull DeWitt)                -- 1
;;
;; wheel은 supervisor의 supervisor를 찾는거니,
;; (Warbucks Oliver) 기준으로깊이가 2이상인 애들을 찾으면 4명.
;;
;;     (rule (wheel ?person)
;;           (and (supervisor ?middle-manager ?person)
;;                (supervisor ?x ?middle-manager)))


(~> microshaft-data-base
    (initialize-data-base))

(~> '(wheel ?who)
    (run)
    (check-equal? '((wheel (Warbucks Oliver))
                    (wheel (Warbucks Oliver))
                    (wheel (Bitdiddle Ben))
                    (wheel (Warbucks Oliver))
                    (wheel (Warbucks Oliver)))))
