#lang sicp
;; file: 4_49.rkt
;; 4_45 / 4_46 / 4_47 / 4_48 / 4_49 / 4_50
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.3.3-ambeval.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

;; Alyssa P. Hacker는 문장을 파싱하는 것보다 흥미로운 문장을 생성하는 데 더 관심이 있다.
;; 그녀는 parse-word 프로시저를 수정하여 "입력 문장"을 무시하고, 대신 항상 성공적으로 적절한 단어를 생성하도록 하면,
;; 기존에 파싱을 위해 작성된 프로그램을 문장 생성에 사용할 수 있다고 생각한다.
;; Alyssa의 아이디어를 구현하고, 생성된 처음 6개 정도의 문장을 보여라.


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
       
       (define (parse-word word-list)
         (require (not (null? *unparsed*)))
         (require (memq (car *unparsed*) 
                        (cdr word-list)))
         (let ((found-word (car *unparsed*)))
           (set! *unparsed* (cdr *unparsed*))
           ;; before
           ;; (list (car word-list) found-word)

           ;; after
           (list (car word-list)
                 (nth (cdr word-list)
                      (random (length (cdr word-list)))))
           ))
       )
    (run env3))

(~> '(parse '(the cat eats))
    (run env3)
    (check-equal? '(sentence (simple-noun-phrase (article the) (noun student)) (verb sleeps))))