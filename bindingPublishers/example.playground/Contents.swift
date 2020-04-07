import SwiftUI

class Store: ObservableObject{
    @Published var things = [Thing](){
        didSet {
            print("set things \(things)")
        }
    }
}

class Thing: ObservableObject, CustomStringConvertible, Identifiable {
    let id = UUID()
    @Published var name: String

    init(_ name: String) {
        self.name = name
    }
    
    var description: String {
        name
    }
}

struct Parent: View {
    @ObservedObject var store: Store
    
    init(store: Store){
        self.store = store
    }
    
    var body: some View {
        Child(things: $store.things)
        .onReceive(store.$things) { things in
            print("hi \(things)")
        }
    }
}

struct Child: View {
    @Binding var things: [Thing] {
        didSet {
            print("set things \(things)")
        }
    }
    
    init(things: Binding<[Thing]>){
        self._things = things
        self.things[0].name = "four"
        self._things.wrappedValue[0].name = "four"
    }

    var body: some View {
        List {
            ForEach(self.things) { thing in
                Text(thing.description)
            }
        }
    }
}

let store = Store()
store.things = [Thing("one"), Thing("two"), Thing("three")]
store.$things.sink(receiveCompletion: { _ in print("complete") }, receiveValue: { thing in
    print("received value: \(thing)")
})

let parent = Parent(store: store)

print(store.things)
