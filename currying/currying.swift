//// Regular Function
func puppy(_ name:  String,_ breed: String,_ activity: String) -> String {
    "\(name) is a \(breed) that likes to \(activity)!"
}

// Function Type with a closure expression
let puppy: ((String, String, String) -> (String)) = { (name, breed, activity) in
    "\(name) is a \(breed) that likes to \(activity)!"
}

//let puppy = { (name: String, breed: String, activity: String) in
//    "\(name) is a \(breed) that likes to \(activity)!"
//}

print(puppy("Otis", "BernieDoodle", "Fetch"))

// curry!
let puppyCurry = { (name: String) in
    { (breed: String) in
        { (activity: String) in
            "\(name) is a \(breed) that likes to \(activity)!"
        }
    }
}

func puppy(named: String) -> ((String) -> ((String) -> (String))) {
    func puppyBreed(_ breed: String) -> ((String) -> (String)) {
        func puppyActivity(_ activity: String) -> String {
            "\(named) is a \(breed) that likes to \(activity)!"
        }
        return puppyActivity
    }
    return puppyBreed
}

//let otisPuppy = puppy(named: "Otis")
//let otisDoodle = otisPuppy("BernieDoodle")
//let otisDoodleTheFetchingPuppy = otisDoodle("Fetch")
//print(otisDoodleTheFetchingPuppy)

let otisPuppy = puppyCurry("Otis")
let otisBeneseMtDogPuppy = otisPuppy("Bernese Mountain Dog")
let otisPoodlePuppy = otisPuppy("Poodle")
let otisMix = otisPuppy("BernieDoodle")

enum OtisActivities: Int, CustomStringConvertible {
    case sleep
    case fetch
    case 😭
    case 💩
    case bark
    case dig
    case eat
    case bite
    case run
    case jump
    
    var description: String {
        switch self {
        case .sleep: return "Sleep"
        case .fetch: return "Fetch"
        case .😭: return "😭"
        case .💩: return "💩"
        case .bark: return "BARK"
        case .dig: return "Dig"
        case .eat: return "Eat"
        case .bite: return "Bite"
        case .run: return "Run"
        case .jump: return "Jump"
        }
    }
}

print(otisMix(OtisActivities(rawValue: Int.random(in: 0 ..< 10))?.description ?? "Fetch"))

struct Puppy: CustomStringConvertible {
    let name: String
    let breed: String
    let activity: String

    var description: String {
        "\(name) is a \(breed) that likes to \(activity)!"
    }
}

let puppies = [
    Puppy(name: "Otis", breed: "BernieDoodle", activity: "Fetch"),
    Puppy(name: "Remi", breed: "Aussie", activity: "Jump"),
    Puppy(name: "Ghost", breed: "Doverman", activity: "Sleep"),
    Puppy(name: "Charlie", breed: "Rotty", activity: "Bark"),
    Puppy(name: "King", breed: "Golden", activity: "Fetch")
]

let does = { (thing: String) in { (puppy: Puppy) in puppy.activity == thing } }

let fetchers = puppies.filter(does("Fetch"))

print(fetchers)
