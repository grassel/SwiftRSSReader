
import Foundation

// provides a simplistic Stack implementation useful for realising the context while XML parsing.

class ParserStack : NSObject {
    
    var parsedElements : NSMutableArray = NSMutableArray();
    
    override init() {
        super.init();
        parsedElements = [];
    }
    
    
    func parentElement() -> String {
        return parentElement(1);
    }
    
    func parentElement(descentant : Int) -> String {
        return ((parsedElements.count >= descentant) ? parsedElements[parsedElements.count-descentant] as String : "");
    }
    
    func pushElement(newElmt : String) {
        parsedElements.addObject(newElmt);
    }
    
    func popElement() -> String {
        var lastElmt = parsedElements.count > 0 ? parsedElements.lastObject as String : "";
        parsedElements.removeLastObject();
        return lastElmt as String;
    }
}

