#lang sicp

;;;; LOADS THE EXPLICIT-CONTROL EVALUATOR FROM SECTION 5.4 OF
;;;; STRUCTURE AND INTERPRETATION OF COMPUTER PROGRAMS, WITH
;;;; ALL THE SUPPORTING CODE IT NEEDS IN ORDER TO RUN.

;;;; **NB** The actual "load" calls are implementation dependent.

;(load "ch5-regsim.rkt")			;reg machine simulator

;; **NB** next file contains another "load"
;(load "ch5-eceval-support.rkt")		;simulation of machine operations

;(load "ch5-eceval.rkt")			;eceval itself

;; (racket:provide (racket:all-from-out "../allcode/ch4-4.1.1-mceval.rkt"))

(#%require (prefix racket: racket))
(racket:require (racket:except-in "ch5-regsim.rkt" reset!))
(racket:require "ch5-eceval-support.rkt")
(racket:require "ch5-eceval.rkt")
(racket:provide (racket:all-from-out "ch5-regsim.rkt"))
(racket:provide (racket:all-from-out "ch5-eceval-support.rkt"))
(racket:provide (racket:all-from-out "ch5-eceval.rkt"))
