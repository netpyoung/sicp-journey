#lang sicp
;; file: 4_50.rkt
;; 4_45 / 4_46 / 4_47 / 4_48 / 4_49 / 4_50
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.3.3-ambeval.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

;; special form ramb를 만들자.
;; - amb : 인자 왼쪽에서 오른쪽으로 순서대로 고름.
;; - ramd: 순서를 random으로 고름.
;; 4.49에서 Alyssa의 문제를 푸는데 어떤 도움을 줄 수 있는가?

;; helper

(define (list-ref items n)
  (if (= n 0)
      (car items)
      (list-ref (cdr items) (- n 1))))

(define (filter predicate sequence)
  (cond ((null? sequence) nil)
        ((predicate (car sequence))
         (cons (car sequence)
               (filter predicate (cdr sequence))))
        (else (filter predicate (cdr sequence)))))

(define (remove item sequence)
  (filter (lambda (x) (not (eq? x item)))
          sequence))

;;
(define (ramb? exp)
  (tagged-list? exp 'ramb))

(define (analyze-ramb exp)
  (let ((cprocs (map analyze (rest exp))))
    (lambda (env succeed fail)
      (define (try-next choices)
        (if (null? choices)
            (fail)
            ;; before: analyze-amb
            ;; ((car choices) env
            ;;                succeed
            ;;                (lambda ()
            ;;                  (try-next (cdr choices))))
            ;;
            ;; after: analyze-ramb
            (let* ((r-idx (random (length choices)))
                   (r-item (list-ref choices r-idx))
                   (next-items (remove r-item choices)))
              (r-item env
                      succeed
                      (lambda ()
                        (try-next next-items))))))
      (try-next cprocs))))

(define (analyze exp)
  (cond ((self-evaluating? exp) 
         (analyze-self-evaluating exp))
        ((quoted? exp) (analyze-quoted exp))
        ((variable? exp) (analyze-variable exp))
        ((assignment? exp) (analyze-assignment exp))
        ((definition? exp) (analyze-definition exp))
        ((if? exp) (analyze-if exp))
        ((lambda? exp) (analyze-lambda exp))
        ((begin? exp) (analyze-sequence (begin-actions exp)))
        ((cond? exp) (analyze (cond->if exp)))
        ((let? exp) (analyze (let->combination exp)))
        ((amb? exp) (analyze-amb exp))
        ((ramb? exp) (analyze-ramb exp))                ;**
        ((application? exp) (analyze-application exp))
        (else
         (error "Unknown expression type -- ANALYZE" exp))))

(override-analyze! analyze)

;;


(define expr-base
  '(begin
     (define (require p)
       (if (not p)
           (amb)))

     (define nouns
       ;; noun: 명사
       '(noun student professor cat class))

     (define verbs
       ;; verb: 동사
       '(verb studies lectures eats sleeps))

     (define articles
       ;; article: 관사
       '(article the a))

     (define (parse-sentence)
       ;; sentence: 문장
       (list 'sentence
             (parse-noun-phrase)
             (parse-word verbs)))
       
     (define (parse-noun-phrase)
       ;; noun-phrase: 명사-구
       (list 'noun-phrase
             (parse-word articles)
             (parse-word nouns)))
       
     (define (parse-word word-list)
       (require (not (null? *unparsed*)))
       (require (memq (car *unparsed*) 
                      (cdr word-list)))
       (let ((found-word (car *unparsed*)))
         (set! *unparsed* (cdr *unparsed*))
         (list (car word-list) found-word)))
       
     (define *unparsed* '())
       
     (define (parse input)
       (set! *unparsed* input)
       (let ((sent (parse-sentence)))
         (require (null? *unparsed*))
         sent))

     ;;===
     (define prepositions
       ;; preposition: 전치사 
       '(prep for to in by with))
       
     (define (parse-prepositional-phrase)
       ;; prepositional-phrase: 전치사-구
       (list 'prep-phrase
             (parse-word prepositions)
             (parse-noun-phrase)))
       
     (define (parse-sentence)
       (list 'sentence
             (parse-noun-phrase)
             (parse-verb-phrase)))

     (define (parse-verb-phrase)
       (define (maybe-extend verb-phrase)
         (amb 
          verb-phrase
          (maybe-extend 
           (list 'verb-phrase
                 verb-phrase
                 (parse-prepositional-phrase)))))
       (maybe-extend (parse-word verbs)))
       
     (define (parse-simple-noun-phrase)
       (list 'simple-noun-phrase
             (parse-word articles)
             (parse-word nouns)))
       
     (define (parse-noun-phrase)
       (define (maybe-extend noun-phrase)
         (amb 
          noun-phrase
          (maybe-extend 
           (list 'noun-phrase
                 noun-phrase
                 (parse-prepositional-phrase)))))
       (maybe-extend (parse-simple-noun-phrase)))
     )
  )



(define env3 (setup-environment))
(define-variable! 'append (list 'primitive append) env3)
(define-variable! '< (list 'primitive <) env3)
(define-variable! 'error (list 'primitive error) env3)
(define-variable! 'random (list 'primitive random) env3)
(define-variable! 'length (list 'primitive length) env3)
(racket:random-seed 42)
(~> expr-base
    (run env3)
    (check-equal? 'ok))

(~> '(parse '(the cat eats))
    (runs env3)
    (check-equal?
     '((sentence (simple-noun-phrase (article the) (noun cat)) (verb eats)))))


(~> '(begin
       (define (nth lst n)
         (cond ((null? lst) (error "Index out of bounds"))
               ((< n 0) (error "Index cannot be negative"))
               ((= n 0) (car lst))
               (else (nth (cdr lst) (- n 1)))))
       (define (ramdom-select lst)
         (if (null? lst)
             '()
             (ramb (car lst)
                   (ramdom-select (cdr lst)))))     
       (define (parse-word word-list)
         
         (require (not (null? *unparsed*)))
         (require (memq (car *unparsed*) 
                        (cdr word-list)))
         (let ((found-word (car *unparsed*)))
           (set! *unparsed* (cdr *unparsed*))
           ;; before
           ;; (list (car word-list) found-word)
           ;;
           ;; before: 4.49
           ;; (list (car word-list)
           ;;       (nth (cdr word-list)
           ;;            (random (length (cdr word-list)))))
           ;;
           ;; after: 4.50
           (list (car word-list)
                 (ramdom-select (cdr word-list)))
           ))
       )
    (run env3))

(~> '(parse '(the cat eats))
    (run env3)
    (check-equal? '(sentence (simple-noun-phrase (article the) (noun student)) (verb lectures))))
