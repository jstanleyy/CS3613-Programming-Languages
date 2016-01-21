#lang pl

;; Homework 2
;; Due Friday 22 January at 23:59
;; 
;; Be sure to follow the coding style guidelines discussed in class (and 
;; posted on D2l under References). Also make sure to include appropriate
;; tests, that provide full coverage, for all code you write.

;; 1. Consider the following non-tail recursive function make-list-nontr,
;; which takes an natural n and a value v of arbitary type, and
;; returns a list of n copies of v. Write a tail recursive version
;; of this function, and provide enough tests to achieve full coverage.
;;
;; Your solution to this question should not use built-in racket
;; functions like foldl to avoid recursion.

(: make-list-nontr : (All (A) Natural A -> (Listof A)))
(define (make-list-nontr n x)
  (if (= n 0)
      '()
      (cons x (make-list-nontr (- n 1) x))))

;; Added to get complete coverage
(test (make-list-nontr 5 1) => '(1 1 1 1 1))

; Write your tail recursive function here. Call it make-list
(: make-list : (All (A) Natural A -> (Listof A)))
(define (make-list n x)
  (make-list-helper n x '()))

(: make-list-helper : (All (A) Natural A (Listof A) -> (Listof A)))
(define (make-list-helper n x acc)
  (if (= n 0)
      acc
      (make-list-helper (- n 1) x (cons x acc))))

;; Test cases for make-list.
(test (make-list 5 1) => '(1 1 1 1 1))
(test (make-list 3 'a) => '(a a a))


;; 2. Define a higher order function comma-join with the following type
;; signature:
;;
;; (: comma-join : (All (A) (A -> String) (Listof A) -> String) )
;; 
;; This function should take a "formatter" function as a first
;; argument that converts A's to Strings, and join the resulting list
;; of strings with commas.  Note that you only need one pass over the
;; list. I've included an example test case below to show how it
;; should work; you are however responsible for adding enough tests to
;; achieve full coverage.
;;
;; For full marks your function must be tail recursive. Hint: start by
;; writing a non-tail recursive version, and then modify it to be tail
;; recursive.

(: comma-join : (All (A) (A -> String) (Listof A) -> String))
(define (comma-join func lst)
  (comma-join-helper func lst ""))

(: comma-join-helper : (All (A) (A -> String) (Listof A) String -> String))
(define (comma-join-helper func lst acc)
  (if (null? lst)
      acc
      (comma-join-helper func (rest lst) (string-append 
                                          acc 
                                          (func (first lst)) 
                                          ;; Ensures a comma is placed only if there is another element to come.
                                          (if (null? (rest lst))
                                              "" 
                                              ",")))))

(test (comma-join number->string '(1 2 3)) => "1,2,3")



;; 3. Consider the following type definition for a binary tree. Based
;;    on the type signatures and tests below, complete the function
;;    tree-map, which takes a function f and a tree t, and maps the
;;    given function recursively over the given tree, returning a tree
;;    of the results with the same shape. I've provided some tests to
;;    show how this function works.


; A function used in testing below
(: string-rev : String -> String)
(define (string-rev s)
  (if (equal? s "")
      ""
      (string-append (string-rev (substring s 1 (string-length s)))
                     (string (string-ref s 0)))))
(test (string-rev "") => "")
(test (string-rev "a") => "a")
(test (string-rev "aoeu") => "ueoa")

(define-type BINTREE
  [Empty]
  [Leaf String]
  [Node BINTREE BINTREE])

;; Maps a given function onto a given tree, and returns a new tree.
(: tree-map : (String -> String) BINTREE -> BINTREE)
(define (tree-map f t)
  (cases t
    [(Empty) (Empty)]
    [(Leaf str) (Leaf (f str))]
    [(Node l r) (Node (tree-map f l) (tree-map f r))])) 

(test (tree-map string-rev (Empty)) => (Empty))
(test (tree-map string-rev (Leaf "leaf")) => (Leaf "fael"))
(test (tree-map string-rev (Node (Leaf "leaf1") (Leaf "leaf2"))) 
      => (Node (Leaf "1fael") (Leaf "2fael")))
(test (tree-map (lambda (x) (string (string-ref x 0))) 
                (Node (Node (Leaf "aleaf") (Leaf "bleaf")) (Empty)))
      => (Node (Node (Leaf "a") (Leaf "b")) (Empty)))


;; 4. Consider the following function that computes the sum of the
;; absolute values of a list of numbers recursively.  An alternative
;; to using recursion to implement this is to use higher-order
;; functions. Implement a new version of sum-abs that uses foldl and
;; map instead of recursion.
;;
;; A correct solution will be very short (a one-liner). The function
;; abs might be helpful.

(: sum-abs-rec : (Listof Number) -> Number)
(define (sum-abs-rec lst)
  (if (null? lst)
      0
      (+ (abs (first lst)) (sum-abs-rec (rest lst)))))
(test (sum-abs-rec '()) => 0)
(test (sum-abs-rec '(-2)) => 2)
(test (sum-abs-rec '(1 -2 3)) => 6)

;; Computes the sum of the absolute values of a list without recursion
(: sum-abs : (Listof Number) -> Number)
(define (sum-abs lst)
  (foldl + 0 (map abs lst)))

;; Test cases for sum-abs
(test (sum-abs '()) => 0)
(test (sum-abs '(-2)) => 2)
(test (sum-abs '(1 -2 3)) => 6)








