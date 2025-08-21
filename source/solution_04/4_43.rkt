#lang sicp
;; file: 4_43.rkt
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.3.3-ambeval.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

;; This is taken from a booklet called “Problematical Recreations,” published in the 1960s by Litton Industries, where it is attributed to the Kansas State Engineer.
;;
;; Mary Ann Moore의 아버지는 요트를 가지고 있으며1, 그의 네 친구인 Colonel Downing, Mr. Hall, Sir Barnacle Hood, Dr. Parker도 각각 요트를 가지고 있습니다.
;;
;; 이 다섯 사람 모두 각각 한 명의 딸이 있으며,
;; 각자는 자신의 요트 이름을 **다른 사람의 딸의 이름**으로 지었습니다.
;; 
;; Sir Barnacle Hood의 요트는 Gabrielle입니다.3
;; Mr. Moore는 Lorna를 소유하고 있습니다.4
;; Mr. Hall은 Rosalind를 소유하고 있습니다.6
;; Colonel Downing이 소유한 Melissa는5 Sir Barnacle Hood의 딸의 이름을 따서 지어졌습니다.2
;; Gabrielle의 아버지는 Dr. Parker의 딸의 이름을 딴 요트를 소유하고 있습니다.7 **
;; 
;; Lorna의 아버지는 누구입니까?
;;

