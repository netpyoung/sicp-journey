#lang sicp
;; file: 5_02.rkt
;; 5_01 / 5_02

;; register-machine언어를 사용하여 iterative factorial 머신을 기술하라(연습문제 5.1에서  만든)

'(define (factorial n)
   (define (iter product counter)
     (if (> counter n)
         product
         (iter (* counter product)
               (+ counter 1))))
   (iter 1 1))

'(data-paths
  (registers
   ((name n))
   ((name product)
    (buttons ((name product<-1) 
              (source (constant 1)))
             ((name product<-mul) 
              (source (operation *)))))
   ((name count)
    (buttons ((name counter<-1) 
              (source (constant 1)))
             ((name counter<-add)
              (source (operation +))))))
  (operations
   ((name factorial)
    (inputs (register n)))
   ((name iter)
    (inputs (constant 1) (constant 1)))
   ((name >)
    (inputs (register a) (register b)))
   ((name *)
    (inputs (register a) (register b)))
   ((name +)
    (inputs (register a) (constant 0)))))

'(controller
  (assign n (op read))
  
  (assign product (const 1))
  (assign counter (const 1))
  
  loop-iter
  (test (op =) (reg counter) (reg n))
  (branch
   (label done-iter))
  
  (assign product (op *) (reg counter) (reg product))
  (assign counter (op +) (reg counter) (const 1))
  (goto
   (label loop-iter))
  
  done-iter
  ;; (read product)
  )
