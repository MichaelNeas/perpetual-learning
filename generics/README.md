# Fundamentally Understanding Swift Generics

Swift Generics are one of the primary reasons underlying the versatility of the Swift Standard Library.  If you have written any Swift, I would bet you've already used Generics.  The term `Generic` might seem scary or confusing at first, but I want to demonstrate how beneficial Generics can be, practical reasons to using them, and why abstract thinking promotes a more robust and enriched codebase.

In English, a definition of [generic](https://www.merriam-webster.com/dictionary/generic) provides an insight to the goal of [Generic programming](https://en.wikipedia.org/wiki/Generic_programming).
A `characteristic of or relating to a class or group of things; not specific.`
And that's exactly it!  With Generics, developers aim to avoid locking down implementation details related to specific types and produce more flexible code.

This article dives into several examples of Swift Generics that can most likely be applied to other languages.

The underlying implementation details of Generics in the compiler is beyond the scope of this blog, but is a potential discussion topic based on future interest.

## Swift uses generics?

[Types](https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html) are essential in Swift.  They give the compiler enough information to allocate adequate memory, promote specific optimizations, influence static analysis, and provide developers a way to reason about a codebase.  Ever wonder how we can declare a `String` and `Int` [array](https://developer.apple.com/documentation/swift/array) and they will both have the same basic auxiliary functions, even though both arrays contain different types?
```swift
let ints = [Int]()
let strings = [String]()
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

let birds = [Bird(name: "Al"), Bird(name: "Crim")]
let cats = [Cat(name: "Boosh"), Cat(name: "Styler")]
```

Just about any type can be used in the creation of a new array. No need to be concerned with implementational details of the array type itself!  This concept doesn't only apply to array's, in fact, the majority of the data structures throughout the language operate similarly.  If we want to keep track of the number of Birds, we can do so by declaring a [dictionary](https://developer.apple.com/documentation/swift/dictionary). 
```swift
var birdDictionary = [Bird: Int]()
```

This will bring surface an additional requirement for our Bird struct to be [Hashable](https://developer.apple.com/documentation/swift/hashable).
The compiler tells us `Generic struct 'Dictionary' requires that 'Bird' conform to 'Hashable'`

Swift allows us to easily extend Bird to be `Hashable`.  Since Bird is a `struct` and only contains a name property which is a `String` type, it conforms to `Hashable` without needing to implement any methods explicitly.  All we have to do is extend Bird to conform to Hashable and Swift will handle the rest for us.  To read more about this check out the [documentation](https://developer.apple.com/documentation/swift/hashable).
```swift
extension Bird: Hashable {}
```

The notion of _Type Conformance_ is a fundamental requirement before anyone can truly understand Generics.  One way to understand conformance is to think about driving a car.  A person can get their license by passing a test which prove they understand how to drive.  They have the freedom of using a vehicle on public roads as long as they follow the rules.  The driver's license is proof that this person should understand the standards of the road.  Any rule following or contractual agreements are essentially implying some type of conformance.  

In programming it's not very different.  Bird conform's to Hashable and now gets access to all the cool things Hashable Types can do, provided that it always implements the requirements to **be** Hashable.

## Our own data structure

Let's make a `generic type` [Queue](https://en.wikipedia.org/wiki/Queue_(abstract_data_type)), a data structure that resembles a line at a coffee shop.  As more people show up, the line grows from the back.  As coffee is produced, it's distributed to those in the front of the line first, and they leave.  In swift we have the power to make generic types out of classes, structures, and enumerations, for this example let's go with a struct.

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

A `Thing` in this case is known as a `Type Parameter`, we can think of these as placeholders.  These placeholders are common in most languages that implement Generics.  We can see that our Queue will be made up of "`Thing`'s".  There will be a `Thing` array created for storage and the `enqueue` function requires some `Thing` to be passed to it.  These `Thing`'s can be just about **anything**.

Let's add some subclasses to the `Cat` class.
```swift
class Persian: Cat {}
class Bengal: Cat {}
class Tabby: Cat {}
```

From there we'll instantiate 2 cats and 1 bird.
```swift
let persian = Persian(name: "Oti")
let bengal = Bengal(name: "Beng")
let birdy = Bird(name: "tweety")
```

In object oriented programming we have the notion of subclassing.  A nice intuitive approach to declaring functions parameters or type requirements could be to use the parent class.  But with Generics we can do even better!  We can abstract our code in a way that it doesn't matter what type gets passed in.

Take a look at this Queue.
```swift
var catQueue = Queue<Any>()
catQueue.enqueue(thing: persian)
catQueue.enqueue(thing: bengal)
catQueue.enqueue(thing: birdy)
```

Would you look at that, `Any` as a type in our generic Queue allows for `birdy` to get added.  This may not be the behavior we would want out of the catQueue, as Tweety would surely be a goner as the cats wait for their coffee to be served.  The notion of combining completely separate types is the value add.  Naturally, we will lose information by using `Any` type, but it's important to know that it's possible.

```swift
var catQueue = Queue<Cat>()
```

A simple change from `Any` to `Cat` demonstrates that the birdy is no longer allowed in this queue thanks to some fancy [static analysis](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/debugging_with_xcode/chapters/static_analyzer.html) Swift tells us that it `Cannot convert value of type 'Bird' to expected argument type 'Cat'`

We've added 1 typed parameter to the Queue but it's important to know that
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
There are no restrictions on declaring types with multiple parameters which can lead to more structure in generic types.  An example of using the `crazyQueue` could be to maintain two storage arrays, one for birds and one for cats.  That way Tweety can have a calm waiting experience completely separated from the line of cats.

In your Generic's journey I can guarantee that you will see generic type parameters with variables written as `T`, `U` & `V`.  If you're already working in a preexisting codebase or use dependencies go ahead and search for "<T>" in XCode and see what shows up!  I would encourage using more specific naming to clarify abstract intentions. (Even though `Thing` is not much better than `T`, I would argue "thing" reads better than "T".)

## Type Constraints and Conformance

Another way to apply the `Cat` restriction is through `Type Constraints`.
```swift
struct Queue<Thing: Cat> {
```
By redefining the fundamental requirements of this queue, any future developer would no longer be able to instantiate the catQueue without using `Cat` types.

This unlocks the ability to control the expected behavior/type we want in our queues.  Constraints don't stop at parent classes.  There are loads of [common protocols](https://developer.apple.com/documentation/swift/adopting_common_protocols) throughout the Swift language that various types conform to.  This enables the queue to be contractually constrained by protocol conformances.

```swift
struct Queue<Thing: CustomStringConvertible> {
```

In this example the Queue's generic constraint requires any future Queue to be made from types the implement [CustomStringConvertible](https://developer.apple.com/documentation/swift/customstringconvertible) in order to print any of the `Thing`'s descriptions.  This conformance requires a description declaration.
```swift
struct Bird: CustomStringConvertible {
    let name: String
    
    var description: String {
        "\(name)"
    }
}
```

Bird Queue's `Queue<Bird>()` can now be made since Bird's adhere to the conformance.  Additionally we can add some logging to the dequeue method.  The `description` property will show in code completion since it is guaranteed to be a property from the `CustomStringConvertible` conformance of the Queue type.

```swift
mutating func dequeue() -> Thing {
    let removed = things.removeFirst()
    print(removed.description)
    return removed
}
```

The developer can provide as many constraints as they desire, anyone who instantiates the type in the future is handed the contractual agreement by Swift's static analysis tools before compilation occurs.

A Queue can be made from **ANYTHING** that conforms to CustomStringConvertible, whether that be a Cat, Bird, Person, Place, Food, whatever.  The _only_ thing that matters is that the type adhere's to the conformance.

## Generic Functions

Generic functions can be created inside any type in Swift.  Technically our Queue already uses generic functions, but let's add a more explicit generic function with a brand new type.

First we'll switch gears to using a Cat, which requires conforming to `CustomStringConvertible` protocol.  Then expand the Queue to look for matching `Thing`'s based on Type and description.
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

In this example we don't care about a direct object comparison and only want to know if there are any cat's in the queue with a specific type and name.  This allows the use of parent classes and descriptions to see if there are any valid cat matches waiting in the queue.

If we focus on the `items` we can highlight the generic implementation.
```swift
func items<SomeOtherThing: CustomStringConvertible>(matching thing: SomeOtherThing) -> [Thing] {
    things.filter { $0 is SomeOtherThing && thing.description == $0.description }
}
```

 - `<SomeOtherThing>`: We can introduce different types completely unrelated to the generic Queue's type.  SomeOtherThing can be whatever we want, but for the sake of the example I chose to lock it down as another `CustomStringConvertible` in order to compare descriptions.

## Where Clauses

`Where`'s in Generics are more specific ways to apply constraints to our generics.
In the above example of `items` we could have written
```swift 
func items<SomeOtherThing>(matching thing: SomeOtherThing) -> [Thing] where SomeOtherThing: CustomStringConvertible {
    things.filter { $0 is SomeOtherThing && thing.description == $0.description }
}
```
and the items function would behave the same way as before.

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

Another example, To constrain functionality for 'Thing' if Thing is an `Int` we would use this `where` syntax.

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

Exactly like `containsDupes`, `sum` will only be available for Queue's made up of Swift Int's.

## When to use Generics

A fundamental use case of Generics surfaces when we write functions that may do identically the same thing, besides the types being passed in.  Not only are Generics good for code reduction but they allow us to use even more Types in the future that may have not existed during the creation of the generic.

An incredibly popular place for generics to exist in most apps include network tasks with decode/encode constraints.
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

Writing network requests like this allows us to be flexible with what types we are be expecting to come back from a network request.  This allows us to only write 1 method and make as many requests that will serialize/deserialize as needed to get data and populate a UI.

Other popular places generics are used include:
 - UserDefaults
 - Disk File Read/Write
 - Most implementations of Data Structures
 - Error Handling
 - NSAttributed Strings
 - Explicit Memory Allocations 

The list goes on and on.

## Final thoughts

Similarly to the layout of this article, I like to think about generics from a blank canvas perspective.  Adding constraints as I go, rather that removing them.  This allows me to visualize added functionality over potentially deprecating previous expectations.

That being said, we don't need to make entire codebases generic, but being comfortable and having the foresight for good times to use generics is a powerful skill to lean on.  With practice, use cases for generics will jump out at you.  The biggest thing is to dive in and try it out on your own.  I have included the playground for all the code [here](./resources), feel free to take that and have a go!  Make a Dog Hair Salon queue or practice a random abstract data type using Generics.  New errors and warnings are introduced into the compiler regularly and will be essential to assisting you on your journey.

It's nearly impossible to predict the future, we never know when a business requirement will change in the real world.  Generics can help us reduce the amount of extra work we have to do long term by providing single, testable, and expressive functionality that can easily be reused.  Writing Tests around the constraint system of generics allows for great practice and understanding of what our Generic's are truly capable of.

## Helpful Links
- [Swift Generics Docs](https://docs.swift.org/swift-book/LanguageGuide/Generics.html)
- [Generic Type Constraints](https://swiftbysundell.com/tips/inferred-generic-type-constraints/)
- [Conditional Conformance](https://swift.org/blog/conditional-conformance/)
- [Other Blog Posts by me](https://neas.dev/)