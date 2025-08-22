#lang sicp
;; file: 4_60.rkt
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.4.4.1-query.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))


(~> microshaft-data-base
    (initialize-data-base))

(~> '(lives-near ?person (Hacker Alyssa P))
    (run)
    (check-equal? '((lives-near (Fect Cy D) (Hacker Alyssa P)))))

(~> '(lives-near ?person-1 ?person-2)
    (run)
    (check-equal? '((lives-near (Aull DeWitt) (Reasoner Louis))      ; A
                    (lives-near (Aull DeWitt) (Bitdiddle Ben))       ; B
                    (lives-near (Reasoner Louis) (Aull DeWitt))      ; A
                    (lives-near (Reasoner Louis) (Bitdiddle Ben))    ; D
                    (lives-near (Hacker Alyssa P) (Fect Cy D))       ; ** C
                    (lives-near (Fect Cy D) (Hacker Alyssa P))       ; ** C
                    (lives-near (Bitdiddle Ben) (Aull DeWitt))       ; B
                    (lives-near (Bitdiddle Ben) (Reasoner Louis))))) ; D

;; Q. 왜 중복해서 나오는 문제가 있는가?
;;
;; (rule (lives-near ?person-1 ?person-2)
;;       (and (address ?person-1 (?town . ?rest-1))
;;            (address ?person-2 (?town . ?rest-2))
;;            (not (same ?person-1 ?person-2))))
;;
;; 룰에서 ?person-1 / ?person-2가 같지만 않으면 통과라서. 추가 제제가 없음.
;;
;; Q. 가까운데 사는데 중복이 없도록 나오게 만들 방법이 있는가?
;;
;; uid를 주입해서 활용.

(define uids
  ;; (uid {unique-id} {이름})
  '((uid 1 (Aull DeWitt))
    (uid 2 (Cratchet Robert))
    (uid 3 (Scrooge Eben))
    (uid 4 (Warbucks Oliver))
    (uid 5 (Reasoner Louis))
    (uid 6 (Tweakit Lem E))
    (uid 7 (Fect Cy D))
    (uid 8 (Hacker Alyssa P))
    (uid 9 (Bitdiddle Ben))))

(~> microshaft-data-base
    (append uids)
    (initialize-data-base))

(~> '(and (lives-near ?person-1 ?person-2)
          (uid ?uid-1 ?person-1)
          (uid ?uid-2 ?person-2)
          (lisp-value < ?uid-1 ?uid-2))
    (run)
    (check-equal?
     '((and (lives-near (Aull DeWitt) (Reasoner Louis)) (uid 1 (Aull DeWitt)) (uid 5 (Reasoner Louis)) (lisp-value < 1 5))
       (and (lives-near (Aull DeWitt) (Bitdiddle Ben)) (uid 1 (Aull DeWitt)) (uid 9 (Bitdiddle Ben)) (lisp-value < 1 9))
       (and (lives-near (Reasoner Louis) (Bitdiddle Ben)) (uid 5 (Reasoner Louis)) (uid 9 (Bitdiddle Ben)) (lisp-value < 5 9))
       (and (lives-near (Fect Cy D) (Hacker Alyssa P)) (uid 7 (Fect Cy D)) (uid 8 (Hacker Alyssa P)) (lisp-value < 7 8)))))


;; 이름정렬방식 : environment에 함수를 주입 lisp-value를 사용하여 사람 이름으로 정렬.
;;   - 이름이 중복일 경우도 있음. => 문제발생.
(let ((environment (scheme-report-environment 5))) 
  (eval
   '(begin
      (define (fold-right op init lst)
        (if (null? lst)
            init
            (op (car lst) (fold-right op init (cdr lst)))))
      
      (define (string-join lst delimiter)  
        (if (null? lst)
            ""
            (fold-right (lambda (x acc)
                          (if (string=? acc "")
                              x
                              (string-append x delimiter acc)))
                        ""
                        lst)))
      
      (define (pair->string pair)
        (string-join (map symbol->string pair) " "))
      
      (define (compare-person-name p1 p2)
        (string<? (pair->string p1)
                  (pair->string p2))))
   environment)
  (override-user-initial-environment! environment))

(~> '(and (lives-near ?person-1 ?person-2)
          (lisp-value compare-person-name ?person-1 ?person-2))
    (run)
    (check-equal? '((and (lives-near (Aull DeWitt) (Reasoner Louis))
                         (lisp-value compare-person-name (Aull DeWitt) (Reasoner Louis)))
                    (and (lives-near (Aull DeWitt) (Bitdiddle Ben))
                         (lisp-value compare-person-name (Aull DeWitt) (Bitdiddle Ben)))
                    (and (lives-near (Fect Cy D) (Hacker Alyssa P))
                         (lisp-value compare-person-name (Fect Cy D) (Hacker Alyssa P)))
                    (and (lives-near (Bitdiddle Ben) (Reasoner Louis))
                         (lisp-value compare-person-name (Bitdiddle Ben) (Reasoner Louis))))))
