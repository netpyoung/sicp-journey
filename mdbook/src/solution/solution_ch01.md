# 연습문제 풀이 01

- <https://github.com/netpyoung/sicp-journey/tree/main/source/solution_01>

## 1_01

``` lisp
{{#include ../../../source/solution_01/1_01.rkt:2:}}
```

## 1_02


$$\\frac{5 + 4 + (2 - (3 - (6 + 4/5)))}{3(6 - 2)(2 - 7)}$$


``` lisp
{{#include ../../../source/solution_01/1_02.rkt:2:}}
```

## 1_03

``` lisp
{{#include ../../../source/solution_01/1_03.rkt:2:}}
```

## 1_04

``` lisp
{{#include ../../../source/solution_01/1_04.rkt:2:}}
```

## 1_05

``` lisp
{{#include ../../../source/solution_01/1_05.rkt:2:}}
```

## 1_06

``` lisp
{{#include ../../../source/solution_01/1_06.rkt:2:}}
```

## 1_07

``` lisp
{{#include ../../../source/solution_01/1_07.rkt:2:}}
```

## 1_08

$$
\text{목표: } y = \sqrt[3]{x}
$$

$$
\text{⇒ 양변을 세제곱: } y^3 = x
$$

$$
\text{⇒ 함수로 표현: } f(y) = y^3 - x
$$

$$
\text{⇒ 도함수: } f'(y) = 3y^2
$$

