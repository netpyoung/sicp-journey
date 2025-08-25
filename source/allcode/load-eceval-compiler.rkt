#lang sicp

;;;; LOADS THE EXPLICIT-CONTROL EVALUATOR FROM SECTION 5.4 OF
;;;; STRUCTURE AND INTERPRETATION OF COMPUTER PROGRAMS, WITH
;;;; ALL THE SUPPORTING CODE IT NEEDS IN ORDER TO RUN.

;;;;This is like load-eceval.scm except that it loads the version
;;;; of eceval that interfaces with compiled code
;;;;It doesn't load the compiler itself -- loading the compiler is up to you.

;;;; **NB** The actual "load" calls are implementation dependent.

;(load "ch5-regsim")			;reg machine simulator

;; **NB** next file contains another "load"
;(load "ch5-eceval-support")		;simulation of machine operations

;;**NB** eceval-compiler *must* be loaded after eceval-support,
;;  so that the version of user-print in eceval-compiler will override
;;  the version in eceval-support
;(load "ch5-eceval-compiler")		;eceval itself
					;and interface to compiled code

(#%require (prefix racket: racket))
(racket:require "ch5-regsim.rkt")
(racket:require (racket:except-in "ch5-eceval-support.rkt" user-print the-global-environment))
(racket:require "ch5-eceval-compiler.rkt")
(racket:provide (racket:all-from-out "ch5-regsim.rkt"))
(racket:provide (racket:all-from-out "ch5-eceval-support.rkt"))
(racket:provide (racket:all-from-out "ch5-eceval-compiler.rkt"))
