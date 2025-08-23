#lang sicp
;; file: 4_61.rkt
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.4.4.1-query.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))


(define rules-append-to-form
  '(
    ;; (append-to-form ?x ?y ?z) : ?x 랑 ?y를 합쳐서 ?z만들기.
    ;; (append-to-form (a b) (c d) ?z)
    ;;=> ((append-to-form (a b) (c d) (a b c d)))
    
    (rule (append-to-form () ?y ?y))

    (rule (append-to-form (?u . ?v) ?y (?u . ?z))
          (append-to-form ?v ?y ?z))
    ))

(~> microshaft-data-base
    (append rules-append-to-form)
    (initialize-data-base))

(~> '(append-to-form (a b) (c d) ?z)
    (run)
    (check-equal? '((append-to-form (a b) (c d) (a b c d)))))

(~> '(append-to-form (a b) ?y (a b c d))
    (run)
    (check-equal? '((append-to-form (a b) (c d) (a b c d)))))

(~> '(append-to-form ?x ?y (a b c d))
    (run)
    (check-equal? '((append-to-form (a b c d) () (a b c d))
                    (append-to-form () (a b c d) (a b c d))
                    (append-to-form (a) (b c d) (a b c d))
                    (append-to-form (a b) (c d) (a b c d))
                    (append-to-form (a b c) (d) (a b c d)))))


;; 쿼리 만들어보기
(define rules-next-to
  '(
    ;; (?x next-to ?y in ?z) : ?z에서 붙어있는 ?x / ?y 찾기
    (rule (?x next-to ?y in (?x ?y . ?u)))
    
    (rule (?x next-to ?y in (?v . ?z))
          (?x next-to ?y in ?z))
    ))

(~> microshaft-data-base
    (append rules-next-to)
    (initialize-data-base))

(~> '(?x next-to ?y in (1 (2 3) 4))
    (run)
    (check-equal? '(((2 3) next-to 4 in (1 (2 3) 4))
                    (1 next-to (2 3) in (1 (2 3) 4)))))


(~> '(?x next-to 1 in (2 1 3 1))
    (run)
    (check-equal? '((3 next-to 1 in (2 1 3 1))
                    (2 next-to 1 in (2 1 3 1)))))