;;
;; 프로그램을 효율적으로 실행되도록 작성해 보세요 (연습문제 4.40 참조).
;;
;; 4.40 Q. 모든 사람들을 층에 배정 후 백트래킹을 통해 이를 제거하는 방식은 매우 비효율적. 이전 제약 조건에 의해 이미 배제된 가능성만 생성하도록 하는, 훨씬 더 효율적인 비결정적 절차를 작성하고 이를 시연하라
;;
(define expr-find-father-v1
  '(begin
     (define (yacht-name owner)
       (cond ((eq? owner 'Sir-Barnacle-Hood) 'Gabrielle)
             ((eq? owner 'Mr-Moore)          'Lorna)
             ((eq? owner 'Mr-Hall)           'Rosalind)
             ((eq? owner 'Colonel-Downing)   'Melissa)
             ((eq? owner 'Dr-Parker)         'Mary-Ann-Moore)))
     (define (find-father-v1)
       ;; father  : Mr-Moore Colonel-Downing Mr-Hall Sir-Barnacle-Hood Dr-Parker
       ;; daughter: Mary-Ann-Moore Gabrielle Lorna Rosalind Melissa
  
       (let ((father-Mary-Ann-Moore 'Mr-Moore))
         ; Mary Ann Moore의 아버지는 요트를 가지고 있으며1. 이름으로써  Mr. Moore의 딸. 확정:(Mary-Ann-Moore Mr-Moore)
         
         (let ((father-Melissa 'Sir-Barnacle-Hood))
           ;  Melissa는 Sir Barnacle Hood의 딸의 이름을 따서 지어졌습니다.2             확정:(Melissa Sir-Barnacle-Hood)
           
           (let ((father-Gabrielle (amb 'Mr-Hall 'Colonel-Downing 'Dr-Parker))
                 (father-Lorna     (amb 'Mr-Hall 'Colonel-Downing 'Dr-Parker))
                 (father-Rosalind  (amb 'Mr-Hall 'Colonel-Downing 'Dr-Parker)))
             ;(require (not (eq? 'Sir-Barnacle-Hood father-Gabrielle))) ; Sir Barnacle Hood의 요트는 Gabrielle입니다.3  삭제가능 (Melissa Sir-Barnacle-Hood)
             ;(require (not (eq? 'Mr-Moore father-Lorna)))              ; Mr. Moore는 Lorna를 소유하고 있습니다.4       삭제가능 (Mary-Ann-Moore Mr-Moore)
             ;(require (not (eq? 'Colonel-Downing father-Melissa)))     ; Colonel Downing이 소유한 Melissa는5           삭제가능 (Melissa Sir-Barnacle-Hood)
             (require (not (eq? 'Mr-Hall father-Rosalind)))            ; Mr. Hall은 Rosalind를 소유하고 있습니다.6

             (let ((daughter-father-for-Dr-Parker (amb (cons 'Gabrielle father-Gabrielle)
                                                       (cons 'Lorna     father-Lorna)
                                                       (cons 'Rosalind  father-Rosalind))))
               ; Gabrielle의 아버지는 Dr. Parker의 딸의 이름을 딴 요트를 소유하고 있습니다.7 **
               ; - 아빠와 딸이 같이 붙어있는 제약조건으로 특이함.
               (require (eq? (cdr daughter-father-for-Dr-Parker) 'Dr-Parker))
               (require (eq? (yacht-name father-Gabrielle) (car daughter-father-for-Dr-Parker)))
               
               (require (distinct? (list father-Mary-Ann-Moore father-Gabrielle father-Lorna father-Rosalind father-Melissa)))
               (list (list 'Mary-Ann-Moore father-Mary-Ann-Moore)
                     (list 'Gabrielle      father-Gabrielle)
                     (list 'Lorna          father-Lorna)
                     (list 'Rosalind       father-Rosalind)
                     (list 'Melissa        father-Melissa)))))))
     )
  )

;;
;; 또한, Mary Ann의 성(last name)이 Moore라는 정보가 주어지지 않을 경우 해결책이 몇 개 있는지도 알아내세요.
;;
(define expr-find-father-v2
  '(begin
     (define (yacht-name owner)
       (cond ((eq? owner 'Sir-Barnacle-Hood) 'Gabrielle)
             ((eq? owner 'Mr-Moore)          'Lorna)
             ((eq? owner 'Mr-Hall)           'Rosalind)
             ((eq? owner 'Colonel-Downing)   'Melissa)
             ((eq? owner 'Dr-Parker)         'Mary-Ann-Moore)))
     (define (find-father-v2)
       ;; father  : Mr-Moore Colonel-Downing Mr-Hall Sir-Barnacle-Hood Dr-Parker
       ;; daughter: Mary-Ann-Moore Gabrielle Lorna Rosalind Melissa
  
       (let ((father-Melissa 'Sir-Barnacle-Hood))
         ;  Melissa는 Sir Barnacle Hood의 딸의 이름을 따서 지어졌습니다.2  확정:(Melissa Sir-Barnacle-Hood)
         
         (let ((father-Mary-Ann-Moore (amb 'Mr-Moore 'Colonel-Downing 'Mr-Hall 'Dr-Parker))
               (father-Gabrielle      (amb 'Mr-Moore 'Colonel-Downing 'Mr-Hall 'Dr-Parker))
               (father-Lorna          (amb 'Mr-Moore 'Colonel-Downing 'Mr-Hall 'Dr-Parker))
               (father-Rosalind       (amb 'Mr-Moore 'Colonel-Downing 'Mr-Hall 'Dr-Parker)))
           ; (require (not (eq? 'Sir-Barnacle-Hood father-Gabrielle))) ; Sir Barnacle Hood의 요트는 Gabrielle입니다.3 삭제가능 (Melissa Sir-Barnacle-Hood)
           (require (not (eq? 'Mr-Moore father-Lorna)))              ; Mr. Moore는 Lorna를 소유하고 있습니다.4
           ;(require (not (eq? 'Colonel-Downing father-Melissa)))     ; Colonel Downing이 소유한 Melissa는5           삭제가능 (Melissa Sir-Barnacle-Hood)
           (require (not (eq? 'Mr-Hall father-Rosalind)))            ; Mr. Hall은 Rosalind를 소유하고 있습니다.6

           (let ((daughter-father-for-Dr-Parker (amb (cons 'Mary-Ann-Moore father-Mary-Ann-Moore)
                                                     (cons 'Gabrielle father-Gabrielle)
                                                     (cons 'Lorna     father-Lorna)
                                                     (cons 'Rosalind  father-Rosalind))))
             ; Gabrielle의 아버지는 Dr. Parker의 딸의 이름을 딴 요트를 소유하고 있습니다.7 **
             ; - 아빠와 딸이 같이 붙어있는 제약조건으로 특이함.
             (require (eq? (cdr daughter-father-for-Dr-Parker) 'Dr-Parker))
             (require (eq? (yacht-name father-Gabrielle) (car daughter-father-for-Dr-Parker)))
               
             (require (distinct? (list father-Mary-Ann-Moore father-Gabrielle father-Lorna father-Rosalind father-Melissa)))
             (list (list 'Mary-Ann-Moore father-Mary-Ann-Moore)
                   (list 'Gabrielle      father-Gabrielle)
                   (list 'Lorna          father-Lorna)
                   (list 'Rosalind       father-Rosalind)
                   (list 'Melissa        father-Melissa)))))))
  )


(define env3 (setup-environment))
(define-variable! 'display (list 'primitive display) env3)
(~> '(define (require p)
       (if (not p)
           (amb)))
    (run env3)
    (check-equal? 'ok))

(~> '(define (distinct? items)
       (cond ((null? items)
              true)
             ((null? (cdr items))
              true)
             ((member (car items) (cdr items))
              false)
             (else
              (distinct? (cdr items)))))
    (run env3)
    (check-equal? 'ok))

(~> expr-find-father-v1
    (run env3)
    (check-equal? 'ok))


(~> '(find-father-v1)
    (runs env3)
    (check-equal? '(((Mary-Ann-Moore Mr-Moore)
                     (Gabrielle Mr-Hall)
                     (Lorna Colonel-Downing)
                     (Rosalind Dr-Parker)
                     (Melissa Sir-Barnacle-Hood)))))


(~> expr-find-father-v2
    (run env3)
    (check-equal? 'ok))


(~> '(find-father-v2)
    (runs env3)
    (check-equal? '(((Mary-Ann-Moore Mr-Moore)
                     (Gabrielle Mr-Hall)
                     (Lorna Colonel-Downing)
                     (Rosalind Dr-Parker)
                     (Melissa Sir-Barnacle-Hood))
                    
                    ((Mary-Ann-Moore Mr-Hall)
                     (Gabrielle Mr-Moore)
                     (Lorna Dr-Parker)
                     (Rosalind Colonel-Downing)
                     (Melissa Sir-Barnacle-Hood)))))