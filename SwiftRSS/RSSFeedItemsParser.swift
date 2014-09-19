
import Foundation

class RSSFeedItemsParser : NSObject, NSXMLParserDelegate {
    
    var parser : NSXMLParser! = nil;
    var parseStack : ParseStack = ParseStack();

    var feedIem : RssFeedItemModel = RssFeedItemModel();
    
    var delegate : RSSFeedItemsParserDelegate?;
    
    // queue for doing RSS parsing in background thread
    let queue = NSOperationQueue()
    
    override init() {
        super.init()
    }
    
    func parseRssFeedItemsAsync(urlString : String) {
        queue.addOperationWithBlock() {
            self.parseStack = ParseStack();
            
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
        
        self.parseStack.pushElement(elementName);
        
        // we just found a new item, reset item values
        if (elementName == "item" && parseStack.parentElement(2) == "channel" ) {
            feedIem = RssFeedItemModel();
        }
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        var poppedElmt : String = parseStack.popElement();
        
        if (elementName != poppedElmt) {
            println("ERROR in parsing, unexpected end element \(elementName)!");
        }
        
         if (elementName == "item" && parseStack.parentElement() == "channel" )  {
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.invokeDelegateParseItem(self.feedIem);
            }
        }
    }
    
    func invokeDelegateParseItem(feedIem : RssFeedItemModel) {
        delegate?.parseItem?(feedIem);
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        if (parseStack.parentElement() == "title" && parseStack.parentElement(2) == "item") {
            feedIem.ftitle += string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil);
        } else if (parseStack.parentElement() == "link" && parseStack.parentElement(2) == "item") {
            feedIem.link += string.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil);
        } else if (parseStack.parentElement() == "description" && parseStack.parentElement(2) == "item")  {
            feedIem.fdescription += string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil);
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