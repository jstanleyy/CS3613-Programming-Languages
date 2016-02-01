#lang pl

#| BNF for the WAE language:
       <WAE> ::= <num>
               | { + <WAE> ... }
               | { - <WAE> ... }
               | { * <WAE> <WAE> ... }
               | { / <WAE> <WAE> ... }
               | { with { <id> <WAE> } <WAE> }
               | <id>

   Formal specs for `subst':
   (`N' is a <num>, `E1', `E2' are <WAE>s, `x' is some <id>, 
   `y' is a *different* <id>)
      N[v/x]                = N
      {+ E ...}[v/x]        = {+ E[v/x] ...}
      {* E ...}[v/x]        = {* E[v/x] ...}
      {- E1 E ...}[v/x]     = {- E1[v/x] E[v/x] ...}
      {/ E1 E ...}[v/x]     = {/ E1[v/x] E[v/x] ...}
      y[v/x]                = y
      x[v/x]                = v
      {with {y E1} E2}[v/x] = {with {y E1[v/x]} E2[v/x]}
      {with {x E1} E2}[v/x] = {with {x E1[v/x]} E2}

   Formal specs for `eval':
     eval(N)             = N
     eval(+)             = 0
     eval({+ E ...})     = evalN(E) + ...
     eval(*)             = 1
     eval({* E ...})     = evalN(E) * ...
     eval({- E})         = -evalN(E)
     eval({/ E})         = 1/evalN(E)
     eval({- E1 E ...})  = evalN(E1) - (evalN(E) + ...)
     eval({/ E1 E ...})  = evalN(E1) / (evalN(E) * ...)
     eval(id)            = error!
     eval({with {x E1} E2}) = eval(E2[eval(E1)/x])
|#

;; WAE abstract syntax trees
(define-type WAE
  [Num  Number]
  [Add  (Listof WAE)]
  [Sub  WAE (Listof WAE)]
  [Mul  (Listof WAE)]
  [Div  WAE (Listof WAE)]
  [Id   Symbol]
  [With Symbol WAE WAE])

(: parse-sexpr : Sexpr -> WAE)
;; to convert s-expressions into WAEs
(define (parse-sexpr sexpr)
  (match sexpr
    [(number: n)    (Num n)]
    [(symbol: name) (Id name)]
    [(cons 'with more)
     (match sexpr
       [(list 'with (list (symbol: name) named) body)
        (With name (parse-sexpr named) (parse-sexpr body))]
       [else (error 'parse-sexpr "bad `with' syntax in ~s" sexpr)])]
    [(list '+ args ...) (Add (map parse-sexpr args))]
    [(list '- fst args ...) (Sub (parse-sexpr fst) (map parse-sexpr args))]
    [(list '* args ...) (Mul (map parse-sexpr args))]
    [(list '/ fst args ...) (Div (parse-sexpr fst) (map parse-sexpr args))]
    [else (error 'parse-sexpr "bad syntax in ~s" sexpr)]))

(: parse : String -> WAE)
;; parses a string containing a WAE expression to a WAE AST
(define (parse str)
  (parse-sexpr (string->sexpr str)))

(: substs : (Listof WAE) Symbol WAE -> (Listof WAE))
; convenient helper
(define (substs exprs from to)
  (map (lambda ((x : WAE)) (subst x from to)) exprs))

(: subst : WAE Symbol WAE -> WAE)
;; substitutes the second argument with the third argument in the
;; first argument, as per the rules of substitution; the resulting
;; expression contains no free instances of the second argument
(define (subst expr from to)
  (cases expr
    [(Num n) expr]
    [(Add args) (Add (substs args from to))]
    [(Sub fst args) (Sub (subst fst from to) (substs args from to))]
    [(Mul args) (Mul (substs args from to))]
    [(Div fst args) (Div (subst fst from to) (substs args from to))]
    [(Id name) (if (eq? name from) to expr)]
    [(With bound-id named-expr bound-body)
     (With bound-id
           (subst named-expr from to)
           (if (eq? bound-id from)
               bound-body
               (subst bound-body from to)))]))

(: eval : WAE -> Number)
;; evaluates WAE expressions by reducing them to numbers
(define (eval expr)
  (cases expr
    [(Num n) n]
    [(Add args) (if (null? args)
                    0
                    (foldl + 0 (map eval args)))]
    [(Sub fst args) (let ([x (eval fst)])
                      (if (null? args)
                        (- 0 x)
                        (sub-helper x (map eval args))))]
    [(Mul args) (if (null? args)
                    1
                    (foldl * 1 (map eval args)))]
    [(Div fst args) (let ([x (eval fst)])
                      (cond 
                        [(and (null? args) (= x 0)) (error 'eval "division by zero")]
                        [(null? args) (/ 1 x)]
                        [else (div-helper x (map eval args))]))]
    [(With bound-id named-expr bound-body)
     (eval (subst bound-body
                  bound-id
                  (Num (eval named-expr))))]
    [(Id name) (error 'eval "free identifier: ~s" name)]))

;; Used to calculate subtraction.
(: sub-helper : Number (Listof Number) -> Number)
(define (sub-helper x lst)
  (if (null? lst)
      x
      (sub-helper (- x (first lst)) (rest lst))))

;; Used to calculate division.
(: div-helper : Number (Listof Number) -> Number)
(define (div-helper x lst)
  (cond
    [(null? lst) x]
    [(= 0 (first lst)) (error 'eval "division by zero")]
    [else (div-helper (/ x (first lst)) (rest lst))]))
  
(: run : String -> Number)
;; evaluate a WAE program contained in a string
(define (run str)
  (eval (parse str)))

;; tests
(test (run "5") => 5)
(test (run "{+ 5 5}") => 10)
(test (run "{with {x {+ 5 5}} {+ x x}}") => 20)
(test (run "{with {x 5} {+ x x}}") => 10)
(test (run "{with {x {+ 5 5}} {with {y {- x 3}} {+ y y}}}") => 14)
(test (run "{with {x 5} {with {y {- x 3}} {+ y y}}}") => 4)
(test (run "{with {x 5} {+ x {with {x 3} 10}}}") => 15)
(test (run "{with {x 5} {+ x {with {x 3} x}}}") => 8)
(test (run "{with {x 5} {+ x {with {y 3} x}}}") => 10)
(test (run "{with {x 5} {with {y x} y}}") => 5)
(test (run "{with {x 5} {with {x x} x}}") => 5)
(test (run "{with {x 1} y}") =error> "free identifier")

;; added test for complete coverage
(test (run "{with {x 5} {* x x}}") => 25)
(test (run "{test}") =error> "bad syntax")
(test (run "{with {x 4} {/ x 2}}") => 2)
(test (run "{with {test}}") =error> "bad `with' syntax")

;; test Racket-like arithmetics
;; these tests should pass when you are done
(test (run "{+}") => 0)
(test (run "{*}") => 1)
(test (run "{+ 10}") => 10)
(test (run "{* 10}") => 10)
(test (run "{- 10}") => -10)
(test (run "{/ 10}") => 1/10)
(test (run "{+ 1 2 3 4}") => 10)
(test (run "{* 1 2 3 4}") => 24)
(test (run "{- 10 1 2 3 4}") => 0)
(test (run "{/ 24 1 2 3 4}") => 1)
(test (run "{+ {/ 24 1 3 4} {* 1 2 3} {- 7 3 1}}") => 11)
(test (run "{/ 1 0}") =error> "division by zero")
(test (run "{/ 0}") =error> "division by zero")
