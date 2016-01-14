#lang pl

;; Assignment 1
;; Due 15 January at 23:59
;; Submit your solution to the assignment 1 Dropbox on D2L.
;; You must use #lang pl for this assignment.

;; 1. Add type declarations to the following functions to get them to compile,
;; and enough tests to get complete coverage.

(: foo : Boolean -> String )
(define (foo x)
  (if (not x)
      "yes"
      "no"))

;; Test cases for foo
(test (foo #t) => "no")
(test (foo #f) => "yes")

(: bar : (Listof Boolean) -> (Listof Char))
(define (bar x)
  (if (null? x)
      null
      (cons (string-ref (foo (first x)) 0) (bar (rest x)))))

;; Test cases for bar
(test (bar (list #t #f)) => (list #\n #\y))
(test (bar (list #f #t)) => (list #\y #\n))


(: baz : (U Boolean Number) String -> String)
(define (baz x y)
  (cond
    [(boolean? x) (string-append (foo x) y)]
    [(number? x) (string-append (number->string x) y)]))

; Test cases for baz
(test (baz #t "abc") => "noabc")
(test (baz 5 "abc") => "5abc")


;; 2. Given the following type definition, and definition of pi, define a 
;; function called volume with type declaration (: volume : Shape -> Number)
;; that passes the provided tests. Hint: The function expt might be helpful
;; here.

(define pi 3.14)
(define-type Shape
  [Sphere Number] ; radius
  [Cube Number] ; side length
  [Cone Number Number]) ; radius height

(: volume : Shape -> Number)
(define (volume x)
  (cases x
    [(Sphere y) (* 4/3 pi (expt y 3))]
    [(Cube y) (expt y 3)]
    [(Cone y z) (* pi (expt y 2) (/ z 3))]))
  

(test (volume (Sphere 2)) => (* 32/3 pi))
(test (volume (Cube 3)) => 27)
(test (volume (Cone 3 4)) => (* 36/3 pi))

;; 3. Define a function called bin->num with the type declaration
;; (: bin->num : (Listof (U Zero One)) -> Number)
;; that passes the provided tests. It consumes a list of binary digits (0's 
;; and 1's) representing a binary number, and produces the corresponding
;; decimal number. Hint: The functions length and expt might be helpful here.

(: bin->num : (Listof (U Zero One)) -> Number)
(define (bin->num x)
  (if (= (length x) 0)
      0
      (+ (* (first x) (expt 2 (- (length x) 1))) (bin->num (rest x)))))

(test (bin->num '()) => 0) 
(test (bin->num '(0)) => 0)
(test (bin->num '(1)) => 1) 
(test (bin->num '(1 0)) => 2)
(test (bin->num '(0 1)) => 1)
(test (bin->num '(1 0 1)) => 5)
(test (bin->num '(1 1 0 0)) => 12)
(test (bin->num '(1 0 1 0 1 1)) => 43)