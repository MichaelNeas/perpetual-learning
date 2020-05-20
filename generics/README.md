# Swift Generics Basics - May 2020

Swift Generics allow the standard library to be as versatile as it is.  You've already used Generics without even thinking about it.  The word `generic` might seem a little scary or confusing at first, but I want to show how beneficial Generics can be, practical reasons to use them today, and touch on why thinking abstract thinking promotes a more robust codebase.

In english, the definition of [generic](https://www.merriam-webster.com/dictionary/generic) as an adjective gives a nice insight into the goal of generic programming.
`characteristic of or relating to a class or group of things; not specific.`
That's exactly it!  We'll dive into several examples to show that Generics in Swift, and programming in general, all aim to avoid locking down implementation details related to specified types.

The underlying implementation details of Generics is beyond the scope of this blog, but is certainly a potential topic of discussion in a future blog post.

## Swift uses generics?

In Swift, [Types](https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html) are essential.  They allow the compiler to allocate adequate memory, promote specific optimizations, influence static analysis, and provide developers a nice way to reason about a codebase.  Ever wonder how we can declare a `String` and an `Int` array and they both have the same auxiliary functions, even though both arrays contain different types?
```swift
	let array1 = [Int]()
	let array2 = [String]()
```
Swift built these [Collection types](https://docs.swift.org/swift-book/LanguageGuide/CollectionTypes.html) completely with Generics.  At a high level, this is how we can create arrays out of different Classes or Structs.

```swift
struct Bird {
    let name: String
}

class Cat {
    let name: String
    init(name: String) {
        self.name = name
    }
}

let array3 = [Bird(name: "Al"), Bird(name: "Crim")]
let array4 = [Cat(name: "Boosh"), Cat(name: "Styler")]
```

We can create new arrays from just about anything, without needing to be concerned with any of the implementational details of the Array itself! This is not just the case for Array's but how the majority of data structures throughout the language operate.  We can see that dictionaries work the same way, but with the addition of a contract for hashing.

## Our own data structure

Lets make a `generic type` [Queue](https://en.wikipedia.org/wiki/Queue_(abstract_data_type), which is a data structure that resembles a line at a coffee shop.  The more people that show up the longer the line gets, growing from the back.  As coffee is produced, it's distributed to the people in the front of the line first.  In swift we have the power to make generic types out of classes, structures, and enumerations, but for this example we're going with a struct!

```swift
struct Queue<Thing> {
    var things = [Thing]()
    mutating func enqueue(thing: Thing) {
        things.append(thing)
    }
    mutating func dequeue() -> Thing {
        things.removeFirst()
    }
}
```

A `Thing` in this case is known as a `Type Parameter`, we can think of these as placeholders.  These placeholders are common in most languages that allow for Generics.  We can see that our Queue will be made up of "`Thing`'s".  There will be a `Thing` array for storage, and the `enqueue` method requires a `Thing` to be passed in.  These `Thing`'s can be anything.

Let's add some subclasses to the `Cat` class.
```swift
class Persian: Cat {}
class Bengal: Cat {}
class Tabby: Cat {}

```

From there we'll instantiate 2 cats and a bird just for fun
```swift
let persian = Persian(name: "Oti")
let bengal = Bengal(name: "Beng")
let birdy = Bird(name: "tweety")
```

In object oriented programming we have the notion of subclassing.  A nice intuitive approach to declaring functions or types is to use the super type.  But with Generics we can do better!  We can abstract our code in a way that it doesn't matter what type gets passed in, and that shows the shiny value add of generics.

Then make a queue
```swift
var catQueue = Queue<Any>()
catQueue.enqueue(thing: persian)
catQueue.enqueue(thing: bengal)
catQueue.enqueue(thing: birdy)
```

Wow would you look at that, `Any` as a type in our generic Queue allows for `birdy` to get added.  That is not the behavior we would want out of the catQueue, as Tweety would surely be a goner as the cats wait for their coffee to be served.  But it is super neat that we can combine types! We will lose some information using this `Any` type, but it's important to know that it's possible.

```swift
var catQueue = Queue<Cat>()
```

By a simple change of `Any` to `Cat` we can see the the birdy is no longer allowed in this queue thanks to some fancy static analysis:
`Cannot convert value of type 'Bird' to expected argument type 'Cat'`

A final note

```
We're not restricted to 1 Typed Parameter in Swift
We can get as crazy as we want
```
```swift
struct Queue<Thing1, Thing2, Thing3> {
```
With 3 typed parameters we could instantiate the Queue like:
```swift
let crazyQueue = Queue<Cat, Bird, Int>()
```
There's no restrictions today on declaring types with multiple parameters and this can help us provide more structure in our generic types.  An example of using the `crazyQueue` would be if we want to maintain two storage arrays, one for birds and one for cats.  

In your journey I can guarantee 100% that you will see generic type parameters with variables written as `T`, `U` & `V` but I would encourage using more specific naming, even though `Thing` is not much better than `T`, I would argue "thing" reads better than "T".

## Type Constraints and Conformance

Another way to apply that restriction of `Cat` type we can actually use `Type Constraints` as so.
```swift
struct Queue<Thing: Cat> {
```
By redefining the fundamental requirements of this queue, any future developer would no longer be able to instantiate the catQueue without using `Cat` types.

We now have the ability to control the expected behavior/type we want in our queues.  But it certainly doesn't stop at parent classes.  There are tons of [common protocols](https://developer.apple.com/documentation/swift/adopting_common_protocols) throughout the Swift language that types conform to.  This allows us to write our queue based on contractual requirements of a protocol.

```swift
struct Queue<Thing: CustomStringConvertible> {
```

In this example we make the Queue require that any Queue being made has to be made up of Types the implement [CustomStringConvertible](https://developer.apple.com/documentation/swift/customstringconvertible) in order to print any of the thing's descriptions.  This conformance requires a description declaration like so.
```swift
struct Bird: CustomStringConvertible {
    let name: String
    
    var description: String {
        "\(name)"
    }
}
```

Now we can go ahead and instantiate a `Queue<Bird>()`, and add some logging to the dequeue method that will guarantee some effort put into the description of the type being processed.
```swift
mutating func dequeue() -> Thing {
    let removed = things.removeFirst()
    print(removed.description)
    return removed
}
```

As we can see we are offered up the `description` method from code completion, because it is guaranteed to be there from the  `CustomStringConvertible` conformance.

This is truly one of the coolest parts of Generics.  The developer has to power to be as restrictive as they desire, and anyone who instantiates a type in the future is gated by swifts powerful static analysis tools.

At this point we can make a Queue out of *ANYTHING* that conforms to CustomStringConvertible, whether that be a Cat, Bird, Person, Place, the only thing that matters is that StringConvertible conformance.

## Generic Functions

Generic functions can be a part of any type in Swift.  Our Queue already kind of uses generic functions inside the generic struct, but lets add a more explicit generic function with a brand new type.

```swift
class Cat: CustomStringConvertible {
    let name: String
    init(name: String) {
        self.name = name
    }
    var description: String {
        "\(name)"
    }
}

struct Queue<Thing: CustomStringConvertible> {
    var things = [Thing]()
    mutating func enqueue(thing: Thing) {
        things.append(thing)
    }
    mutating func dequeue() -> Thing {
        let removed = things.removeFirst()
        print(removed.description)
        return removed
    }
    
    func items<SomeOtherThing: CustomStringConvertible>(matching thing: SomeOtherThing) -> [Thing] {
        things.filter { $0 is SomeOtherThing && thing.description == $0.description }
    }
}

var catQueue = Queue<Cat>()
let pumpkin = Tabby(name: "Pumpkin")
let bengal = Bengal(name: "Beng")
let bengie = Bengal(name: "Bengie")
let stray = Tabby(name: "Sparka")
let cat = Cat(name: "Beng")
let persianBeng = Persian(name: "Beng")
catQueue.enqueue(thing: pumpkin)
catQueue.enqueue(thing: bengal)
catQueue.enqueue(thing: bengie)
catQueue.items(matching: stray) // []
catQueue.items(matching: bengal) //[Beng]
catQueue.items(matching: cat) //[Beng]
catQueue.items(matching: persianBeng) // []
```
For this example we don't care about direct object references and just want to know if there are any cat's in the queue with a specific type and name.  This allows us to use parent classes and it's own reference to tell if there are any valid matches in the queue.

If we focus on the `items` we can see a couple neat things with generics.
```swift
    func items<SomeOtherThing: CustomStringConvertible>(matching thing: SomeOtherThing) -> [Thing] {
        things.filter { $0 is SomeOtherThing && thing.description == $0.description }
    }
```

`<SomeOtherThing>` - We can introduce different types completely unrelated to a previously introduced type.  SomeOtherThing can literally be whatever we want, but for the sake of the example I have locked it down to be another `CustomStringConvertible`

## Where Clauses

`Where`'s in Generics are an even more specific way to apply constraints to our generics.
In the above example of `items` we could have written
```swift 
    func items<SomeOtherThing>(matching thing: SomeOtherThing) -> [Thing] where SomeOtherThing: CustomStringConvertible {
        things.filter { $0 is SomeOtherThing && thing.description == $0.description }
    }
```
and it would have performed the same way.

`Where` really shines in extensions and protocols.

```swift
extension Queue where Thing: Hashable {
    func containsDupes() -> Bool {
        var set = Set<Thing>()
        for thing in things {
            if set.contains(thing) {
                return true
            } else {
                set.insert(thing)
            }
        }
        return false
    }
}

extension Bird: Hashable {}
var birdQueue = Queue<Bird>()
let tweety = Bird(name: "Tweety")
let red = Bird(name: "Red")
let pink = Bird(name: "Pink")
birdQueue.enqueue(thing: tweety)
birdQueue.enqueue(thing: red)
birdQueue.enqueue(thing: pink)
birdQueue.enqueue(thing: pink)
birdQueue.containsDupes
```


If we wanted to Type 'Thing' constrained to non-protocol, non-class type 'Int'

```swift
extension Queue where Thing == Int {
    var sum: Int {
        things.reduce(0, +)
    }
}

var numQueue = Queue<Int>()
numQueue.enqueue(thing: 1)
numQueue.enqueue(thing: 2)
numQueue.enqueue(thing: 3)
numQueue.sum
```


## When to use Generics

If you get to a place where you write functions that may do identically the same thing, besides the types being passed in, that is an easy way to throw in the use of a Generic.  Not only is it good for code reduction but allows you to use even more Types in the future than what you may be thinking of in the current moment.

A super popular place I've seen generics include network tasks with decode/encode constraints.
```swift
func get<T: Decodable>(from url: String, completion: @escaping (Result<T, Error>) -> Void) {
    let request = URLRequest(url: URL(string: url)!)
    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
        guard let data = data else { return }
        do {
            let object = try JSONDecoder().decode(T.self, from: data)
            completion(Result.success(object))
        } catch let error {
            completion(Result.failure(error))
        }
    })
    task.resume()
}
```

Other popular places I've seen or used generics is: 
 - UserDefaults
 - Disk File Read/Write
 - Most implementations of Data Structures
 - Error Handling
 - NSAttributed Strings
 - Explicit Memory Allocations 

The list goes on and on.

A popular way to start out using generics is to write all your code using specific types and when you see overlap, in functionality think about deduplication with generics.

## Final thoughts

We don't need to make entire codebases generic, but being comfortable and having the foresight for good times to use generics is a powerful skill.  With practice, use cases for generics will jump out at you.  As with most things, the biggest thing is to dive in and try things on your own.  Make a Dog Hair Salon queue or practice a random abstract data type using Generics.  New errors and warnings are introduced into the compiler regularly and can help you on your journey.

It's nearly impossible to predict the future, and we never know when a business requirement will change in the real world.  Generics can help us reduce the amount of extra work we have to do long term by providing single testable and expressive functionality that can easily be reused.  Writing Tests around the constraint system of generics allows for great practice and understanding of what our Generic Types are truly capable of.

## Helpful Links
- [Swift Generics Docs](https://docs.swift.org/swift-book/LanguageGuide/Generics.html)
- [Generic Type Constraints](https://swiftbysundell.com/tips/inferred-generic-type-constraints/)