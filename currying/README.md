# Partial Applications & Currying, Swift & Beyond! - December 18, 2019

## Key Functional Programming Concepts

- First class and higher order functions - Pass functions around or use them as types
- Pure Functions: given a function and an input value you will always receive the same output. That is to say there is no external state used in the function.
- Type Systems: Swift surely is strictly typed! In strongly typed languages like swift, we know exactly what types we can expect to be returned from any function.

## What is Currying?

**Currying** is when a function does not take all of it's arguments up front.  A function has a single parameter and it returns a function with a single parameter. This pattern can continue down a chain until a function is reached that returns some desired value.  It is important to remember that all the previous properties are enclosed from before to be freely used as desired.

## What is a Partial Application?

1. Currying takes exactly 1 input, whereas a partial application can take 2 (or more) inputs. Similar to currying, the function being called can be separated in to successive calls, with the option of providing multiple arguments per invocation.
2. A partial application is also when a function is curried and some, but not all, of the resulting functions are used.  It is a curried chain that is only "partially applied", waiting for some future input.

## Why is it called "currying"?

Christopher Strachey coined the term currying in 1967, although he did not invent the underlying concept, he named currying in a Computer Science context after Haskell Curry.  The ideal of "currying" can be traced back to 1893 in a mathematical context.

## What do partially applied and curried functions look like?

Here is how 3 different languages handle currying or partially applying 5 values.  
Now 5 layers of curried functions might be impractical, especially for summation, but the goal is to demonstrate the true "magic" behind curried statements and partial applications.

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

# But when would I even use it?

This is that classic question I get asked whenever I bring up currying or partial applications.  Someone coming from a strictly Object Oriented background, this technique could certainly be seen as impractical, potientially unintuitive, and overkill.  Aside from currying originating in mathematics and surviving over 100 years of inferential arguments, I would argue that there are wonderful reasons to emplore this idealogy in every day use cases.

### Map, reduce, filter
Just about all modern languages have basic utility functions that come with given types.  Arrays are one of the best examples of this.  Generally speaking, Arrays will have methods like `map` to take all the values in an array and transform them in some way.  `Filter`, which takes a function that filters _out or in_ array contents based on a given conditional. `Reduce` which iterates through the array contents and applies a transformation to create a smaller subset of data.  These functions all take a function as a parameter and apply the given function over an array.  Currying is incredibly useful for auxillary functions like these!

```Swift
let puppies = [
    Puppy(name: "Otis", breed: "BernieDoodle", activity: "Fetch"),
    Puppy(name: "Remi", breed: "Aussie", activity: "Jump"),
    Puppy(name: "Ghost", breed: "Doverman", activity: "Sleep"),
    Puppy(name: "Charlie", breed: "Rotty", activity: "Bark"),
    Puppy(name: "King", breed: "Golden", activity: "Fetch")
]

let does = { (thing: String) in { (puppy: Puppy) in puppy.activity == thing } }

let fetchers = puppies.filter(does("Fetch"))
```

### Configuration
If you have an API that requires some form of setup.  Whether that be the development environment, api keys, or even access levels, currying provides a nice way to couple encapsulation with composibility.  This [configuration encapsulation](./apiConfiguration.swift) allows developers to have the flexibility to easily test api functionality without needing to add in boiler plate or separate configuration code.

### Composibility
The ability to swap out contents on the fly is what gives so much power to currying.  We are able to store a primed function at any step of the curry and reassign the invocation at any later point in the programs execution.  Taking this one step further, we can define our types based on *what they do* rather than *what they are*.  No longer do we have to predict the future with large inheritence trees where subtypes inherit functions they may never execute in their lifetime.

The value added to any project in terms of composibility and testability is essential. By using a functional technique like currying we can:
1. Provide better [configuration](./apiConfiguration.swift) objects
1. [Lazy evaluations](./urlSessionCurry.swift)
1. Create [modular and readable higher order functions](./currying.swift)

And SO much more!!

Please take a look at my presentation slides below to walk through more examples of currying and see "real world" reasons why you might want to consider adding currying to your toolbelt.

## References
- [My Presentation!](./functionalSwift.key)
- [Currying](https://en.wikipedia.org/wiki/Currying)
- [Partial Applications](https://en.wikipedia.org/wiki/Partial_application)
- [Currying Swift Evolution](https://github.com/apple/swift-evolution/blob/master/proposals/0002-remove-currying.md)