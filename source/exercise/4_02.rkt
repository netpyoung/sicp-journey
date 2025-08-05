#lang sicp
;; file: 4_02.rkt

;; a) eval의 cond절에서
;;    assignment 혹은 definition보다
;;        ((assignment? exp) (eval-assignment exp env))
;;        ((definition? exp) (eval-definition exp env))
;;    application을
;;        ((application? exp) (apply (eval (operator exp) env) (list-of-values (operands exp) env)))
;;    먼저 배치한다는 계획에서 잘못된 점은무엇인가?
;;   - (귀띔 : 저 생각대로 (define x 3) 식을 처리하면 어떻게 될까?)
;;
;;  이런식으로 함수 호출이 먼저 된다면?
;;
;;(define (eval exp env)
;;  (cond (
;;        ...
;;        ((variable? exp) ; symbol? 이면
;;         (lookup-variable-value exp env))
;;        ...
;;        ((application? exp) ; pair? 이면 함수 호출
;;         (apply (eval (operator exp) env) (list-of-values (operands exp) env)))
;;        ...
;;        ((assignment? exp) ; set! 으로 시작
;;         (eval-assignment exp env))
;;       ((definition? exp) ; define 으로 시작
;;         (eval-definition exp env))
;;        ...
;;    )))
;;
;; - 간단히
;    - '(define x 3)가 pair?를 만족함으로 application(함수 콜)을 처리하는 로직에 떨어지게 됨.
;;   - 당연히 'define이라는 함수가 정의가 되지 않았으므로 에러 발생 예상.
;; - 자세히.
;;   - ((application? '(define x 3)) ; pair? 이면 함수 호출
;;   - (apply (eval 'define env) (list-of-values '(x 3) env)) 를 수행하게 되는데
;;     - (eval 'define env) 에서 'define은 심볼이므로
;;     - ((variable? 'define) (lookup-variable-value 'define env)) 로 떨어지게 됨
;;       - lookup-variable-value은 아직 구현이 나와있지 않으나 'define이 env에 정의되지 않았을 거임 그래서 에러가 발생할꺼.(에러가 발생안한다면 잘못된 구현)


;; b)언어 문법을 바꾸어서 프로시저 적용 식이 언제나 call로 시작되게 하자.
;;   - 보기를 들어， (factorial 3)은 (call factorial 3)으로， (+ 1 2)는 (call + 1 2)로 된다.
;;
;; eval함수에서 함수를 처리하는 부분은
;; ((application? exp) ; pair? 이면 함수 호출
;;   (apply (eval (operator exp) env) (list-of-values (operands exp) env)))
;;
;; exp가 (factorial 3) 에서 (call factorial 3) 식으로 바뀌었으므로
;; application? /  operator / operands 부분을 고쳐야함.


;; 단순 pair?로 체크하는걸 'call로 시작하는 리스트를 확인하는걸로 바꾸고
;;(define (application? exp)
;;  (pair? exp))
(define (application? exp)
  (tagged-list? exp 'call))

;; rest로 첫번째 아이템('call)은 건너띄면 됨.
;;(define (operator exp)
;;  (first exp))
;;(define (operands exp)
;;  (rest exp))
(define (operator exp)
  (first (rest exp)))
 (define (operands exp)
  (rest (rest exp)))