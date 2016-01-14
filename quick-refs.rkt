#lang pl
					;
;; The first line above is important. It
;; tells racket which variant of Racket
;; you want to use. We will mainly use
;; "pl" or "typed/racket"
					;
;; This file is by Mathew Flatt, U. of
;; Utah Converted to typed-racket/pl by
;; David Bremner, UNB, and updated by
;; Paul Cook.
					;
;; This is a comment that continues to
;; the end of the line.
; One semi-colon is enough.
					;
;; A common convention is to use two
;; semi-colons for multiple lines of
;; comments, and a single semi-colon when
;; adding a comment on the same line as
;; code.  


#| This is a block comment, which starts
with '#|' and ends with a '|#'.  Block
comments can be nested, which is why I
can name the start and end tokens in this
comment. Unfortunately the syntax
highlighter is not that clever |#

;; #; comments out a single form. We use
;; #; below to comment out error
;; examples.
#;(/ 1 0)
					
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Built-in atomic data
					;
;; Booleans
					;
true
false
#t ; another name for true, and the way
   ; it prints
#f ; ditto for false

;; Numbers
					;
1
0.5
1/2  ; this is a literal fraction, not a division operation
1+2i ; complex number

;; Strings
					;
"apple"
"banana cream pie"

;; Symbols
					;
'apple
'banana-cream-pie
'a->b
'#%$^@*&?!

;; Characters (unlikely to be useful)
					;
#\a
#\b
#\A
#\space  ; same as #\  (with a space after \)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Built-in functions on atomic data
					;
not
					;
+
-
*
; etc.
					;
<
>
=
<=
>=

;;
string-append
string=?
string-ref
					;
eq?      ; mostly for symbols
equal?   ; most other things
number?
real?
symbol?
string?

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Basic expression forms
					;
;; Procedure application
;;  (<expr> <expr>*)
					;
(not true)                ; => #f
					;
(+ 1 2)                   ; => 3
(< 2 1)                   ; => #f
(= 1 1)                   ; => #t
					;
(string-append "a" "b")   ; => "ab"
(string-ref "apple" 0)    ; => #\a

(eq? 'apple 'apple)       ; => #t
(eq? 'apple 'orange)      ; => #f
(eq? "apple" "apple")     ; => #f, probably
					;
(equal? "apple" "apple")  ; => #t
(string=? "apple" "apple"); => #t
					;
(null? null)            ; => #t
					;
(number? null)           ; => #f
(number? 12)              ; => #t
(real? 1+2i)              ; => #f

;; Conditionals
;;  (cond
;;    [<expr> <expr>]*)
;;  (cond
;;    [<expr> <expr>]*
;;    [else <expr>])
;
(cond                     ;
  [(< 2 1) 17]            ;
  [(> 2 1) 18])           ; => 18
					;
;; second expression not evaluated
(cond                     
  [true 8]                ;
  [false (* 'a 'b)])      ; => 8
					
;; any number of cond-lines allowed
(cond 
  [(< 3 1) 0]             ;
  [(< 3 2) 1]             ;
  [(< 3 3) 2]             ;
  [(< 3 4) 3])            ; => 3
					;
;; else allowed as last case
(cond                     
  [(eq? 'a 'b) 0]         ;
  [(eq? 'a 'c) 1]         ;
  [else 2])               ; => 2
					;
(cond
  [(< 3 1) 1]
  [(< 3 2) 2])            ; => prints nothing
					;
(void)                    ; => prints nothing
					
;; If
;;   (if <expr> <expr> <expr>)
					;  
(if (< 3 1)               ; simpler form for single test
    "apple"               ;
    "banana")             ; => "banana"
				       
;; And and Or
;;  (and <expr>*)
;;  (or <expr>*)
					;
(and true true)           ; => #t
(and true false)          ; => #f
(and (< 2 1) true)        ; => #f
(and (< 2 1) (+ 'a 'b))   ; => #f (second expression is not evaluated)

