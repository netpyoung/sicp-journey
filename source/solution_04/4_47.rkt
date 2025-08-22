#lang sicp
;; file: 4_47.rkt
;; 4_45 / 4_46 / 4_47 / 4_48 / 4_49

;; Louis Reasoner: 동사구(verb phrase)가 단순히 동사(verb)이거나 동사구 뒤에 전치사구(prepositional phrase)가 따라오는 구조라고 주장.
;;
'(define (parse-verb-phrase)
   ;; 4_45: origin
   (define (maybe-extend verb-phrase)
     (amb 
      verb-phrase
      (maybe-extend 
       (list 'verb-phrase
             verb-phrase
             (parse-prepositional-phrase)))))
   (maybe-extend (parse-word verbs)))

'(define (parse-verb-phrase)
   ;; 4_47: Louis Reasoner
   (amb (parse-word verbs)
        (list 
         'verb-phrase
         (parse-verb-phrase)
         (parse-prepositional-phrase))))

;; Q. 이 방식이 제대로 동작하는가?
;;
;; 내부에서 호출하는 (parse-verb-phrase) 가 무한 루프를 일으킬 가능성.
;;
;; Q. amb 내부의 표현식 순서를 바꾸면 프로그램이 달리 동작하는가?
;;
;; 순서를 바꿔도 무한 루프 가능성은 사라지지 않음.