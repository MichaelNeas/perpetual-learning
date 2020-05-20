import Foundation
struct Bird: CustomStringConvertible {
    var name: String
    var description: String {
        "\(name)"
    }
    mutating func change(name: String) {
        self.name = name
    }
}

extension Bird: Hashable {}

let birdDictionary = [Bird: Int]()

class Cat: CustomStringConvertible {
    let name: String
    init(name: String) {
        self.name = name
    }
    var description: String {
        "\(name)"
    }
}

class Persian: Cat {}
class Bengal: Cat {}

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
    
    func items<SomeOtherThing>(matching thing: SomeOtherThing) -> [Thing] where SomeOtherThing: CustomStringConvertible {
        things.filter { $0 is SomeOtherThing && thing.description == $0.description }
    }
}

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

extension Queue where Thing == Int {
    var sum: Int {
        things.reduce(0, +)
    }
}

var catQueue = Queue<Cat>()
let persian = Persian(name: "Oti")
let bengal = Bengal(name: "Beng")
let bangal2 = Bengal(name: "Bengie")
let stray = Persian(name: "Shadow")
let cat = Cat(name: "Beng")
let bengPersian = Persian(name: "Beng")
catQueue.enqueue(thing: persian)
catQueue.enqueue(thing: bengal)
catQueue.enqueue(thing: bangal2)
catQueue.items(matching: stray) // []
catQueue.items(matching: bengal) //[Beng]
catQueue.items(matching: cat) //[Beng]
catQueue.items(matching: bengPersian) // []


var birdQueue = Queue<Bird>()
let tweety = Bird(name: "Tweety")
let red = Bird(name: "Red")
let pink = Bird(name: "Pink")
birdQueue.enqueue(thing: tweety)
birdQueue.enqueue(thing: red)
birdQueue.enqueue(thing: pink)
birdQueue.enqueue(thing: pink)
birdQueue.containsDupes

var numQueue = Queue<Int>()
numQueue.enqueue(thing: 1)
numQueue.enqueue(thing: 2)
numQueue.enqueue(thing: 3)
numQueue.sum


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
