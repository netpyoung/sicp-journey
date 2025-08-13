#lang sicp
;; file: 4_15.rkt

;;
;; 정지 문제:
;; - Halting Problem: https://en.wikipedia.org/wiki/Halting_problem
;; - SCOOPING THE LOOP SNOOPER -  http://www.lel.ed.ac.uk/~gpullum/loopsnoop.html
;;

;; 가정:
;; 함수 p와 오브젝트 a가 있을시, (p a)를 호출하면 값을 반환하거나, 에러를 뱉거나, 끊임없이 동작한다고 가정하자.
;;
;; 문제:
;; 함수 p와 입력값 a에 대해, (p a)시 멈추는지 아닌지 판별하는 halts?라는 함수를 작성하는게 불가능 하다.
;; 이를 증명해보아라.
;;
;; 증명:
;; 귀류법: 해결방법이 있다라는 가정에서 모순이 발생한다는 것을 보임으로써 증명한다.
;;
;; 만일 halts?라는게 있다면 다음코드를 작성할 수 있을 것이며,
;; 
;; (define (run-forever)
;;   (run-forever))
;; 
;; (define (try p)
;;   (if (halts? p p)
;;       (run-forever)
;;       'halted))
;;
;; 그런 다음, (try try)를 호출하면 결과가 어떻든(값을 반환하거나, 에러를 뱉거나, 끊임없이 동작),
;; halts?의 정의에 어긋남을 밝히면 된다.
;;
;; (halts? p a)는 (p a)시 멈춘다면 true반환할 것이다.
;; (try try)
;;  => (halts? try try) - 만약 참이라면 (try try)시 멈춘다는 말이다. 하지만,
;;   => 조건문을 만족시키면서 (run-forever)로 돌면서 (try try)는 멈추지 않고 끊임없이 동작할 것이다.
;;  =>(halts? try try) - 만약 것짓이라면, (try try)시 멈추지 않는다는 말이다. 하지만,
;;   => 조건문을 만족시키지 못하면서 'halted를 반환하면서 (try try)는 멈추게 된다.:
;; 이 모순된 상황은 halts?의 정의와는 맞지않다.