(or false true)           ; #t
(or false false)          ; #f
;
(and true true true true) ; => #t
(or false false false)    ; => #f
;
(and true 1)              ; => 1, because only `false' is false

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Built-in compound data
;
;; Lists
;
null                     ; => '()
;
(list 1 2 3)              ; => '(1 2 3)
(cons 0 (list 1 2 3))     ; => '(0 1 2 3)
;
(list 'a 'b)              ; => '(a b), because ' also distributes to elements

'1                        ; => 1, because numbers are self-quoting
'"a"                      ; => "a", ditto
(list "a" "b")            ; => '("a" "b")
'("a" "b")                ; => '("a" "b")
'((1 2) (3 4))            ; => (list (list 1 2) (list 3 4))

(cons 1 null)            ; => '(1)
(cons 1 '())              ; => '(1)
(cons 'a (cons 2 null))  ; => '(a 2)
;
(list 1 2 3 null)        ; => '(1 2 3 ())

(append (list 1 2) null) ; => '(1 2)
(append (list 1 2)
        (list 3 4))       ; => '(1 2 3 4)
(append (list 1 2)
        (list 'a 'b)
        (list true))      ; => '(1 2 a b #t)

(first (list 1 2 3))      ; => 1
(rest (list 1 2 3))       ; => '(2 3)
(first (rest (list 1 2))) ; => 2
;
(list-ref '(1 2 3) 2)     ; => 3

;; Vectors
;
; '#(...) creates a vector, and #(...) is self-quoting
'#(1 2)                   ; => '#(1 2)
#(1 (2 3))                ; => '#(1 (list 2 3))
#(a b)                    ; => '#(a b)
;
(vector-ref #(a b c) 2)   ; => 'c

;; Boxes
;
(box 1)                   ; => '#&1
(unbox (box 1))           ; => 1
;
'#&1                      ; => '#&1
#&1                       ; => '#&1

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Definitions
;
;; Defining constants
;;  (define <id> <expr>)
					;
(define PI 3.14159)
(* PI 10)                 ; => 31.4159
					;
;; (: <id> <type>)
(: PI2 Real)
(define PI2 (* PI PI))

;; Defining functions
;;  (define (<id> <id>*) <expr>)
;
(: circle-area : Number -> Number )
(define (circle-area r)
  (* PI r r))
(circle-area 10)          ; => 314.159
					;
(: is-odd? : Number -> Boolean)
(define (is-odd? x)
  (if (zero? x)
      false
      (is-even? (- x 1))))
;
(: is-even? : Number -> Boolean)
(define (is-even? x)
  (if (zero? x)
      true
      (is-odd? (- x 1))))
(is-odd? 12)              ; => #f

;; Defining datatypes
;;  (define-type <id>
;;    [<id> (<id> <type>)*]*)
;
(define-type Animal
  [Snake  Symbol Number Symbol ]
  [Tiger  Symbol  Number])
					;
(Snake 'Slimey 10 'rats)  ; => (Snake 'Slimey 10 'rats)
(Tiger 'Tony 12)          ; => (Tiger 'Tony 12)
					
(list (Tiger 'Tony 12))   
;; => (list (Tiger 'Tony 12)) since use of
;; `Tiger' cannot be
; quoted
					;
#;(Snake 10 'Slimey 5)    ; => error: 10 is not a symbol
					;
