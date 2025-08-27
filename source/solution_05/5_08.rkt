#lang sicp
;; file: 5_08.rkt

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix racket: racket))
(#%require threading)

(racket:require (racket:rename-in "../allcode/ch5-regsim.rkt"
                                  (_extract-labels origin-extract-labels)))

;; 시율레이터에서 there까지 돌렸을 때 레지스터 a 값은?
(define expr
  '(start
    (goto (label here))
    here
    (assign a (const 3))
    (goto (label there))
    here
    (assign a (const 4))
    (goto (label there))
    there))

(define add-machine
  (make-machine
   '(a)
   '()
   expr))

(~> add-machine
    (start)
    (check-equal? 'done))
(~> add-machine 
    (get-register-contents 'a)
    (check-equal? 3))

;; 어셈블러가 서로 다른 위치에 같은 라벨 이름을 썼을 때 에러를 나타내도록 extract-labels 프로시저를 고쳐라.
(define (extract-labels text receive)
  (if (null? text)
      (receive '() '())
      (extract-labels (cdr text)
                      (lambda (insts labels)
                        (let ((next-inst (car text)))
                          (if (symbol? next-inst)
                              ;; before
                              ;; (receive insts
                              ;;          (cons (make-label-entry next-inst
                              ;;                                  insts)
                              ;;                labels))
                              ;;
                              ;; after
                              (if (assoc next-inst labels)
                                  (error "duplicate labels: " next-inst)
                                  (receive insts
                                           (cons (make-label-entry next-inst
                                                                   insts)
                                                 labels)))
                              
                              (receive (cons (make-instruction next-inst)
                                             insts)
                                       labels)))))))

(override-extract-labels! extract-labels)

(check-exn
 #rx"duplicate labels:  here"
 (lambda ()
   (extract-labels expr (lambda (insts labels) nil))))
