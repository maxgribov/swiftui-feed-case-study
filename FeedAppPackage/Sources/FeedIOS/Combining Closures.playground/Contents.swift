import Cocoa

struct Parallel<A> {
    
    let run: (@escaping (A) -> Void) -> Void
}

func transform<A, B>(_ source: Parallel<A>, map: @escaping (A) -> B) -> Parallel<B> {
    
    return Parallel<B> { closure in
        
        source.run { a in
            
            closure(map(a))
        }
    }
}

var capturedClosure: ((Int) -> Void)? = nil
var loadItem = Parallel<Int> { closure in
    
    capturedClosure = closure
}

func map(item: Int) -> String {
    
    "result: \(item)"
}

let loadTransformed = transform(loadItem, map: map(item:))
loadTransformed.run { item in
    
    print(item)
}

capturedClosure?(200)


