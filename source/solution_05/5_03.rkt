#lang sicp
;; file: 5_03.rkt

#|
(define (sqrt x)
  (define (good-enough? guess)
    (< (abs (- (square guess) x)) 0.001))
  (define (improve guess)
    (average guess (/ x guess)))
  (define (sqrt-iter guess)
    (if (good-enough? guess)
        guess
        (sqrt-iter (improve guess))))
  (sqrt-iter 1.0))


- sqrt 각 버전의 머신 설계를 data-path 다이어그램으로, 레지스터 머신 언어로 controller 정의를 작성하여 설명.
|#


;; - good-enough?와 improve 연산자는 primitive로 사용 가능하다고 가정.
'(controller
  (assign x (op read))
  
  (assign guess (constant 1.0))
  
  loop-sqrt-iter
  (test (op good-enough?) (reg guess) (reg x))
  (branch
   (label done-loop-sqrt-iter))
  
  (assign guess (op improve) (reg guess) (reg x))
  (goto
   (label loop-sqrt-iter))
  
  done-loop-sqrt-iter
  ;; (read guess)
  )


;; - 두 연산자를 산술 연산으로 확장하여 구현
'(controller
  (assign x (op read))
  
  (assign guess (constant 1.0))
  
  loop

  ;; (define (good-enough? guess)
  ;;   (< (abs (- (square guess) x)) 0.001)) 
  (assign good-enough-s   (op square) (reg guess))                  ; (square guess)
  (assign good-enough-m   (op -)      (reg good-enough-s) (reg x))  ; (- x)
  (assign good-enough-abs (op abs)    (reg good-enough-m))          ; (abs)
  (test (op <) (register good-enough-abs) (constant 0.001))         ; (< 0.001)
  (branch
   (label done))

  ;; (define (improve guess)
  ;;   (average guess (/ x guess)))
  (assign improve-d   (op /)       (reg x)     (reg guess))          ; (/ x guess)
  (assign guess       (op average) (reg guess) (reg improve-d))      ; (average)
  (goto
   (label loop))
  
  done
  ;; (read guess)
  )