# Currying - November 24, 2019

## Common Lisp
```common-lisp
(defun curry-me (a b c d e)
  (+ a b c d e))
​
(defun curry-stuff (a b c)
  (lambda (d e) (curry-me a b c d e)))
  
(funcall (curry-stuff 1 2 3) 4 5)
```
## JavaScript
```javascript
function curryMe(a, b, c, d, e) {
   return a + b + c + d + e
}

function curryStuff(a, b, c) {
    return function(d, e) {
        return curryMe(a, b, c, d, e)
    }
}

curryStuff(1, 2, 3)(4, 5)
```

## Also JavaScript
```javascript
let curryMe = (a, b, c, d, e) => a + b + c + d + e

let curryStuff = (a, b, c) => (d, e) => curryMe(a, b, c, d, e)

curryStuff(1, 2, 3)(4, 5)
```

## Swift
```swift
func curryMe(a: Int, b: Int, c: Int, d: Int, e: Int) -> Int {
    return a + b + c + d + e
}

func curryStuff(a: Int, b: Int, c: Int) -> ((Int, Int) -> Int) {
    return { (d, e) in
        return curryMe(a: a, b: b, c: c, d: d, e: e)
    }
}

curryStuff(a: 1, b: 2, c: 3)(4, 5)
```