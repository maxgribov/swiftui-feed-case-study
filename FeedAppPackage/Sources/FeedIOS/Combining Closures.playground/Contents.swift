import Cocoa

func adapt<A, B>(_ source: @escaping ((A) -> Void) -> Void, map: @escaping (A) -> B) -> ((B) -> Void) -> Void {
    
    return { b in
        
        source { a in
            
            b(map(a))
        }
    }
}


func loadItems(completion: (Int) -> Void) {
    
    completion(10)
}

func loadViewModels(completion: @escaping (String) -> Void) {
    
    completion("Hello")
}

func adapt(load: @escaping ((Int) -> Void) -> Void, map: @escaping (Int) -> String) -> ((String) -> Void) -> Void {

    return { result in

        load { item in

            let mapped = map(item)
            result(mapped)
        }
    }
}


let result: ((String) -> Void) -> Void = adapt(loadItems(completion:)) { String($0) }
