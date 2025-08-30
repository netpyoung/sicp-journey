#lang sicp
;; file: 5_20.rkt

#|
연습문제 5.20: 다음 코드로 생성된 리스트 구조의 박스-포인터 다이어그램과 메모리 벡터 표현(그림 5.14와 같은 형식)을 그리시오:

(define x (cons 1 2))
(define y (list x x))

초기 free 포인터는 p1.
최종 free 포인터의 값은 무엇인가? 변수 x와 y의 값을 나타내는 포인터는 무엇인가?
|#

#|

| p | pointer    |
| n | number     |
| e | empty list |


e0 : 빈리스트 - '()

|#


#|

x = (cons 1 2)
<p1> = (cons 1 2)
+-+-+-+-+
|   |   |--> n2
+-+-+-+-+
  |
  v
  n1

y = (list x y) = (cons x (cons x '()))
  | <p2> = (cons x '())  = (cons <p1> <e0>)
  | <p3> = (cons x <p2>) = (cons <p1> <e2>)
y = <p3>

<p3>        <p2>
+-+-+-+-+    +-+-+-+-+
|   |   |--> |   |   |--> e0
+-+-+-+-+    +-+-+-+-+
  |            |
  v            v
  x<p1>       x<p1>


| index    | 0   | 1   | 2   | 3   | 4   |
| -------- | --- | --- | --- | --- | --- |
| the-cars |     | n1  | p1  | p1  |     |
| the-cdrs |     | n2  | e0  | p2  |     |

즉,

x    : p1
y    : p3
free : p4

|#