#lang sicp
;; file: 4_68.rkt
;; 2_18 / 4_67 / 4_68

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

(#%require "../allcode/ch4-4.4.4.1-query.rkt")

;; Q. 연습문제 2.18의 reverse를 rule로 만들어 봐라. (힌트, append-to-form 활용)
;;

(define rules-append-to-form
  '(
    ;; (append-to-form ?x ?y ?z) : ?x 랑 ?y를 합쳐서 ?z만들기.
    ;; (append-to-form (a b) (c d) ?z)
    ;;=> ((append-to-form (a b) (c d) (a b c d)))
    (rule (append-to-form () ?y ?y))

    (rule (append-to-form (?u . ?v) ?y (?u . ?z))
          (append-to-form ?v ?y ?z))

    ))

(define rules-reverse
  '(
    ;; (reverse ?x ?reversed) : ?x를 받아 뒤집어서 ?reversed.
    ;; (reverse (1 2 3) ?x)
    ;;=> ((reverse (1 2 3) (3 2 1)))
    (rule (reverse () ()))

    (rule (reverse (?first . ?rest) ?reversed)
          (and (reverse ?rest ?rest-reversed)
               (append-to-form ?rest-reversed (?first) ?reversed)))

    ))

(~> microshaft-data-base
    (append rules-append-to-form)
    (append rules-reverse)
    (initialize-data-base))

(~> '(reverse () ?x)
    (run)
    (check-equal? '((reverse () ()))))

(~> '(reverse (1) ?x)
    (run)
    (check-equal? '((reverse (1) (1)))))

(~> '(reverse (1 2 3) ?x)
    (run)
    (check-equal? '((reverse (1 2 3) (3 2 1)))))


(~> '(reverse ?x (1 2 3))
    (run)
    (check-equal? '((reverse (1 2 3) (3 2 1)))))

;; 무한루프
;;
;; (~> '(reverse (1 2 3) ?x)
;;     (run)
;;     (check-equal? '((reverse (1 2 3) (3 2 1)))))

;; TODO Q. (reverse (1 2 3) ?x) 과 (reverse ?x (1 2 3)) 에 모두 답할 수 있는가?
;;
;; (reverse ?x (1 2 3))는 무한 루프.
