# Partial Applications & Currying, Swift & Beyond! - December 18, 2019

# Key Functional Programming Concepts

- First class and higher order functions - Pass functions around or use them as types
- Pure Functions: given a function and an input value you will always receive the same output. That is to say there is no external state used in the function.
- Type Systems: Swift surely is strictly typed!

# Inheritence vs Composition
Inheritence is when you design your types around what they are.
Composition is when you design your types around what they do.

# What is Currying?

Currying is when a function does not take all of it's arguments up front.  You give a function a single parameters, it returns a function with a single parameter. And this can continue down a chain until you reach a function that returns the value that you want.

# What is a Partial Application?

Currying takes exactly 1 input, whereas partial application can take 2 (or more) inputs. Similar to currying it lets us call a function, split it in multiple calls, and provides multiple arguments per-call.
Partial application is also when you curry a function, and use some, but not all of the resulting functions.  It is a curried chain that is only "partially applied".

# Why is it called "currying"?
Christopher Strachey coined the term currying in 1967, although he did not invent the underlying concept, he named currying in a computer science context after Haskell Currying.  The ideal of "currying" can be traced back to 1893 in a mathematical context.

# What do partially applied and curried functions look like?

Here is how 3 different languages handle currying or partially applying 5 values.  
Now 5 layers of curried functions might be impractical, especially for summation, but I want to demonstrate the true "magic" behind multiple curried statements and partial applications.

## Swift
```swift
func addMe(_ a: Int,_ b: Int,_ c: Int,_ d: Int,_ e: Int) -> Int {
    return a + b + c + d + e
}

func partiallyApplyStuff(a: Int, b: Int, c: Int) -> ((Int, Int) -> Int) {
    return { (d, e) in
        return addMe(a, b, c, d, e)
    }
}

partiallyApplyStuff(a: 1, b: 2, c: 3)(4, 5)

let curryStuff = {(a: Int) in
    {(b: Int) in
        {(c: Int) in
            {(d: Int) in
                {(e: Int) in
                    addMe(a, b, c, d, e)
                }
            }
        }
    }
}

curryStuff(1)(2)(3)(4)(5)
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

function curryStuff(a) {
    return function(b) {
        return function(c) {
            return function(d) {
                return function(e) {
                    return addMe(a, b, c, d, e)
                }
            }
        }
    }
}

curryStuff(1)(2)(3)(4)(5)
```

## JavaScript Arrow Functions
```javascript
let addMe = (a, b, c, d, e) => a + b + c + d + e

let partiallyApplyStuff = (a, b, c) => (d, e) => addMe(a, b, c, d, e)

partiallyApplyStuff(1, 2, 3)(4, 5)

let curryStuff = a => b => c => d => e => addMe(a, b, c, d, e) 

curryStuff(1)(2)(3)(4)(5)
```

## Common Lisp
```common-lisp
(defun add-me (a b c d e)
    (+ a b c d e))
​
(defun partially-apply-stuff (a b c)
    (lambda (d e) (add-me a b c d e)))
  
(funcall (partially-apply-stuff 1 2 3) 4 5)

(defun curry-stuff (a)
    (lambda (b) 
        (lambda (c) 
            (lambda (d)
                (lambda(e)
                    (add-me a b c d e)
                )
            )
        )
    )
)

(funcall(funcall(funcall(funcall(funcall (curry-stuff 1) 2) 3) 4) 5)
```

# But when would I use it?

This is that classic question I get asked whenever I bring up currying or partial applications in general.
It may not be intuitive to think of a curried solution for someone coming from an Object Oriented background and it may even be overkill or unneccesary to even think about currying.  Regardless there are some wonderful reasons to use this technique.

### Map, reduce, filter
Just about all modern languages have basic utility functions that come with certain types.  Array's are the best example of this.  Generally array's will have method's like map to take all the values in an array and transform them in some way.  Or filter, which will take a function that filters out or in array contents based on some condition. Or even more powerful, Reduce which will take the array contents and reduce the amount of data to some smaller subset of data, a common use case could be to sum up all the int's in an array.  These functions take some function and apply it over an array.  Currying is incredibly useful for auxillary functions like these!

### Configuration
If you have an API and would like to change setup values, currying provides a wonderful way to meet encapsulation with composibility.

### Composibility
Which leads into comosibility.  The ability to swap out contents on the fly is what gives so much power to currying.  We are able to store a primed function at any step of the curry and reassign the invocation at any later point in the programs execution.

To sum this up there is a ton of value added to any project in terms of composibility and testability.  By using a functional technique like currying we can:
1. Provide [configuration encapsulation](./apiConfiguration.swift)
1. [Lazy evaluations](./urlSessionCurry.swift)
1. Create [modular and readable higher order functions](./currying.swift)

# References
- [My Presentation!](./functionalSwift.key)
- [Currying](https://en.wikipedia.org/wiki/Currying)
- [Partial Applications](https://en.wikipedia.org/wiki/Partial_application)
- [Currying Swift Evolution](https://github.com/apple/swift-evolution/blob/master/proposals/0002-remove-currying.md)