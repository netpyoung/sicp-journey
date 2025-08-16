#lang sicp
;; file: 4_21.rkt

(#%require rackunit)
(#%require (only racket λ))

;; Stoy 1977 for details on the λ-calculus,
;;Gabriel 1988 for an exposition of the  Y operator in Scheme

;; lambda calculus 람다 대수.
;; - https://en.wikipedia.org/wiki/Lambda_calculus
;; - [Lambda Calculus - Fundamentals of Lambda Calculus & Functional Programming in JavaScript](https://www.youtube.com/watch?v=3VQ382QG-y4)
;; - 모든 기계적인 계산은 람다 대수로 표현할 수 있다
;; - turing completeness 만족.
;;   - 어떤 프로그래밍 언어나 추상 기계가 튜링 기계와 동일한 계산 능력을 가진다는 의미
;;
;; Application
;; f x       = (f x)
;; f x y     = ((f x) y) = (f x) y
;; f (x y)   = (f (x y))
;;
;; λ Lambda
;; λparameter.return
;; λx.a       = (λ (x) a)          | x => a
;; λx.a b     = (λ (x) (a x))      | x => (a x)
;; λx.λy.a    = (λ (x) (λ (y) a))  | x => y => a
;; (λx. a) b  = ((λ (x) a) b)      | (x => a)(b)
;; 
;; α-equivalence 동치. 변수 이름이 다른 두 람다 표현식이 구조상 같을때.
;; λx.x     와  λy.y
;; (f (x) x) 와 (f (y) y)
;; α-conversion  변환. 변수 이름 바꾸기(이름 충돌 방지).
;; λx.(λx.x)         => λx.(λy.y)
;; (f (x) (f (x) x)) => (f (x) (f (y) y)) 
;; β-reduction   축소. 함수 적용 후 변수 치환
;; ((λx.M) N)          => M
;; ((λ (x) (+ x 1)) 3) => (+ 3 1) => 4
;; η-conversion  변환. 불필요한 래핑 제거
;; (Η η eta /ˈiːtə, ˈeɪtə/ 이터 / 에이터)
;; λx.(fx)       => f
;; (λ (x) (f x)) => f
;;
;; Church encoding
;; https://en.wikipedia.org/wiki/Church_encoding
;;
;; TRUE  = λt. λf. t = (λ (t) (λ (f) t)) // 첫 번째 인자만 고르는 함수
;; FALSE = λt. λf. f = (λ (t) (λ (f) f)) // 두 번째 인자만 고르는 함수
;; ...
;;
;; Combinator: free variable이 없는 함수.
;; (λ (x) x) : 함수이면서, free variable이 없어 combinator.
;; (λ (x) a) : 함수이지만, free variable a가 있어 combinator가 아님.
;;
;; Fixed-point combinator (고정점 결합자)
;; - https://en.wikipedia.org/wiki/Fixed-point_combinator
;; - 함수의 재귀적 자기 참조를 가능하게 하는 함수
;; - 함수 f의 고정점 x는 f(x) = x가 성립하는 x입니다.
;;     (f x)     = x
;;     (f (f x)) = x
;; -  Y Combinator, Z Combinator 등 다양한 형태가 가능
;;
;; Y Combinator.
;; - λ-계산에서는 함수에 자기 자신을 직접 호출 할 수 없음.
;; - 하지만 함수를 인자를 받아 활용하면  재귀적인 동작이 가능함.
;; - 이 재귀적인 동작을 가능케하는 함수가 바로 Y Combinator.
;; - 단일 인자 함수에 대해 재귀를 가능하게 함
;;
;; Y = λf.(λx.f(x x))(λx.f(x x))
;;   = (λ (f)
;;       ((λ (x) (f (x x)))
;;        (λ (x) (f (x x)))))
;; (Y a) = (a (Y a))
;;       풀어쓰면 햇갈리니 두번째 (λ (x) (f (x x)))를 (λ (y) (f (y y))로 α-conversion
;;         = ((λ (f)
;;              ((λ (x) (f (x x)))
;;               (λ (y) (f (y y)))))
;;            a)
;; f에 a를 넣으면 (β-reduction)
;;         = ((λ (x) (a (x x)))
;;            (λ (y) (a (y y))))
;; x에 (λ (y) (a (y y)))를 넣으면 (β-reduction)
;;         = (a ( (λ (y) (a (y y)))
;;                (λ (y) (a (y y))) ) )
;; a를 다시 빼주면 ( α-conversion )
;;         = (a ((λ (f)
;;                 ((λ (y) (f (y y)))
;;                  (λ (y) (f (y y))))) a))
;;다시 (λ (y) (f (y y)))를 (λ (x) (f (x x)))로 변경시켜주고  α-conversion 
;;         = (a ((λ (f)
;;               ((λ (x) (f (x x)))
;;                (λ (x) (f (x x))))) a))
;; Y = (λ (f) ((λ (x) (f (x x))) (λ (x) (f (x x))))) 이므로
;;         = (a (Y a))
;;         = (Y a)
;; 즉 Y에 a를 넣으면 a가 재귀적으로 계속 호출됨.
;;
;; Z Combinator
;; Z = λf.(λx.f(λv. xxv))(λx.f(λv. xxv))
;;   = (λ (f)
;;      ((λ (x)
;;         (f (λ (v) ((x x) v))))
;;       (λ (x)
;;         (f (λ (v) ((x x) v))))))
;;



;; letrec을 쓰지 않고도 재귀 프로시져를 만들 수 있음.

(define Y
  (λ (f)
    ((λ (x)
       (f (x x)))
     (λ (x)
       (f (x x))))))

(define Z
  (λ (f)
    ((λ (x)
       (f (λ (v) ((x x) v))))
     (λ (x)
       (f (λ (v) ((x x) v)))))))

(check-eq? ((Z
             (lambda (fact)
               (lambda (n)
                 (if (= n 0)
                     1
                     (* n (fact (- n 1)))))))
            10)
           3628800)

(check-eq? ((λ (n)
              ((λ (x)
                 (x x 0 n))
               (λ (iter acc y)
                 (if (= y 0)
                     acc
                     (iter iter (+ acc y) (- y 1))))))
            10)
           55)

;; 1-1. 표현식을 평가하여 factorial이 돌아가는지 확인.
(check-eq? ((lambda (n)
              ((lambda (fact)
                 (fact fact n))
               (lambda (ft k)
                 (if (= k 1)
                     1
                     (* k (ft ft (- k 1)))))))
            10)
           3628800)

;; 1-2. 피보나치 수를 구하는 함수 작성.

(check-eq? (let ()
             (define (fib n)
               (cond ((= n 0) 0)
                     ((= n 1) 1)
                     (else
                      (+ (fib (- n 1))
                         (fib (- n 2))))))
             (fib 10))
           55)

(check-eq? ((lambda (n)
              ((lambda (fibo)
                 (fibo fibo n))
               (lambda (fb n)
                 (cond ((= n 0) 0)
                       ((= n 1) 1)
                       (else
                        (+ (fb fb (- n 1))
                           (fb fb (- n 2))))))))
            10)
           55)

(check-eq? ((Z
             (lambda (fibo)
               (lambda (n)
                 (cond ((= n 0) 0)
                       ((= n 1) 1)
                       (else
                        (+ (fibo (- n 1))
                           (fibo (- n 2))))))))
            10)
           55)

;; 2. 빈칸을 체워서 다음과 같은 함수와 동일한 함수 작성.
;; (define (f x)
;;   ((lambda (new-even? new-odd?)
;;      (new-even? new-even? new-odd? x))
;;    (lambda (ev? od? n)
;;      (if (= n 0) 
;;          true 
;;          (od? <??> <??> <??>)))
;;    (lambda (ev? od? n)
;;      (if (= n 0) 
;;          false 
;;          (ev? <??> <??> <??>)))))

(define (f x)
  (define (new-even? n)
    (if (= n 0)
        true
        (new-odd? (- n 1))))
  (define (new-odd? n)
    (if (= n 0)
        false
        (new-even? (- n 1))))
  (new-even? x))
(check-eq? (f 5) false)
(check-eq? (f 6) true)



(define (f2 x)
  ((lambda (new-even? new-odd?)
     (new-even? new-even? new-odd? x))
   (lambda (ev? od? n)
     (if (= n 0) 
         true 
         (od? ev? od? (- n 1))))
   (lambda (ev? od? n)
     (if (= n 0) 
         false 
         (ev? ev? od? (- n 1))))))

(check-eq? (f2 5) false)
(check-eq? (f2 6) true)
