
import Foundation

class RSSFeedItemsParser : NSObject, NSXMLParserDelegate {
    
    var parser : NSXMLParser! = nil;
    var parserStack : ParserStack = ParserStack();

    var ftitle = NSMutableString()
    var link = NSMutableString()
    var fdescription = NSMutableString()
    
    var delegate : RSSFeedItemsParserDelegate?;
    
    // queue for doing RSS parsing in background thread
    let queue = NSOperationQueue()
    
    override init() {
        super.init()
    }
    
    func parseRssFeedItemsAsync(urlString : String) {
        queue.addOperationWithBlock() {
            self.parserStack = ParserStack();
            
            var url: NSURL = NSURL.URLWithString(urlString)
            self.parser = NSXMLParser(contentsOfURL: url)

            if (self.parser == nil) {
                println("parseRssFeedItemsAsync FAILED to create NSXMLParser object. Giving up!");
                return;
            }
            
            self.parser.delegate = self
            self.parser.shouldProcessNamespaces = false
            self.parser.shouldReportNamespacePrefixes = false
            self.parser.shouldResolveExternalEntities = false
            self.parser.parse()
        }
    }

    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        
        self.parserStack.pushElement(elementName);
        
        // we just found a new item, reset item values
        if (elementName == "item") {
            ftitle = NSMutableString.alloc();
            ftitle = ""
            link = NSMutableString.alloc();
            link = ""
            fdescription = NSMutableString.alloc()
            fdescription = ""
        }
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        var poppedElmt : String = parserStack.popElement();
        
        if (elementName != poppedElmt) {
            println("ERROR in parsing, unexpected end element \(elementName)!");
        }
        
        if (elementName == "item") {
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.invokeDelegateParseItem(self.ftitle, link: self.link, fdescription: self.fdescription);
            }
        }
    }
    
    func invokeDelegateParseItem(ftitle : NSMutableString, link : NSMutableString, fdescription : NSMutableString) {
        delegate?.parseItem?(ftitle, link: link, fdescription: fdescription);
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        if (parserStack.parentElement() == "title" && parserStack.parentElement(2) == "item") {
            let s = string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil);
            ftitle.appendString(s)
        } else if (parserStack.parentElement() == "link" && parserStack.parentElement(2) == "item") {
            let s = string.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil);
            link.appendString(s)
        } else if (parserStack.parentElement() == "description" && parserStack.parentElement(2) == "item")  {
            let s = string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil);
            fdescription.appendString(s)
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser!) {
         NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.invokeDelegateParseDone();
        }
    }
    
    // FIXME: this is a bit of a hack: 
    // can't have this directly inside a blck
    func invokeDelegateParseDone() {
        delegate?.parseDone?();
    }
    

}