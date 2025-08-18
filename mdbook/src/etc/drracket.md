# DrRacket

The Racket Programming Environment

- [다운로드](https://download.racket-lang.org/)
  - [깔깔앵무의 정리노트 - [프로그래밍언어] Racket 설치 및 SICP 모듈 설정(1)](https://kkalkkalparrot.tistory.com/31)
  - [깔깔앵무의 정리노트 - [프로그래밍언어] Racket 설치 및 SICP 모듈 설정(2)](https://kkalkkalparrot.tistory.com/32)

## 왜 DrRacket

- ref: <https://github.com/zv/SICP-guile?tab=readme-ov-file#language>
  - Zetavolt이란 분은 GNU Guile을 추천함.

|                | PL          | r5rs | 함수 재정의 | GUI IDE                       |
| -------------- | ----------- | ---- | ----------- | ----------------------------- |
| DrRacket       | Racket      | O    | X           | DrRacket                      |
| MITScheme      | Scheme      | O    | O           | X                             |
| GNU Guile      | Scheme      | O    | O           | X                             |
| CHICKEN Scheme | Scheme      | O    | O           | X                             |
| SBCL           | Common Lisp | X    | O           | Slt Plugin for JetBrains IDEs |
| LispWorks      | Common Lisp | X    | O           | LispWorks                     |

- Common Lisp로 하는건 일단 배제하고,
- **Emacs 사용이 자유로운 사람**이라면, 함수를 계속 덮어쓰므로 Scheme구현체 중 하나를 선택하면 좋다.
- **단점!** 물론 불러온 함수 재정의가 안되는 치명적인 단점과 필요에 따라 추가적인 racket문법을 익혀야 한다는 단점이 있다.
- **장점!** 설치도 간편. IDE를 지원하는게 DrRacket이 유일. 디버거도 그럭저럭 쓸만하고, racket 패키지들도 유용하고 문서화가 잘 되어 있다.
- 단점도 엄청 치명적이긴 한데 IDE지원이라는 장점이 진입장벽을 낮춤으로써 단점보다 조금 더 낫다고 생각했다.

## 흔히 쓰게될 단축키

|                    | 단축키           |                    |                                                                                                       |
| ------------------ | ---------------- | ------------------ | ----------------------------------------------------------------------------------------------------- |
| 파일 실행          | Ctrl + R  / F5   |                    |                                                                                                       |
| 코드 포맷          | Ctrl + I         |                    |                                                                                                       |
| 코드 <=> Repl 전환 | Ctrl + F6        | shift-focus        |                                                                                                       |
| λ 문자 삽입        | Ctrl + \         | insert λ           | #lang racket에선 lambda대신 λ도 가능                                                                  |
| 자동완성           | Ctrl + /         | Complete Word      |                                                                                                       |
| 파일 버퍼 되돌리기 | Ctrl + Shift + E | Revert             | 외부 에디터에서 파일을 수정해도 자동으로 버퍼를 갱신하지 않으니 외부에서 파일 수정시 버퍼 초기화 용도 |
| 인덴트 가이드      | Ctrl + Shift + I | Show Indent Guides |                                                                                                       |

- 정의로 가기는 단축키가 없다
  - 함수 이름 우클릭 > Jump to definition of {blabla}? 클릭

## Tip

### SICP가 설치가 안되어 있다면

- File > Package Manager... 쪽에서 sicp를 찾아보면 된다
  - <https://docs.racket-lang.org/sicp-manual/SICP_Language.html>
  - <https://github.com/sicp-lang/sicp/tree/master>

### 코드 색깔 바꾸기

- define이라도 색깔이 다르면 좀 더 코드가 보기 편해진다.
- 다음 사이트에서 원하는 테마를 고르고
  - <https://github.com/tuirgin/base16-drracket>
  - <https://github.com/catppuccin/drracket>

- File > Package Manager... 쪽에서
  - `https://github.com/tuirgin/base16-drracket` 를 붙여넣어서 설치 하거나
  - `https://github.com/catppuccin/drracket` 를 붙여넣어서 설치

### 코드 포맷

- 메뉴> Racket > Reindent All
- 혹은 단축키 Ctrl + I
- 혹은 전체 선택(Ctrl + A) 후 Tab

### 백업파일(.bak) 생성 안되게

- 메뉴> Edit > Preferences...
  - General 탭
    - Make backups for unsaved files 체크 해제
    - Create first-change files 체크 해제

### Emacs 키 바인딩이 그립다면

- 메뉴> Edit > Preferences...
  - Editing 탭
    - General Editing탭
      - Enable keybindings in menus (overrides Emacs keybindings) 체크 해제
- ref
  - <https://docs.racket-lang.org/drracket/Keyboard_Shortcuts.html>
  - <https://blog.racket-lang.org/2009/03/the-drscheme-repl-isnt-the-one-in-emacs.html>
  - <https://stackoverflow.com/questions/56916606/drracket-custom-keybindings>

- emacs
  - <https://docs.racket-lang.org/guide/Emacs.html>
    - <https://www.nongnu.org/geiser/>
    - <https://github.com/emacsmirror/geiser?tab=readme-ov-file>

### 쓰레딩 매크로( ~> / ~>> )를 사용하고 싶다면

- [threading](https://github.com/lexi-lambda/threading)
  - clojure -> / ->> 와는 다르게 ~> / ~>> 이다

``` lisp
#lang sicp
(#%require threading)

(~> 2 (/ 5))
;;=> 2/5

(~>> 2 (/ 5))
;;=> 5/2
```

### 유닛테스트를 하고 싶다면?

- [rackunit](https://docs.racket-lang.org/rackunit/)

``` lisp
#lang sicp

(#%require rackunit)

(check-equal? (+ 1 2) 3)
;; (check-equal? <expected> <actual> <message>)
```

### DrRacket 디버거 사용이 힘들어 그냥 쉽게 출력해서 보고 싶다면

- <https://docs.racket-lang.org/debug/index.html>

``` lisp
#lang debug sicp
(+ 1 2 #R(* 3 4))
;;>> {* 3 4} = 12
;;=> 15
```

### 함수 수행을 따라가 보고 싶다면

- <https://docs.racket-lang.org/reference/debugging.html>

```
#lang sicp

(define (f x)
  (if (zero? x) 0
      (add1 (f (sub1 x)))))

(#%require (prefix trace: racket/trace))
(trace:trace f)
```

### todo errortrace

"C:\Program Files\Racket\Racket.exe" -l errortrace -t 4_08.rkt
- https://docs.racket-lang.org/errortrace/using-errortrace.html

### todo pretty print

- https://docs.racket-lang.org/reference/pretty-print.html

### TODO sandbox

- https://docs.racket-lang.org/reference/Sandboxed_Evaluation.html

### 기타 문법

``` lisp

;; 블록 코맨트( #; )
#;(error "wtf")


;; TODO 설명 필요

(#%require (prefix racket: racket))
(racket:provide (racket:all-defined-out))
```
