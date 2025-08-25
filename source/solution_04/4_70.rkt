#lang sicp
;; file: 4_70.rkt

;; Q. 프로시저 add-assertion! 과 add-rule! 에서 let을 쓰는 목적이 무엇인가?
;;
;; cons-stream을 쓰는데 이게 두번째(cdr)위치에 있는 것을 dealy시킴.
;; delay되면서 자기 자신을 참조하게되는데 그걸 방지할 목적으로 let으로 미리 저장해둔걸 사용.
;;
;; Q. 다음과 같이 add-assertion!을 구현하면 무엇이 잘못인가?
;;  - 3.5.2절에서 끝없는 스트림의 정의를 되새겨 보라
;;    - (define ones (cons-stream 1 ones))
;;
;; (define (add-assertion! assertion)
;;   (store-assertion-in-index assertion)
;;   (set! THE-ASSERTIONS (cons-stream assertion THE-ASSERTIONS))
;;   'ok)

;; 예를들어 (add-assertion! '(a 1)) 라고 하면
;; THE-ASSERTIONS 는 다음과 같이 무한으로 나가게 된다.
;; (a 1) THE-ASSERTIONS
;;       (a 1) THE-ASSERTIONS
;;             (a 1) THE-ASSERTIONS
;;                   ...
