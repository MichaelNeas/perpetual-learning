// Regular Function
func puppyFunc(_ name:  String,_ size: String,_ exercise: String) -> String {
    "\(name) is a \(size) puppy that likes to \(exercise)!"
}

// Function Type with a closure expression
let puppy: ((String, String, String) -> (String)) = { (name, size, exercise) in
    "\(name) is a \(size) puppy that likes to \(exercise)!"
}
print(puppy("Otis", "Small", "Fetch"))

// curry!
let puppyCurry = { (name: String) in
    { (size: String) in
        { (exercise: String) in
            "\(name) is a \(size) puppy that likes to \(exercise)!"
        }
    }
}

let pup = puppyCurry("Remi")
print(pup("Medium")("Jump"))

print(puppyCurry("Otis")("Small")("Fetch"))

struct Puppy: CustomStringConvertible {
    let name: String
    let size: String
    let exercise: String

    var description: String {
        "\(name) is a \(size) puppy that likes to \(exercise)!"
    }
}

let puppies = [
    Puppy(name: "Otis", size: "Small", exercise: "Fetch"),
    Puppy(name: "Remi", size: "Medium", exercise: "Jump"),
    Puppy(name: "Ghost", size: "Large", exercise: "Sleep"),
    Puppy(name: "Charlie", size: "Extra Small", exercise: "Bark"),
    Puppy(name: "King", size: "Medium", exercise: "Fetch")
]

let does = { (thing: String) in { (puppy: Puppy) in puppy.exercise == thing } }

let fetchers = puppies.filter(does("Fetch"))

print(fetchers)