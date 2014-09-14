
import Foundation
import UIKit

// parses the RSS channel description: title, description, pub data and image, if available
class RssFeedChannelParser : NSObject, NSXMLParserDelegate {
    
    var parser = NSXMLParser()
    var parserStack : ParserStack = ParserStack();
    var delegate : RssFeedChannelParserDelegate?
    
    // queue for doing RSS parsing in background thread
    let queue = NSOperationQueue()
    
    override init() {
        super.init()
    }
    
    func parseRssFeedChannelAsync(urlString : String) {
        /* http://stackoverflow.com/questions/24589575/how-to-do-multithreading-concurrency-or-parallelism-in-ios-swift
        func addOperationWithBlock(block: (() -> Void)!)
        block role is extraneous, and last func argument, can be shortened to
        queue.addOperationWithBlock() { ... }
        */
        queue.addOperationWithBlock() {
            self.parserStack = ParserStack();
            
            var url: NSURL = NSURL.URLWithString(urlString)
            self.parser = NSXMLParser(contentsOfURL: url)
            self.parser.delegate = self
            self.parser.shouldProcessNamespaces = false
            self.parser.shouldReportNamespacePrefixes = false
            self.parser.shouldResolveExternalEntities = false
            
            self.parserStack = ParserStack();     // no elements parsed
            self.parser.parse()
        }
    }
    
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        parserStack.pushElement(elementName);
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        var poppedElmt : String = parserStack.popElement();
        
        if (elementName != poppedElmt) {
            println("ERROR in parsing, unexpected end element \(elementName)!");
        }
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        if (parserStack.parentElement() == "title" && parserStack.parentElement(2) == "channel" && parserStack.parentElement(3) == "rss") {
            if (delegate != nil) {
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                   self.delegate!.parseValue(title: string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil))
                }
            }
        } else if (parserStack.parentElement() == "description" && parserStack.parentElement(2) == "channel" && parserStack.parentElement(3) == "rss") {
            if (delegate != nil) {
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    self.delegate!.parseValue(description: string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil));
                }
            }
        } else if (parserStack.parentElement() == "pubDate" && parserStack.parentElement(2) == "channel" && parserStack.parentElement(3) == "rss") {
            if (delegate != nil) {
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    self.delegate!.parseValue(pubDate: string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil));
                }
            }
        } else if (parserStack.parentElement() == "url" && parserStack.parentElement(2) == "image" && parserStack.parentElement(3) == "channel" && parserStack.parentElement(4) == "rss") {
            if (delegate != nil) {
                var urlString = string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil);
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    self.delegate!.parseValue(imageUrl:urlString)
                }
                queue.addOperationWithBlock() {
                    let url = NSURL.URLWithString(urlString);
                    var err: NSError?
                    var imageData :NSData = NSData.dataWithContentsOfURL(url,options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err);
                    var image = UIImage(data:imageData); // Warning: is it allowed to create a UIImage in a background thread?
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        // set the image content in the foreground
                        self.delegate!.parseValue(decodedImage: image);
                    }
                }
            }
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser!) {
          if (delegate != nil) {
              NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.delegate!.parseDone()
            }
        }
    }
}