$$
\text{⇒ 뉴튼 방법 일반식: } y_{n+1} = y_n - \frac{f(y_n)}{f'(y_n)}
$$

$$
\text{⇒ 대입: } y_{n+1} = y_n - \frac{y_n^3 - x}{3y_n^2}
$$

$$
= y_n - \frac{1}{3} \left( y_n - \frac{x}{y_n^2} \right)
$$

$$
= \frac{2y_n + \frac{x}{y_n^2}}{3}
$$

$$
\therefore \boxed{
y_{n+1} = \frac{x/y_n^2 + 2y_n}{3}
}
$$


``` lisp
{{#include ../../../source/solution_01/1_08.rkt:2:}}
```

## 1_09

``` lisp
{{#include ../../../source/solution_01/1_09.rkt:2:}}
```

## 1_10

``` lisp
{{#include ../../../source/solution_01/1_10.rkt:2:}}
```

## 1_11

``` lisp
{{#include ../../../source/solution_01/1_11.rkt:2:}}
```

## 1_12

``` lisp
{{#include ../../../source/solution_01/1_12.rkt:2:}}
```

## 1_13

``` lisp
{{#include ../../../source/solution_01/1_13.rkt:2:}}
```

## 1_14

- 1.2.2에서 나온 count-change 함수가 11 센트(cent)에 맞게 잔돈을 만들어내는 트리를 그려보아라.

<pre class="mermaid">
%%{init: {'flowchart' : {'curve' : 'monotoneX'}}}%%
graph TD
  cc_11_05_a["(cc 11 5)"] --> cc_11_04_a["(cc 11 4)"]
  cc_11_04_a --> cc_11_03_a["(cc 11 3)"]
  cc_11_03_a --> cc_11_02_a["(cc 11 2)"]
  cc_11_02_a --> cc_11_01_a["(cc 11 1)"]
  cc_11_01_a --> cc_11_00_a["(cc 11 0)"]
  cc_11_01_a --> cc_10_01_a["(cc 10 1)"]
  cc_10_01_a --> cc_10_00_a["(cc 10 0)"]
  cc_10_01_a --> cc_09_01_a["(cc 9 1)"]
  cc_09_01_a --> cc_09_00_a["(cc 9 0)"]
  cc_09_01_a --> cc_08_01_a["(cc 8 1)"]
  cc_08_01_a --> cc_08_00_a["(cc 8 0)"]
  cc_08_01_a --> cc_07_01_a["(cc 7 1)"]
  cc_07_01_a --> cc_07_00_a["(cc 7 0)"]
  cc_07_01_a --> cc_06_01_a["(cc 6 1)"]
  cc_06_01_a --> cc_06_00_a["(cc 6 0)"]
  cc_06_01_a --> cc_05_01_a["(cc 5 1)"]
  cc_05_01_a --> cc_05_00_a["(cc 5 0)"]
  cc_05_01_a --> cc_04_01_a["(cc 4 1)"]
  cc_04_01_a --> cc_04_00_a["(cc 4 0)"]
  cc_04_01_a --> cc_03_01_a["(cc 3 1)"]
  cc_03_01_a --> cc_03_00_a["(cc 3 0)"]
  cc_03_01_a --> cc_02_01_a["(cc 2 1)"]
  cc_02_01_a --> cc_02_00_a["(cc 2 0)"]
  cc_02_01_a --> cc_01_01_a["(cc 1 1)"]
  cc_01_01_a --> cc_01_00_a["(cc 1 0)"]
  cc_01_01_a --> cc_00_01_a["(cc 0 1)"]

  cc_11_02_a --> cc_06_02_a["(cc 6 2)"]
  cc_06_02_a --> cc_06_01_b["(cc 6 1)"]
  cc_06_01_b --> cc_06_00_b["(cc 6 0)"]
  cc_06_01_b --> cc_05_01_b["(cc 5 1)"]
  cc_05_01_b --> cc_05_00_b["(cc 5 0)"]
  cc_05_01_b --> cc_04_01_b["(cc 4 1)"]
  cc_04_01_b --> cc_04_00_b["(cc 4 0)"]
  cc_04_01_b --> cc_03_01_b["(cc 3 1)"]
  cc_03_01_b --> cc_03_00_b["(cc 3 0)"]
  cc_03_01_b --> cc_02_01_b["(cc 2 1)"]
  cc_02_01_b --> cc_02_00_b["(cc 2 0)"]
  cc_02_01_b --> cc_01_01_b["(cc 1 1)"]
  cc_01_01_b --> cc_01_00_b["(cc 1 0)"]
  cc_01_01_b --> cc_00_01_b["(cc 0 1)"]

  cc_06_02_a --> cc_01_02_a["(cc 1 2)"]
  cc_01_02_a --> cc_01_01_c["(cc 1 1)"]
  cc_01_01_c --> cc_01_00_c["(cc 1 0)"]
  cc_01_01_c --> cc_00_01_c["(cc 0 1)"]
  cc_01_02_a --> cc_m4_02["(cc -4 2)"]

  cc_11_03_a --> cc_01_03_a["(cc 1 3)"]
  cc_01_03_a --> cc_01_02_b["(cc 1 2)"]
  cc_01_02_b --> cc_01_01_d["(cc 1 1)"]
  cc_01_01_d --> cc_01_00_d["(cc 1 0)"]
  cc_01_01_d --> cc_00_01_d["(cc 0 1)"]
  cc_01_02_b --> cc_m4_02_b["(cc -4 2)"]

  cc_01_03_a --> cc_m9_03["(cc -9 3)"]

  cc_11_04_a --> cc_m14_04["(cc -14 4)"]

  cc_11_05_a --> cc_m39_05["(cc -39 5)"]

  classDef highlightNode fill:#ffcccc,stroke:#cc0000,stroke-width:2px;
  class cc_00_01_a highlightNode;
  class cc_00_01_b highlightNode;
  class cc_00_01_c highlightNode;
  class cc_00_01_d highlightNode;
</pre>

``` lisp
{{#include ../../../source/solution_01/1_14.rkt:2:}}
```

## 1_15

``` lisp
{{#include ../../../source/solution_01/1_15.rkt:2:}}
```

## 1_16

``` lisp
{{#include ../../../source/solution_01/1_16.rkt:2:}}
```

## 1_17

``` lisp
{{#include ../../../source/solution_01/1_17.rkt:2:}}
```

## 1_18

``` lisp
{{#include ../../../source/solution_01/1_18.rkt:2:}}
```

## 1_19

``` lisp
{{#include ../../../source/solution_01/1_19.rkt:2:}}
```

## 1_20

``` lisp
{{#include ../../../source/solution_01/1_20.rkt:2:}}
```

## 1_21

``` lisp
{{#include ../../../source/solution_01/1_21.rkt:2:}}
```

## 1_22

``` lisp
{{#include ../../../source/solution_01/1_22.rkt:2:}}
```

## 1_23

``` lisp
{{#include ../../../source/solution_01/1_23.rkt:2:}}
```

## 1_24

``` lisp
{{#include ../../../source/solution_01/1_24.rkt:2:}}
```

## 1_25

``` lisp
{{#include ../../../source/solution_01/1_25.rkt:2:}}
```

## 1_26

``` lisp
{{#include ../../../source/solution_01/1_26.rkt:2:}}
```

## 1_27

``` lisp
{{#include ../../../source/solution_01/1_27.rkt:2:}}
```

## 1_28

``` lisp
{{#include ../../../source/solution_01/1_28.rkt:2:}}
```

## 1_29

``` lisp
{{#include ../../../source/solution_01/1_29.rkt:2:}}
```

## 1_30

``` lisp
{{#include ../../../source/solution_01/1_30.rkt:2:}}
```

## 1_31

``` lisp
{{#include ../../../source/solution_01/1_31.rkt:2:}}
```

## 1_32

``` lisp
{{#include ../../../source/solution_01/1_32.rkt:2:}}
```

## 1_33

``` lisp
{{#include ../../../source/solution_01/1_33.rkt:2:}}
```

## 1_34

``` lisp
{{#include ../../../source/solution_01/1_34.rkt:2:}}
```

## 1_35

``` lisp
{{#include ../../../source/solution_01/1_35.rkt:2:}}
```

## 1_36

``` lisp
{{#include ../../../source/solution_01/1_36.rkt:2:}}
```

## 1_37

``` lisp
{{#include ../../../source/solution_01/1_37.rkt:2:}}
```

## 1_38

``` lisp
{{#include ../../../source/solution_01/1_38.rkt:2:}}
```

## 1_39

``` lisp
{{#include ../../../source/solution_01/1_39.rkt:2:}}
```

## 1_40

``` lisp
{{#include ../../../source/solution_01/1_40.rkt:2:}}
```

## 1_41

``` lisp
{{#include ../../../source/solution_01/1_41.rkt:2:}}
```

## 1_42

``` lisp
{{#include ../../../source/solution_01/1_42.rkt:2:}}
```

## 1_43

``` lisp
{{#include ../../../source/solution_01/1_43.rkt:2:}}
```

## 1_44

``` lisp
{{#include ../../../source/solution_01/1_44.rkt:2:}}
```

## 1_45

``` lisp
{{#include ../../../source/solution_01/1_45.rkt:2:}}
```

## 1_46

``` lisp
{{#include ../../../source/solution_01/1_46.rkt:2:}}
```

