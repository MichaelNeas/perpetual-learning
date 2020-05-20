# Swift Generics Basics - May 2020

Swift Generics are one of the major reasons behind Swift standard libraries versatility.  If you've written any Swift, I would bet that you've already used Generics without even knowing.  The term `Generic` might seem a little scary or confusing at first, but I want to demonstrate how beneficial Generics can be, practical reasons to use them today, and touch on why abstract thinking promotes a more robust and enriched codebase.

In English, a definition of [generic](https://www.merriam-webster.com/dictionary/generic) proves an insight around the goal of [Generic programming](https://en.wikipedia.org/wiki/Generic_programming).
`characteristic of or relating to a class or group of things; not specific.`
That's exactly the magic of it all!  Aiming to avoid locking down implementation details related to specified types and produce more flexible code is what it's all about.

This article dives into several examples of Swift Generics that can most likely be applied to other languages.

The underlying implementation details of Generics in the compiler is beyond the scope of this blog, but is a potential discussion topic based on future interest.

## Swift uses generics?

[Types](https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html) are essential in the Swift.  They allow the compiler to allocate adequate memory, promote specific optimizations, influence static analysis, and provide developers a way to reason about a codebase.  Ever wonder how we can declare a `String` and an `Int` [array](https://developer.apple.com/documentation/swift/array) and they both have the same auxiliary functions, even though both arrays contain different types?
```swift
	let array1 = [Int]()
	let array2 = [String]()
```
Swift builds [Collection types](https://docs.swift.org/swift-book/LanguageGuide/CollectionTypes.html) completely with Generics.  This backbone enables the creation of arrays from different [value or reference types](https://www.swiftbysundell.com/basics/value-and-reference-types/).

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

Just about any type can be used in the creation of a new array without any concern of the implementational details of the array type itself! Not only Array's but the majority of data structures throughout the language operate similarly.  By declaring a [dictionary](https://developer.apple.com/documentation/swift/dictionary) of Bird counts we can see there is an additional contract for [Hashable](https://developer.apple.com/documentation/swift/hashable).
```swift
var birdDictionary = [Bird: Int]()
```

The compiler tells us `Generic struct 'Dictionary' requires that 'Bird' conform to 'Hashable'`

So we can go ahead and extend Bird to be `Hashable`.  Because Bird is a `struct` and `String` conforms to `Hashable` out of the box, all we have to do is extend Bird to conform to Hashable and Swift will handle the rest for us.  To read more about this check out the [documentation](https://developer.apple.com/documentation/swift/hashable).
```swift
extension Bird: Hashable {}
```

This notion of _Type Conformance_ is a fundamental requirement before someone can truly understand Generics.  One way to understand conformance is to think about driving a car.  A person can get their license by passing a test to prove they understand how to drive.  Then while they're out on the road they have the freedom of using a vehicle as long as they follow the rules of the road.  The driver's license is proof that this person understands the conformance of the road.  Any rule following or contractual agreement is essentially enforcing some type of conformance.  

In programming it's not very different.  Bird conform's to Hashable and now gets access to all the cool things Hashable Types can do, pending it always provides a way to *be* Hashable.

## Our own data structure

Let's make a `generic type` [Queue](https://en.wikipedia.org/wiki/Queue_(abstract_data_type), a data structure that resembles a line at a coffee shop.  As more people show up, the line grows from the back.  As coffee is produced, it's distributed to those in the front of the line first.  In swift we have the power to make generic types out of classes, structures, and enumerations, for this example let's go with a struct!

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

A `Thing` in this case is known as a `Type Parameter`, we can think of these as placeholders.  These placeholders are common in most languages that implement Generics.  We can see that our Queue will be made up of "`Thing`'s".  There will be a `Thing` array created for storage and the `enqueue` method requires a `Thing` to be passed in.  These `Thing`'s can be just about **anything**!

Let's add some subclasses to the `Cat` class.
```swift
class Persian: Cat {}
class Bengal: Cat {}
class Tabby: Cat {}
```

From there we'll instantiate 2 cats and a bird
```swift
let persian = Persian(name: "Oti")
let bengal = Bengal(name: "Beng")
let birdy = Bird(name: "tweety")
```

In object oriented programming we have the notion of subclassing.  A nice intuitive approach to declaring functions or types could be to use the parent class.  But with Generics we can do even better!  We can abstract our code in a way that it doesn't matter what type gets passed in.

Then make a queue
```swift
var catQueue = Queue<Any>()
catQueue.enqueue(thing: persian)
catQueue.enqueue(thing: bengal)
catQueue.enqueue(thing: birdy)
```

Wow would you look at that, `Any` as a type in our generic Queue allows for `birdy` to get added.  That is not the behavior we would want out of the catQueue, as Tweety would surely be a goner as the cats wait for their coffee to be served.  But it's neat that we can combine types! Naturally, we will lose information by using `Any` type, but it's important to know that it's possible.

```swift
var catQueue = Queue<Cat>()
```

A simple change from `Any` to `Cat` demonstrates that the birdy is no longer allowed in this queue thanks to some fancy [static analysis](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/debugging_with_xcode/chapters/static_analyzer.html):
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
There are no restrictions on declaring types with multiple parameters which can lead to more structure in generic types.  An example of using the `crazyQueue` could be to maintain two storage arrays, one for birds and one for cats.

In your Generic's journey I can guarantee 100% that you will see generic type parameters with variables written as `T`, `U` & `V`.  If you're working in a prexisting codebase or use dependencies go ahead and search for "<T>" in XCode and see what shows up!  I would encourage using more specific naming to clarify abstract intentions. (Even though `Thing` is not much better than `T`, I would argue "thing" reads better than "T".)

## Type Constraints and Conformance

Another way to apply that restriction of `Cat` we can actually use `Type Constraints` as so.
```swift
struct Queue<Thing: Cat> {
```
By redefining the fundamental requirements of this queue, any future developer would no longer be able to instantiate the catQueue without using `Cat` types.

This unlocks the ability to control the expected behavior/type we want in our queues.  But it certainly doesn't stop at parent classes.  There are loads of [common protocols](https://developer.apple.com/documentation/swift/adopting_common_protocols) throughout the Swift language that various types conform to.  This enables the queue to be contractually based on protocol conformances.

```swift
struct Queue<Thing: CustomStringConvertible> {
```

In this example the Queue Generic constraint requires any future Queue to be made from Types the implement [CustomStringConvertible](https://developer.apple.com/documentation/swift/customstringconvertible) in order to print any of the `Thing`'s descriptions.  This conformance requires a description declaration like so.
```swift
struct Bird: CustomStringConvertible {
    let name: String
    
    var description: String {
        "\(name)"
    }
}
```

Now we can go ahead and instantiate a `Queue<Bird>()`, and add some logging to the dequeue method.  The `description` property will show in code completion since it is guaranteed to be a property from the `CustomStringConvertible` conformance.

```swift
mutating func dequeue() -> Thing {
    let removed = things.removeFirst()
    print(removed.description)
    return removed
}
```

This is truly one of the coolest parts of Generics.  The developer has the power to provide as many constraints as they desire, anyone who instantiates that type in the future is handed the contractual agreement by Swift's static analysis tools before compilation!

A Queue can be made from **ANYTHING** that conforms to CustomStringConvertible, whether that be a Cat, Bird, Person, Place, Food, whatever.  The _only_ thing that matters is that the type adhere's to it's conformance.

## Generic Functions

Generic functions can be a part of any type in Swift.  Technically our Queue already uses generic functions inside the generic struct, but lets add a more explicit generic function with a brand new type.

First we'll switch gears to using a Cat, which requires conforming to `CustomStringConvertible`.  Then expand the Queue to look for matching things's based on Type and description.
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
In this example we don't care about a direct object comparison and only want to know if there are any cat's in the queue with a specific type and name.  This allows the use parent classes and names to tell if there are any valid matches in the queue.

If we focus on the `items` we can see highlight the generic implementation.
```swift
    func items<SomeOtherThing: CustomStringConvertible>(matching thing: SomeOtherThing) -> [Thing] {
        things.filter { $0 is SomeOtherThing && thing.description == $0.description }
    }
```

 - `<SomeOtherThing>`: We can introduce different types completely unrelated to a previously introduced type.  SomeOtherThing can literally be whatever we want, but for the sake of the example I have locked it down to be another `CustomStringConvertible` in order to compare descriptions.

## Where Clauses

`Where`'s in Generics are more specific ways to apply constraints to our generics.
In the above example of `items` we could have written
```swift 
    func items<SomeOtherThing>(matching thing: SomeOtherThing) -> [Thing] where SomeOtherThing: CustomStringConvertible {
        things.filter { $0 is SomeOtherThing && thing.description == $0.description }
    }
```
and the items method would behave the same way.

`Where` really shines in extensions and protocols.

```swift
extension Queue where Thing: Hashable {
    var containsDupes: Bool {
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
With this extension, code completion will **only** show the containsDupes property if `Thing` conforms to `Hashable`.  Since that conformance was created earlier, let's make a Bird Queue and use the new property.  If there was a Queue of Cat's this functionality will not accessible, hiding away irrelevant properties.

Another example, if we wanted to Type 'Thing' constrained to the type `Int` we would use this `where` syntax.

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

Exactly like `containsDupes`, the sum will only be available for Queue's made up of Swift Int's.


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