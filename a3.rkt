#lang pl 

#|

CS3613 Assignment 3
Due 29 January at 23:59

Question 1:

In class we have seen the grammar for AE, a simple language for
"Arithmetic Expressions".  Write a BNF for "KE" a similarly simple
language of "Kons Expressions". Valid "programs" in this language
should correspond to lists of numbers built using kons. Kons behaves
very similarly to Racket's cons, except that the first argument to
kons must be either a number or a non-null list, but not a null list.

For example, some valid expressions in KE are:

null
(kons 1 null)
(kons 1 (kons 2 null))
(kons (kons 1 null) null)
(kons 1 (kons (kons 2 null) null))

but the following are invalid expressions:

1
(kons 1 2)
(kons 1 2 null)
(kons null null)
(kons null (kons 1 null))

Write a BNF for this language. Ensure that it is not ambiguous, and
that it does not include any redundant rules.

Write your BNF here (i.e., in the comment)...

<KE>::= null
      | (kons <ITEM> <KE>)

<ITEM>::= <num>
      | (kons <num> <KE>)






2. Here is the interpreter for AE. It's the same as the version that
we saw in class, and that's posted to D2L. In this assignment we'll be
extending this interpreter in a few ways.

A. Modify the interpreter to use postfix notation (but still fully
   parenthesized, to keep things simple) as opposed to prefix
   notation. E.g., instead of {+ 1 2} you would write {1 2 +}. To do
   this you will need to change the BNF (in the comment before the
   interpreter) and the parser (i.e., parse-sexpr), and update the
   tests. (Hint: this is actually quite easy. If you're writing lots
   of new code you're probably off-track.)

B. Notice what happens when you divide by 0, e.g., (run "{5 0 /}") (in
   our new postfix syntax!).  We get a Racket "division by zero"
   error. Fix this by making division by 0 evaluate to
   infinity. Racket provides a value for infinity: +inf.0 To do this
   you should only have to modify eval. Here's a simple test case:

   (test (run "{5 0 /}") => +inf.0)

   You will want to include further tests to make sure things are
   working as intendend.

C. Add a new add1 expression to the interpreter. It will also use the
   new postfix notation. You will have to modify the BNF, the AE type,
   the parser, and eval. Here are some new test cases:

   (test (run "{1 add1}") => 2)
   (test (run "{{2 3 +} add1}") => 6)


 BNF for the AE language:
   <AE>: <num>
          | { <AE> <AE> + }
          | { <AE> <AE> - }
          | { <AE> <AE> * }
          | { <AE> <AE> / }
          | { <AE> add1 }
|#

;; AE abstract syntax trees
(define-type AE
  [Num Number]
  [Add AE AE]
  [Sub AE AE]
  [Mul AE AE]
  [Div AE AE]
  [Add1 AE])

(: parse-sexpr : Sexpr -> AE)
(define (parse-sexpr sexpr)
  (match sexpr
    [(number: n) (Num n)]
    [(list lhs rhs '+)
     (Add (parse-sexpr lhs) (parse-sexpr rhs))]
    [(list lhs rhs '-)
     (Sub (parse-sexpr lhs) (parse-sexpr rhs))]
    [(list lhs rhs '*)
     (Mul (parse-sexpr lhs) (parse-sexpr rhs))]
    [(list lhs rhs '/)
     (Div (parse-sexpr lhs) (parse-sexpr rhs))]
    [(list x 'add1)
     (Add1 (parse-sexpr x))]
    [else
     (error 'parse-sexpr "bad syntax in ~s" sexpr)]))

(: parse : String -> AE)
(define (parse str)
  (parse-sexpr (string->sexpr str)))

(: eval : AE -> Number)
(define (eval expr)
  (cases expr
    [(Num n)   n]
    [(Add l r) (+ (eval l) (eval r))]
    [(Sub l r) (- (eval l) (eval r))]
    [(Mul l r) (* (eval l) (eval r))]
    [(Div l r) (let ((r-val (eval r)))
                 (if (= 0 r-val)
                     +inf.0
                     (/ (eval l) r-val)))]
    [(Add1 x) (add1 (eval x))]))

(: run : String -> Number)
(define (run str)
  (eval (parse str)))

(test (run "3") => 3)
(test (run "{3 4 + }") => 7)
(test (run "{{3 4 -} 7 +}") => 6)
(test (run "{{3 2 *} 1 +}") => 7)
(test (run "{6 3 /}") => 2)
(test (run "{3 +}") =error> "bad syntax in (3 +)")
(test (run "{5 0 /}") => +inf.0)
(test (run "{1 add1}") => 2)
(test (run "{{2 3 +} add1}") => 6)