(Animal? (Snake 'Slimey 10 'rats)) ; => #t
(Animal? (Tiger 'Tony 12)) ; => #t
(Animal? 10)               ; => #f

;; A type can have any number of variants:
(define-type Shape
  [Square Number]
  [Circle Number]
  [Triangle Number Number])
					;
(Shape? (Triangle 10 12)) ; => #t

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Local binding forms
					;
;;  (let ([<id> <expr>]*) <expr>)
					;
(let ([x 10]
      [y 11])
  (+ x y))                ; => 21
					;
(let ([x 0])
  (let ([x 10]
        [y (+ x 1)])
    (+ x y)))             ; => 11
					;
(let ([x 0])
  (let* ([x 10]
         [y (+ x 1)])
    (+ x y)))             ; => 21

;; Datatype case dispatch
;;  (cases  <expr>
;;    [(<id> <id>*) <expr>]*)
;;  (cases <expr>
;;    [<id> (<id>*) <expr>]*
;;    [else <expr>])
;
(cases (Snake 'Slimey 10 'rats)
  [(Snake n w f) n]
  [(Tiger n sc) n])      ; => 'Slimey
					;
(: animal-name : Animal -> Symbol)
(define (animal-name a)
  (cases a
    [(Snake n w f) n]
    [(Tiger n sc) n]))
					
(animal-name (Snake 'Slimey 10 'rats)) ; => 'Slimey
(animal-name (Tiger 'Tony 12)) ; => 'Tony
					;
#;(animal-name 10)        ; => error: Type error
;
(: animal-weight : Animal -> (U Number #f))
(define (animal-weight a)
  (cases a
    [(Snake n w f) w]
    [else #f]))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; First-class functions
;
;; Anonymous function:
;;  (lambda (<id>*) <expr>)
;;  (lambda ( (<id> : <type>)* ) <expr>)
;
 (lambda [(x : Number)] (+ x 1))      
;; => #<procedure>
;
;; Note the type annotation is not needed here
;
((lambda (x) (+ x 1)) 10) ; => 11


(define add-one
  (lambda [(x : Number)]
    (+ x 1)))
(add-one 10)              ; => 11

;; Similarly note here the inner lambda does not need annotation
(: make-adder : Number -> (Number -> Number))
(define (make-adder n)
  (lambda (m)
    (+ m n)))
(make-adder 8)            ; => #<procedure>
(define add-five (make-adder 5))
(add-five 12)             ; => 17
((make-adder 5) 12)       ; => 17

(map (lambda [(x : Number)]
       (* x x))
     '(1 2 3))            ; => (list 1 4 9)
;
(andmap (lambda [(x : Number)] (< x 10))
        '(1 2 3))         ; => #t
(andmap (lambda [(x : Number)]
                  (< x 10))
        '(1 20 3))        ; => #f

;; The apply function may be useful eventually:
					;
(: f :  Number Number Number -> Number)
(define (f a b c) (+ a (- b c)))
(define l '(1 2 3))
					;
#;(f l)                   ; => error: f expects 3 arguments
(apply f l)               ; => 0
;
;; apply is most useful with functions that accept any
;;  number of arguments:
;
(apply + '(1 2 3 4 5))    ; => 15

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Side-effects 
;;
;; IMPORTANT: in this class using a
;; side-effect is usually wrong
					;
;; set! and begin
;;  (set! <id> <expr>)
;;  (begin <expr>*)
					;
(define count 0)
					;
(set! count (+ count 1))  ; =>
count                     ; => 1
					;
(begin
  (set! count (+ count 1))
  count)                  ; => 2
					
(let [(x 0)]     
  (begin             
    (set! x (+ x 1)) 
    (set! x (+ x 1)) 
    x))                   ; => 2

;; set-box! is a function with side effects:
;
(define B (box 10))
(set-box! B 12)           ; =>
B                         ; => '#&12
(unbox B)                 ; => 12

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Testing
;
(test (+ 5 5) => 10)         
			; => '(good 10 10 "...")
#;(test (+ 5 4) => 10)         
			; => '(bad 9 10 "...")

;; testing errors
;; match the whole thing
(test (error 'test "this is a test") =error> "this is a test")

;; match a prefix
(test (error 'test "this is a test") =error> "this is")

;; match with single character wildcard 
(test (error 'test "this is a test") =error> "this is ? test")

;; zero or more characters match *
(test (error 'test "this is a test") =error> "this * test")

;; similar for output
(test (display "hi mom") =output> "hi mom")
(test (begin (display "hi mom") 'hello) => 'hello =output> "hi mom")