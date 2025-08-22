#lang sicp
;; file: 4_48.rkt
;; 4_45 / 4_46 / 4_47 / 4_48 / 4_49
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.3.3-ambeval.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))


;; 문법(grammar)을 더 복잡하게 확장시켜 보자.
;; 명사구와 동사구를 형용사(adjective)와 부사(adverb)를 포함하도록 한다거나, 중문(compound sentences)을 처리할 수 있도록 하거나.
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
(~> expr-base
    (run env3)
    (check-equal? 'ok))

(~> '(parse '(the cat eats))
    (runs env3)
    (check-equal?
     '((sentence (simple-noun-phrase (article the) (noun cat)) (verb eats)))))

(~> '(begin
       (define adjectives
         ;; 형용사
         '(adj beautiful big quiet shiny warm cold fast slow powerful soft))

       (define (parse-complex-noun-phrase)
         ;; 관사 형용사 명사
         (list 'complex-noun-phrase
               (parse-word articles)
               (parse-word adjectives)
               (parse-word nouns)))

       (define (parse-noun-phrase)
         (define (maybe-extend noun-phrase)
           (amb 
            noun-phrase
            (maybe-extend 
             (list 'noun-phrase
                   noun-phrase
                   (parse-prepositional-phrase)))))
         ;; before
         ;;(maybe-extend (parse-simple-noun-phrase))
         ;;
         ;; after
         (amb (maybe-extend (parse-simple-noun-phrase))
              (maybe-extend (parse-complex-noun-phrase)))
         ))
    (run env3)
    (check-equal? 'ok))

(~> '(parse '(the beautiful cat eats))
    (runs env3)
    (check-equal? '((sentence
                     (complex-noun-phrase (article the) (adj beautiful) (noun cat))
                     (verb eats)))))

(~> '(begin       
       (define adverbs
         ;; 부사
         '(adv quickly quietly loudly slowly carefully happily often rarely completely partly))

       (define (parse-adverb-list)
         (amb
          (list (parse-word adverbs))
          (cons (parse-word adverbs) (parse-adverb-list))))

       (define (parse-verb-phrase)
         (define (maybe-extend verb-phrase)
           (amb 
            verb-phrase
            (maybe-extend 
             (list 'verb-phrase
                   verb-phrase
                   (parse-prepositional-phrase)))))
         ;; before
         ;; (maybe-extend (parse-word verbs))
         ;;
         ;; after
         (amb (maybe-extend (parse-word verbs))
              (maybe-extend
               (list 'verb-phrase
                     (append (list 'adverb-list) (parse-adverb-list))
                     (parse-word verbs)))
              (maybe-extend
               (list 'verb-phrase
                     (parse-word verbs)
                     (append (list 'adverb-list) (parse-adverb-list))))
              ))
       )
    (run env3)
    (check-equal? 'ok))

(~> '(parse '(the beautiful cat eats quickly))
    (runs env3)    
    (check-equal?
     '((sentence
        (complex-noun-phrase (article the) (adj beautiful) (noun cat))
        (verb-phrase (verb eats) (adverb-list (adv quickly))))))
    )

(~> '(begin
       
       (define coordinating-conjunctions
         ;; 등위 접속사
         '(coord-conj for and nor but or yet so))
               
       (define (parse-sentence)
         ;; before
         ;; (list 'sentence
         ;;       (parse-noun-phrase)
         ;;       (parse-verb-phrase))
         ;;
         ;; after
         (define (maybe-extend sentence)
           (amb 
            sentence
            (maybe-extend 
             (list 'compound-sentence
                   sentence
                   (parse-word coordinating-conjunctions)
                   (parse-sentence)))))
         (maybe-extend (list 'sentence
                             (parse-noun-phrase)
                             (parse-verb-phrase))))
       )
    (run env3)
    (check-equal? 'ok))


(~> '(parse '(the cat eats and the cat eats))
    (runs env3)    
    (check-equal?
     '((compound-sentence
        (sentence (simple-noun-phrase (article the) (noun cat)) (verb eats))
        (coord-conj and)
        (sentence (simple-noun-phrase (article the) (noun cat)) (verb eats))))))