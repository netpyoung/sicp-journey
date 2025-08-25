#lang sicp
;; file: 4_75.rkt
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

(racket:require "../allcode/ch4-4.4.4.1-query.rkt")
;; TODO

(~> microshaft-data-base
    (initialize-data-base))

(define (uniquely-asserted content frame-stream)
  (let* ((q (first content)))
    ;; 남은 스트림을 다시 커다란 스트림 하나로 묶어서 unique 쿼리의 결과를 내놓게 된다.
    (stream-flatmap (lambda (frame)
                      ;; qeval을 사용하여, 스트림 속의 각 일람표에 대해 정해진 쿼리를 만족하도록 확장된 모든 일람표의 스트림을 찾아낸다
                      (let ((qstream (qeval q (singleton-stream frame))))
                        ;; 이로부터 정확히 원소 하나만 들지 않은 스트림은 걸러내야 한다.
                        (cond ((stream-null? qstream)              the-empty-stream)
                              ((stream-null? (stream-cdr qstream)) qstream)
                              (else                                the-empty-stream))))
                    frame-stream)))

(put 'unique 'qeval uniquely-asserted)

(~> '(unique (job ?x (computer wizard)))
    (run)
    (check-equal? '((unique (job (Bitdiddle Ben) (computer wizard))))))


(~> '(unique (job (Bitdiddle Ben) (computer wizard)))
    (run)
    (check-equal? '((unique (job (Bitdiddle Ben) (computer wizard))))))


(~> '(unique (job ?x (computer programmer)))
    (run)
    (check-equal? '()))

(~> '(and (job ?x ?j) 
          (unique (job ?anyone ?j)))
    (run)
    (check-equal? '(
                    (and (job (Aull DeWitt) (administration secretary))
                         (unique (job (Aull DeWitt) (administration secretary))))
                    (and (job (Cratchet Robert) (accounting scrivener))
                         (unique (job (Cratchet Robert) (accounting scrivener))))
                    (and (job (Scrooge Eben) (accounting chief accountant))
                         (unique (job (Scrooge Eben) (accounting chief accountant))))
                    (and (job (Warbucks Oliver) (administration big wheel))
                         (unique (job (Warbucks Oliver) (administration big wheel))))
                    (and (job (Reasoner Louis) (computer programmer trainee))
                         (unique (job (Reasoner Louis) (computer programmer trainee))))
                    (and (job (Tweakit Lem E) (computer technician))
                         (unique (job (Tweakit Lem E) (computer technician))))
                    (and (job (Bitdiddle Ben) (computer wizard))
                         (unique (job (Bitdiddle Ben) (computer wizard)))))
                  ))
