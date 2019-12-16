import Foundation

internal class AnAPIObject {
    let apiKey: String
    let env: String
    let base: URL
    init(_ key: String, _ environment: String, _ url: URL) {
        self.apiKey = key
        self.env = environment
        self.base = url
    }
    func doStuff() {}
    func doMoreStuff() {}
}

private func superAwesomeEncapsulatedAPI(key: String, environment: String) -> ((URL) -> (AnAPIObject)) {
    return { (endpoint: URL) in
        AnAPIObject(key, environment, endpoint)
    }
}

struct Configuration {
    var apiKey: String
    var environment: String
}

func reallyAwesomeAPI(conf: Configuration) -> ((URL) -> (AnAPIObject)) {
    return superAwesomeEncapsulatedAPI(key: conf.apiKey, environment: conf.environment)
}

let example = Configuration(apiKey: "abc123", environment: "lala")
let configuredAPI = reallyAwesomeAPI(conf: example)
let usableAPIObject = configuredAPI(URL(string: "https://gotruemotion.com/api")!)
usableAPIObject.doStuff()
usableAPIObject.doMoreStuff()
