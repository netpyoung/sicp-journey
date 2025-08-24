# VsCode 설정

DrRacket을 쓰면 상관없지만, VsCode로 하고싶다면

- Vscode: Visual Studio Code (VSCode)는 마이크로소프트에서 개발한 소스 코드 편집기이다.
  - <https://code.visualstudio.com/>
- Magic Racket: Racket 언어를 위한 VSCode 확장 프로그램
  - <https://marketplace.visualstudio.com/items?itemName=evzen-wybitul.magic-racket>
- Racket Helpers
  - S-expression 영역 선택
  - <https://marketplace.visualstudio.com/items?itemName=Calvin-LL.racket-helpers>

## racket-rangserver 설치

- raco: racket 관리 도구(패키지, 문서, 빌드 등등)
  - <https://docs.racket-lang.org/raco/index.html>
  - Windows라면 `C:\Program Files\Racket` 폴더에 있음.

``` zsh
raco pkg install racket-langserver
Would you like to install these dependencies? [Y/n/a/c/?]

raco pkg update racket-langserver

# sicp 설치(필요시)
raco pkg install sicp
```