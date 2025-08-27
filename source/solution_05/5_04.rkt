#lang sicp
;; file: 5_04.rkt
;; 5_04 / 5_07
(#%require (prefix racket: racket))

(racket:provide
 expt-recur-controller
 expt-iter-controller)

;; ref:
;;  - Figure 5.11 - factorial

;; controller 랑 data-path다이어그램

;; Recursive exponentiation:
#|
(define (expt b n)
  (if (= n 0)
      1
      (* b (expt b (- n 1)))))
|#

(define expt-recur-data-path
  '(data-paths
    (registers
     ((name b)
      (buttons ((name b<-b) 
                (source (register b)))))
     ((name n)
      (buttons ((name n<-n-1) 
                (source (operator -)))))
     ((name val)
      (buttons ((name val<-expt-n-1)
                (source (operator expt)))))
     ((name continue)
    
      ))
    (operations
     ((name expt)
      (inputs (register b) (register n)))
     ((name =)
      (inputs (register n) (constant 0)))
     ((name -)
      (inputs (register n) (constant 1)))
     ((name *)
      (inputs (register b) (register val))))))

(define expt-recur-controller
  '(controller
    ;; (assign b (op read))
    ;; (assign n (op read))

    (assign continue
            (label done))
  
    loop
    (test (op =) (reg n) (const 0))      ;   (if (= n 0)
    (branch
     (label base-case))

    (save continue)
    ;;(save n)
    (assign n (op -) (reg n) (const 1))
    (assign continue
            (label after))
    (goto
     (label loop))

    after
    ;;(restore n)
    (restore continue)
    (assign val (op *) (reg b) (reg val)) ;       (* b (expt b (- n 1)))))
    (goto
     (reg continue))
  
    base-case
    (assign val (const 1))                ; 1
    (goto
     (reg continue))
  
    done
    ;; (read val)
    ))

;; Iterative exponentiation:
#|
(define (expt b n)
  (define (expt-iter counter product)
    (if (= counter 0)
        product
        (expt-iter (- counter 1)
                   (* b product))))
  (expt-iter n 1))
|#

(define expt-iter-data-path
  '(data-paths
    (registers
     ((name b))
     ((name n))
     ((name counter)
      (buttons ((name counter<-n) 
                (source (register n)))
               ((name counter<-minus)
                (source (operation -)))))
     ((name product)
      (buttons ((name product<-1) 
                (source (constant 1)))
               ((name counter<-mul)
                (source (operation *))))))
    (operations
     ((name expt)
      (inputs (register b) (register n)))
     ((name expt-iter)
      (inputs (register n) (constant 1)))
     ((name =)
      (inputs (register counter) (constant 0)))
     ((name -)
      (inputs (register counter) (constant 1)))
     ((name *)
      (inputs (register b) (register product))))))

(define expt-iter-controller
  '(controller
    ;; (assign b (op read))
    ;; (assign n (op read))

    (assign counter (reg n))
    (assign product (const 1))
  
    loop-iter
    (test (op =) (reg counter) (const 0))
    (branch
     (label done-iter))

    (assign counter (op -) (reg counter) (const 1))
    (assign product (op *) (reg b) (reg product))
  
    (goto
     (label loop-iter))
  
    done-iter
    ;; (read product)
    ))
