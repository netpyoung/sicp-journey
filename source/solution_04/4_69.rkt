#lang sicp
;; file: 4_69.rkt
;; 2_17 / 4_62 / 4_63 / 4_69

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

(#%require "../allcode/ch4-4.4.4.1-query.rkt")

;; 연습문제 4.63에서 만든 데이터베이스와 규칙을 시작으로, 손자 관계에 “great”를 추가하는 규칙을 고안하시오.
;; 이 규칙은 시스템이 Irad가 Adam의 2대 손자(great-grandson)임을 추론하거나, Jabal과 Jubal이 Adam의 6대 손자(great-great-great-great-great-grandson)임을 추론할 수 있도록 해야 합니다.
;; 
;; 힌트: 예를 들어, Irad에 대한 사실을 ((great grandson) Adam Irad)로 표현하시오.
;;       리스트가 grandson이라는 단어로 끝나는지 판단하는 규칙을 작성하시오.
;;       이를 사용하여 (?rel이 grandson으로 끝나는 리스트일 때)
;;       ((great . ?rel) ?x ?y) 관계를 도출하는 규칙을 표현하시오.
;;
;; ((great grandson) ?g ?ggs)나 (?relationship Adam Irad)와 같은 질의에서 규칙을 확인하시오.
;;
;;                               Grandson :     손자
;;                         Great-grandson : 2대 손자
;;                   Great-great-grandson : 3대 손자
;;             Great-great-great-grandson : 4대 손자
;;       Great-great-great-great-grandson : 5대 손자
;; Great-great-great-great-great-grandson : 6대 손자

(racket:require (racket:only-in "4_62.rkt"
                                rules-last-pair))
(racket:require (racket:only-in "4_63.rkt"
                                Genesis-4
                                rules-find-grandson
                                rules-find-son))

(define rules-relationship-of-grandson
  '(
    
    ;; ((great {손자 관계}) {?대 조상} {?대 손자})
    (rule ((grandson) ?x ?y)
          (find-grandson ?x ?y))
    
    (rule ((great . ?rel) ?x ?y)
          (and (find-son ?x ?x-son)
               (?rel ?x-son ?y)
               (last-pair ?rel (grandson))))
    ))


(~> microshaft-data-base
    (append Genesis-4)
    (append rules-find-son)
    (append rules-find-grandson)
    (append rules-last-pair)
    (append rules-relationship-of-grandson)
    (initialize-data-base))

(~> '((great grandson) ?x Irad)
    (run)
    (check-equal? '(
                    ((great grandson) Adam Irad)
                    )))

(~> '((great grandson) ?g ?ggs)
    (run)
    (check-equal? '(
                    ((great grandson) Mehujael Jubal)
                    ((great grandson) Irad Lamech)
                    ((great grandson) Mehujael Jabal)
                    ((great grandson) Enoch Methushael)
                    ((great grandson) Cain Mehujael)
                    ((great grandson) Adam Irad)
                    )))

(~> '(?relationship Adam Irad)
    (run)
    (check-equal? '(
                    ((great grandson) Adam Irad)
                    )))

(~> '(?relationship Adam Jubal)
    (run)
    (check-equal? '(
                    ((great great great great great grandson) Adam Jubal)
                    )))

(~> '((great great great great great grandson) Adam ?x)
    (run)
    (check-equal? '(
                    ((great great great great great grandson) Adam Jubal)
                    ((great great great great great grandson) Adam Jabal)
                    )))
