# Partial Applications & Currying - December 18, 2019

# Key Functional Programming Concepts
- First class and higher order functions - Functions for everything!
- Pure Functions: given a function and an input value you will always receive the same output. That is to say there is no external state used in the function.
- Type Systems: Swift surely is strictly typed!

# What is Currying?

Currying is when a function does not take all of it's arguments up front.  You give a function a single parameters, it returns a function with a single parameter. And this can continue down a chain until you reach a function that returns the value that you want.

# What is a Partial Application?

Currying takes exactly 1 input, whereas partial application can take 2 (or more) inputs. Similar to currying it lets us call a function, split it in multiple calls, and provides multiple arguments per-call.
Partial application is also when you curry a function, and use some, but not all of the resulting functions.

# Why is it called "currying"?
Christopher Strachey coined the term currying in 1967, although he did not invent the underlying concept, he named currying in a computer science context after Haskell Currying.  The ideal of "currying" can be traced back to 1893 in a mathematical context.

# What do partial applications look like?
## Common Lisp
```common-lisp
(defun add-me (a b c d e)
  (+ a b c d e))
​
(defun partially-apply-stuff (a b c)
  (lambda (d e) (add-me a b c d e)))
  
(funcall (partially-apply-stuff 1 2 3) 4 5)
```
## JavaScript
```javascript
function addMe(a, b, c, d, e) {
   return a + b + c + d + e
}

function partiallyApplyStuff(a, b, c) {
    return function(d, e) {
        return addMe(a, b, c, d, e)
    }
}

partiallyApplyStuff(1, 2, 3)(4, 5)
```

## Also JavaScript
```javascript
let addMe = (a, b, c, d, e) => a + b + c + d + e

let partiallyApplyStuff = (a, b, c) => (d, e) => addMe(a, b, c, d, e)

partiallyApplyStuff(1, 2, 3)(4, 5)
```

## Swift
```swift
func addMe(a: Int, b: Int, c: Int, d: Int, e: Int) -> Int {
    return a + b + c + d + e
}

func partiallyApplyStuff(a: Int, b: Int, c: Int) -> ((Int, Int) -> Int) {
    return { (d, e) in
        return addMe(a: a, b: b, c: c, d: d, e: e)
    }
}

partiallyApplyStuff(a: 1, b: 2, c: 3)(4, 5)
```

# But when would I use it?

# Inheritence vs Composition
Inheritence is when you design your types around what they are.
Composition is when you design your types around what they do.

# References
- [Currying](https://en.wikipedia.org/wiki/Currying)
- [Partial Applications](https://en.wikipedia.org/wiki/Partial_application)