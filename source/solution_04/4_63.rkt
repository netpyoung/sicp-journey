#lang sicp
;; file: 4_63.rkt
;; 2_17 / 4_62 / 4_63 / 4_69

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.4.4.1-query.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

(racket:provide
 Genesis-4
 rules-find-grandson
 rules-find-son
 )

(define Genesis-4
  '(
    ;; 창세기 4 족보
    ;;
    ;; 아담(Adam)
    ;; └── 가인(Cain)
    ;;     └── 에녹(Enoch)
    ;;         └── 이라드(Irad)
    ;;             └── 므후야엘(Mehujael)
    ;;                 └── 므드사엘(Methushael)
    ;;                     └── 라멕(Lamech) + 아다(Adah)
    ;;                         ├── 야발(Jabal)
    ;;                         └── 유발(Jubal)
    
    ;; (son {부모} {아들})
    ;; (wife {남편} {아내})

    (son Adam Cain)
    (son Cain Enoch)
    (son Enoch Irad)
    (son Irad Mehujael)
    (son Mehujael Methushael)
    (son Methushael Lamech)
    (wife Lamech Ada)
    (son Ada Jabal)
    (son Ada Jubal)
    ))

;; Q. 규칙을 만들어라
;;
;; - S가 f의 아들이고, f가 G의 아들이면, S는 G의 손자이다
;; - W가 M의 아내이고, S가 W의 아들이면, S는 M의 아들이다.

(define rules-find-grandson
  '(
    ;; (find-grandson {조부모} {손자})
    (rule (find-grandson ?G ?S)   ; S는 G의 손자이다
          (and (find-son ?f ?S)   ; S가 f의 아들이고, 
               (find-son ?G ?f))) ; f가 G의 아들이면,
    )
  )

(define rules-find-son
  '(
    ;; (find-son {부모} {아들})
    (rule (find-son ?M ?S)        ; S는 M의 아들이다.
          (or (son ?M ?S)
              (and (wife ?M ?W)   ; W가 M의 아내이고, 
                   (son ?W ?S)))) ; S가 W의 아들이면,
    ))

;; Q. Cain의 손자 / Lamech의 아들들 / Methushael의 손자들을 찾아내는 쿼리 만들어라.

(~> microshaft-data-base
    (append Genesis-4)
    (append rules-find-grandson)
    (append rules-find-son)
    (initialize-data-base))

(~> '(find-grandson Cain ?grandson)
    (run)
    (check-equal? '((find-grandson Cain Irad))))


(~> '(find-son Lamech ?son)
    (run)
    (check-equal? '((find-son Lamech Jubal)
                    (find-son Lamech Jabal))))

(~> '(find-grandson Methushael ?grandson)
    (run)
    (check-equal? '((find-grandson Methushael Jubal)
                    (find-grandson Methushael Jabal))))
    
