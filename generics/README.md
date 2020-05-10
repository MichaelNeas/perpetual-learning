# Swift Generics Basics - May 2020

Swift Generics allow the standard library to be as versatile as it is.  You've already used Generics without even thinking about it.  The word `generic` might seem a little scary or confusing at first, but I want to show how simple and powerful Generics are, practical reasons to use them today, and touch on why thinking abstract thinking promotes a more robust codebase.

## Swift uses generics?

Ever wonder how we can declare a `String` and an `Int` array and they both have the same functions, even though both arrays contain different types?
```swift
	let array1 = [Int]()
	let array2 = [String]()
```
Swift built these [Collection types](https://docs.swift.org/swift-book/LanguageGuide/CollectionTypes.html) completely with Generics.  That's how we can create array's out of a bunch of different Objects or References.  

```swift
struct Bird {
    let name: String
}

class Fly {
    let name: String
    init(name: String) {
        self.name = name
    }
}

let array3 = [Bird(name: "Al"), Bird(name: "Crim")]
let array4 = [Fly(name: "Phi"), Fly(name: "Nil")]
```

We can create new arrays from just about anything, without needing to be concerned with any of the implementational details of the Array itself!  Now this is definitely not just the case for Array's but how a ton of the data structures throughout the language operate.  We can see that dictionaries work the same way, but with the addition of a contract for hashing.

## Our own array

## Generic Functions



## Type Constraints and Conformance

Talk about the fly dictionary needing to adhere to certain contracts.

## When to use Generics

If you get to a place where you write functions that may do identically the same thing, besides the types being passed in, that is an easy way to throw in the use of a Generic.  Not only is it good for code reduction but allows you to use even more Types in the future than what you may be thinking of in the current moment.

## Final thoughts

We don't need to make entire codebases generic, but being comfortable and having the foresight for good times to use generics is an incredibly powerful skill.

It's incredibly hard to predict the future, and we never know when a business requirement will change in the real world.  Generics can help us reduce the amount of extra work we have to do long term, by providing single testable and expressive functionality that can easily be reused.

## Helpful Links
- [Swift Generics Docs](https://docs.swift.org/swift-book/LanguageGuide/Generics.html)
- https://swiftbysundell.com/tips/inferred-generic-type-constraints/