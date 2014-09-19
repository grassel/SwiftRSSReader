
import Foundation
import UIKit

// parses the RSS channel description: title, description, pub data and image, if available
class RssFeedChannelParser : NSObject, NSXMLParserDelegate {
    
    var parser = NSXMLParser()
    var parseStack : ParseStack = ParseStack();
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
            self.parseStack = ParseStack();
            
            var url: NSURL = NSURL.URLWithString(urlString)
            self.parser = NSXMLParser(contentsOfURL: url)
            self.parser.delegate = self
            self.parser.shouldProcessNamespaces = false
            self.parser.shouldReportNamespacePrefixes = false
            self.parser.shouldResolveExternalEntities = false
            
            self.parseStack = ParseStack();     // no elements parsed
            self.parser.parse()
        }
    }
    
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        parseStack.pushElement(elementName);
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        var poppedElmt : String = parseStack.popElement();
        
        if (elementName != poppedElmt) {
            println("ERROR in parsing, unexpected end element \(elementName)!");
        }
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        if (parseStack.parentElement() == "title" && parseStack.parentElement(2) == "channel" && parseStack.parentElement(3) == "rss") {
            if (delegate != nil) {
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                   self.delegate!.parseValue(title: string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil))
                }
            }
        } else if (parseStack.parentElement() == "description" && parseStack.parentElement(2) == "channel" && parseStack.parentElement(3) == "rss") {
            if (delegate != nil) {
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    self.delegate!.parseValue(description: string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil));
                }
            }
        } else if (parseStack.parentElement() == "pubDate" && parseStack.parentElement(2) == "channel" && parseStack.parentElement(3) == "rss") {
            if (delegate != nil) {
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    self.delegate!.parseValue(pubDate: string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil));
                }
            }
        } else if (parseStack.parentElement() == "url" && parseStack.parentElement(2) == "image" && parseStack.parentElement(3) == "channel" && parseStack.parentElement(4) == "rss") {
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