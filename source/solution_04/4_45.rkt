#lang sicp
;; file: 4_45.rkt
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.3.3-ambeval.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

;;
;; Parsing natural language
;;
(define env3 (setup-environment))
(~> '(define (require p)
       (if (not p)
           (amb)))
    (run env3)
    (check-equal? 'ok))

(~> '(begin
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
       )
    (run env3)
    (check-equal? 'ok))

(~> '(parse '(the cat eats))
    (run env3)
    (check-equal? '(sentence 
                    (noun-phrase (article the) (noun cat))
                    (verb eats))))
(~> '(begin
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
    (run env3)
    (check-equal? 'ok))

(~> '(parse '(the student with the cat 
                  sleeps in the class))
    (run env3)
    (check-equal? '(sentence
                    (noun-phrase
                     (simple-noun-phrase (article the) 
                                         (noun student))
                     (prep-phrase (prep with)
                                  (simple-noun-phrase
                                   (article the)
                                   (noun cat))))
                    (verb-phrase
                     (verb sleeps)
                     (prep-phrase (prep in)
                                  (simple-noun-phrase
                                   (article the)
                                   (noun class)))))))

(~> '(parse '(the professor lectures to 
                  the student with the cat))
    (runs env3)
    (check-equal?
     '((sentence
        (simple-noun-phrase (article the) (noun professor))
        (verb-phrase
         (verb-phrase
          (verb lectures)
          (prep-phrase (prep to) (simple-noun-phrase (article the) (noun student))))
         (prep-phrase (prep with) (simple-noun-phrase (article the) (noun cat)))))
       (sentence
        (simple-noun-phrase (article the) (noun professor))
        (verb-phrase
         (verb lectures)
         (prep-phrase
          (prep to)
          (noun-phrase
           (simple-noun-phrase (article the) (noun student))
           (prep-phrase
            (prep with)
            (simple-noun-phrase (article the) (noun cat))))))))))

;; The professor lectures to the student in the class with the cat.를 5가지 방법으로 분석(parse)할 수 있음.
;; 의미를 설명해라.
;;
(~> '(parse '(the professor lectures to the student in the class with the cat))
    (runs env3)
    (check-equal?
     '((sentence
        (simple-noun-phrase (article the) (noun professor))
        ;; 교수가 **고양이와 함께**, 교실에서 학생에게 강의한다. (교수가 고양이 동반)
        (verb-phrase
         (verb-phrase
          (verb-phrase (verb lectures) (prep-phrase (prep to) (simple-noun-phrase (article the) (noun student))))
          (prep-phrase (prep in) (simple-noun-phrase (article the) (noun class))))
         (prep-phrase (prep with) (simple-noun-phrase (article the) (noun cat)))))
       (sentence
        ;; 교수가, **고양이가 있는 교실**에서, 학생에게 강의한다. (교실에 고양이가 있음, 교수/학생과 무관.)
        (simple-noun-phrase (article the) (noun professor))
        (verb-phrase
         (verb-phrase (verb lectures) (prep-phrase (prep to) (simple-noun-phrase (article the) (noun student))))
         (prep-phrase
          (prep in)
          (noun-phrase
           (simple-noun-phrase (article the) (noun class))
           (prep-phrase (prep with) (simple-noun-phrase (article the) (noun cat)))))))
       (sentence
        (simple-noun-phrase (article the) (noun professor))
        ;; 교수가, **고양이와 함께 교실에 있는 학생에게**, 강의한다.
        (verb-phrase
         (verb-phrase
          (verb lectures)
          (prep-phrase
           (prep to)
           (noun-phrase
            (simple-noun-phrase (article the) (noun student))
            (prep-phrase (prep in) (simple-noun-phrase (article the) (noun class))))))
         (prep-phrase (prep with) (simple-noun-phrase (article the) (noun cat)))))
       (sentence
        ;; 교수가, 교실에 있는, **고양이와 함께 있는 학생**에게 강의한다.
        (simple-noun-phrase (article the) (noun professor))
        (verb-phrase
         (verb lectures)
         (prep-phrase
          (prep to)
          (noun-phrase
           (noun-phrase
            (simple-noun-phrase (article the) (noun student))
            (prep-phrase (prep in) (simple-noun-phrase (article the) (noun class))))
           (prep-phrase (prep with) (simple-noun-phrase (article the) (noun cat)))))))
       (sentence
        ;; 교수가, **고양이가 있는 교실**에 있는, 학생에게 강의한다. (학생이 교실에 있고, 교실에 고양이가 있음.)
        (simple-noun-phrase (article the) (noun professor))
        (verb-phrase
         (verb lectures)
         (prep-phrase
          (prep to)
          (noun-phrase
           (simple-noun-phrase (article the) (noun student))
           (prep-phrase
            (prep in)
            (noun-phrase
             (simple-noun-phrase (article the) (noun class))
             (prep-phrase (prep with) (simple-noun-phrase (article the) (noun cat))))))))))))



