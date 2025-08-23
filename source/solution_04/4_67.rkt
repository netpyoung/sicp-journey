#lang sicp
;; file: 4_67.rkt
;; 2_18 / 4_67 / 4_68

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.4.4.1-query.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

;; TODO Q. 쿼리 시스템에 루프 감지기를 설치하여 본문과 연습문제 4.64에서 설명된 간단한 루프를 피할 수 있는 방법을 고안하시오.
;; 일반적인 아이디어는 시스템이 현재 추론 체인의 이력을 유지하고, 이미 처리 중인 쿼리를 다시 처리하지 않도록 하는 것입니다.
;; 이 이력에 포함되는 정보(패턴과 프레임)의 종류와 검사 방법을 설명하시오.
;;
;; (4.4.4절에서 쿼리 시스템 구현의 세부 사항을 공부한 후, 루프 감지기를 포함하도록 시스템을 수정할 수 있습니다.)

(racket:require "4_64.rkt")

(~> microshaft-data-base-modified-outranked-by
    (initialize-data-base))

(define (qeval query frame-stream)
  (display query)
  (newline)
  (let ((qproc (get (type query) 'qeval)))
    (if qproc
        (qproc (contents query) frame-stream)
        (simple-query query frame-stream))))
         
(override-qeval! qeval)

;; (~> '(outranked-by (Bitdiddle Ben) ?who)
;;     (run))
;;
;; (outranked-by (Bitdiddle Ben) (? who))
;; (or (supervisor (? 1 staff-person) (? 1 boss)) (and (outranked-by (? 1 middle-manager) (? 1 boss)) (supervisor (? 1 staff-person) (? 1 middle-manager))))
;; (supervisor (? 1 staff-person) (? 1 boss))
;; (and (outranked-by (? 1 middle-manager) (? 1 boss)) (supervisor (? 1 staff-person) (? 1 middle-manager)))
;;
;; (outranked-by (? 1 middle-manager) (? 1 boss))
;; (or (supervisor (? 2 staff-person) (? 2 boss)) (and (outranked-by (? 2 middle-manager) (? 2 boss)) (supervisor (? 2 staff-person) (? 2 middle-manager))))
;; (supervisor (? 2 staff-person) (? 2 boss))
;; (supervisor (? 1 staff-person) (? 1 middle-manager))
;; (and (outranked-by (? 2 middle-manager) (? 2 boss)) (supervisor (? 2 staff-person) (? 2 middle-manager)))
;;
;; (outranked-by (? 2 middle-manager) (? 2 boss))
;; (or (supervisor (? 3 staff-person) (? 3 boss)) (and (outranked-by (? 3 middle-manager) (? 3 boss)) (supervisor (? 3 staff-person) (? 3 middle-manager))))
;; (supervisor (? 3 staff-person) (? 3 boss))
;; (supervisor (? 2 staff-person) (? 2 middle-manager))
;; (and (outranked-by (? 3 middle-manager) (? 3 boss)) (supervisor (? 3 staff-person) (? 3 middle-manager)))
;;
;; ...
;;
;; (outranked-by (? {N} middle-manager) (? {N} boss))
;; (or (supervisor (? {N+1} staff-person) (? {N+1} boss)) (and (outranked-by (? {N+1} middle-manager) (? {N+1} boss)) (supervisor (? {N+1} staff-person) (? {N+1} middle-manager))))
;; (supervisor (? {N+1} staff-person) (? {N+1} boss))
;; (supervisor (? {N} staff-person) (? {N} middle-manager))
;; (and (outranked-by (? {N+1} middle-manager) (? {N+1} boss)) (supervisor (? {N+1} staff-person) (? {N+1} middle-manager)))


