# DrRacket

The Racket Programming Environment

- [다운로드](https://download.racket-lang.org/)

## 흔히 쓰게될 단축키

|                    | 단축키         |               |
| ------------------ | -------------- | ------------- |
| 파일 실행          | Ctrl + R  / F5 |               |
| 코드 정렬          | Ctrl + I       |               |
| 코드 <=> Repl 전환 | Ctrl + F6      | shift-focus   |
| λ 문자 삽입        | Ctrl + \       | insert λ      |
| 자동완성           | Ctrl + /       | Complete Word |

- 정의로 가기는 단축키가 없다
  - 함수 이름 우클릭 > Jump to definition of {blabla}? 클릭

## Tip

### SICP가 설치가 안되어 있다면

- File > Package Manager... 쪽에서 sicp를 찾아보면 된다
  - <https://docs.racket-lang.org/sicp-manual/SICP_Language.html>

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
```

### DrRacket 디버거 사용이 힘들어 그냥 쉽게 출력해서 보고 싶다면

https://docs.racket-lang.org/debug/index.html


``` lisp
#lang debug sicp
(+ 1 2 #R(* 3 4))
;;>> {* 3 4} = 12
;;=> 15
```

### 기타 문법

``` lisp

;; 블록 코맨트( #; )
#;(error "wtf")


;; TODO 설명 필요

(#%require threading)

(#%require (prefix racket/ racket))
(racket/provide (racket/all-defined-out))

(#%require "../allcode/ch4-4.1.1-mceval.rkt")
```
