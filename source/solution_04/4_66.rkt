#lang sicp
;; file: 4_66.rkt
;; 4_65 / 4_66
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.4.4.1-query.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))



;; Ben은 쿼리 시스템을 일반화 시키고 있음.  새로운 시스템은 다음과 같은 형태의 표현을 허용하도록 만들고 싶음.
;;
;; (accumulation-function {variable}
;;                        {query pattern})
;;
;; ex. 모든이들의 급의여 합.
;; (sum ?amount
;;      (and (job ?x (computer programmer))
;;           (salary ?x ?amount)))
;;
;; 하지만 연습문제 4.65에서 wheel결과를 보고 Ben은 좌절에 빠짐.
;;
;; Q. Ben이 깨닫은 것은?
;;
;; 기존 쿼리 시스템에서 중복이 나올 가능성이 있음. 이 중복으로 계산의 결과가 올바르지 못하게 될 경우가 있음.
;;

(~> microshaft-data-base
    (initialize-data-base))

(~> '(and (wheel (Warbucks Oliver))
          (salary ?x ?amount))
    (run)
    (check-equal? '((and (wheel (Warbucks Oliver)) (salary (Aull DeWitt) 25000))
                    (and (wheel (Warbucks Oliver)) (salary (Aull DeWitt) 25000))
                    (and (wheel (Warbucks Oliver)) (salary (Cratchet Robert) 18000))
                    (and (wheel (Warbucks Oliver)) (salary (Aull DeWitt) 25000))
                    (and (wheel (Warbucks Oliver)) (salary (Scrooge Eben) 75000))
                    (and (wheel (Warbucks Oliver)) (salary (Cratchet Robert) 18000))
                    (and (wheel (Warbucks Oliver)) (salary (Warbucks Oliver) 150000))
                    (and (wheel (Warbucks Oliver)) (salary (Aull DeWitt) 25000))
                    (and (wheel (Warbucks Oliver)) (salary (Reasoner Louis) 30000))
                    (and (wheel (Warbucks Oliver)) (salary (Scrooge Eben) 75000))
                    (and (wheel (Warbucks Oliver)) (salary (Tweakit Lem E) 25000))
                    (and (wheel (Warbucks Oliver)) (salary (Cratchet Robert) 18000))
                    (and (wheel (Warbucks Oliver)) (salary (Fect Cy D) 35000))
                    (and (wheel (Warbucks Oliver)) (salary (Warbucks Oliver) 150000))
                    (and (wheel (Warbucks Oliver)) (salary (Hacker Alyssa P) 40000))
                    (and (wheel (Warbucks Oliver)) (salary (Cratchet Robert) 18000))
                    (and (wheel (Warbucks Oliver)) (salary (Bitdiddle Ben) 60000))
                    (and (wheel (Warbucks Oliver)) (salary (Reasoner Louis) 30000))
                    (and (wheel (Warbucks Oliver)) (salary (Scrooge Eben) 75000))
                    (and (wheel (Warbucks Oliver)) (salary (Tweakit Lem E) 25000))
                    (and (wheel (Warbucks Oliver)) (salary (Scrooge Eben) 75000))
                    (and (wheel (Warbucks Oliver)) (salary (Fect Cy D) 35000))
                    (and (wheel (Warbucks Oliver)) (salary (Warbucks Oliver) 150000))
                    (and (wheel (Warbucks Oliver)) (salary (Hacker Alyssa P) 40000))
                    (and (wheel (Warbucks Oliver)) (salary (Warbucks Oliver) 150000))
                    (and (wheel (Warbucks Oliver)) (salary (Bitdiddle Ben) 60000))
                    (and (wheel (Warbucks Oliver)) (salary (Reasoner Louis) 30000))
                    (and (wheel (Warbucks Oliver)) (salary (Reasoner Louis) 30000))
                    (and (wheel (Warbucks Oliver)) (salary (Tweakit Lem E) 25000))
                    (and (wheel (Warbucks Oliver)) (salary (Tweakit Lem E) 25000))
                    (and (wheel (Warbucks Oliver)) (salary (Fect Cy D) 35000))
                    (and (wheel (Warbucks Oliver)) (salary (Fect Cy D) 35000))
                    (and (wheel (Warbucks Oliver)) (salary (Hacker Alyssa P) 40000))
                    (and (wheel (Warbucks Oliver)) (salary (Hacker Alyssa P) 40000))
                    (and (wheel (Warbucks Oliver)) (salary (Bitdiddle Ben) 60000))
                    (and (wheel (Warbucks Oliver)) (salary (Bitdiddle Ben) 60000)))))

;; Q. 이 상황을 해결하기 위해선?
;;
;; 중복된 결과를 유니크한 결과로 바꿀 메커니즘이 필요.
