#lang sicp
;; file: 5_10.rkt
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix racket: racket))
(#%require threading)

#|
새로운 문법을 추가할 수 있으면 추가해봐라.
|#

(racket:require (racket:rename-in "../allcode/ch5-regsim.rkt"
                                  (_make-execution-procedure origin-make-execution-procedure)))

(define (make-inc inst machine labels operations pc)
  (display (second inst))
  (newline)
  (let* ((register-name (second inst))
         (target (get-register machine register-name))
         (r (get-register machine register-name)))
    (lambda ()
      (set-contents! target (inc (get-contents r)))
      (advance-pc pc))))


(define (make-execution-procedure inst labels machine
                                  pc flag stack ops)
  (cond ((eq? (car inst) 'assign)
         (make-assign inst machine labels ops pc))
        ((eq? (car inst) 'test)
         (make-test inst machine labels ops flag pc))
        ((eq? (car inst) 'branch)
         (make-branch inst machine labels flag pc))
        ((eq? (car inst) 'goto)
         (make-goto inst machine labels pc))
        ((eq? (car inst) 'save)
         (make-save inst machine stack pc))
        ((eq? (car inst) 'restore)
         (make-restore inst machine stack pc))
        ((eq? (car inst) 'perform)
         (make-perform inst machine labels ops pc))
        ((eq? (first inst) 'inc)
         (make-inc inst machine labels ops pc))
        (else (error "Unknown instruction type -- ASSEMBLE"
                     inst))))

(override-make-execution-procedure! make-execution-procedure)

(define dummy-machine 
  (make-machine
   '(x)
   '()
   '((assign x (const 1))
     
     (inc x)
     (inc x)
     )))

(~> dummy-machine
    (start)
    (check-equal? 'done))
(~> dummy-machine 
    (get-register-contents 'x)
    (check-equal? 3))