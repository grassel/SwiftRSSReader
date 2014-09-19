
import Foundation
import UIKit

// parses the RSS channel description: title, description, pub data and image, if available
class RssFeedChannelParser : NSObject, NSXMLParserDelegate {
    
    var parser = NSXMLParser();
    var parseStack : ParseStack = ParseStack();
    var delegate : RssFeedChannelParserDelegate?
    
    var title : String = "";
    var desc : String = "";
    var pubDate : String = "";
    var imgUrl = "";
    
    // queue for doing RSS parsing in background thread
    let queue = NSOperationQueue()
    
    override init() {
        super.init()
    }
    
    // attempt to retrieve and parse the RSS from the given Url
    // return true if retrieving and parssng was successfull
    // this is not, yet, warranty that an RSS file has been downloaded and it can be parseed!
    func parseRssFeedChannelAsync(urlString : String) {
        /* http://stackoverflow.com/questions/24589575/how-to-do-multithreading-concurrency-or-parallelism-in-ios-swift
        func addOperationWithBlock(block: (() -> Void)!)
        block role is extraneous, and last func argument, can be shortened to
        queue.addOperationWithBlock() { ... }
        */
        queue.addOperationWithBlock() {
            self.parseStack = ParseStack();
            
            var url: NSURL! = NSURL.URLWithString(urlString)
            if (url == nil) {
                self.fireParsingFailed();
                return;
            }
            
            var data:NSData! = NSData.dataWithContentsOfURL(url, options: nil, error: nil)
            if (data == nil) {
                self.fireParsingFailed();
                return;
            }
            self.parser = NSXMLParser(contentsOfURL: url)
            
            self.parser.delegate = self
            self.parser.shouldProcessNamespaces = false
            self.parser.shouldReportNamespacePrefixes = false
            self.parser.shouldResolveExternalEntities = false
            
            self.parseStack = ParseStack();     // no elements parsed
            if self.parser.parse() {
                self.fireParsingSucceeded();
            } else {
                self.fireParsingFailed();
            }
        }
    }
    
    func fireParsingFailed() {
        if (delegate != nil) {
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.fireParsingFailedUI();
            }
        }
    }
    
    // call the delegates optional method (exec in UI thread)
    // can't call the optional protocol method in above block parameter
    func fireParsingFailedUI() {
         self.delegate?.parsingFaied?();
    }
    
    func fireParsingSucceeded(){
        if (delegate != nil) {
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.fireParsingSucceededUI();
            }
        }
    }
    
    // see fireParsingFailedUI
    func fireParsingSucceededUI() {
        self.delegate?.parsingSucceeded?();
    }

    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        parseStack.pushElement(elementName);
        
        if (parseStack.parentElement() == "channel" && parseStack.parentElement(2) == "rss") {
            // new channel starts
            title = "";
            desc = "";
            pubDate = "";
            imgUrl = "";
        }
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        var poppedElmt : String = parseStack.popElement();
        
        if (elementName != poppedElmt) {
            println("ERROR in parsing, unexpected end element \(elementName)!");
        }
        
        if (elementName == "channel" && parseStack.parentElement(1) == "rss") {
            // submit new channel via delegate
            
            if (delegate != nil) {
                // submit the RSS item element values.
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                   self.parseValueUI(title: self.title, description: self.desc, pubDate: self.pubDate, imageUrl: self.imgUrl);
                }
                
                // fetch the image
                queue.addOperationWithBlock() {
                    let url = NSURL.URLWithString(self.imgUrl);
                    var err: NSError?
                    var imageData :NSData = NSData.dataWithContentsOfURL(url,options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err);
                    var image = UIImage(data:imageData); // Warning: is it allowed to create a UIImage in a background thread?
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        // set the image content in the foreground
                        self.parseValueUI(decodedImage: image);
                    }
                }
            }
        }
    }
    
    // see fireParsingFailedUI why this is a separate method
    func parseValueUI(title ftitle : String,
        description fdescription: String,
        pubDate fpubDateString : String,
        imageUrl fimageUrlString :String) {
            self.delegate?.parseValue?(title: self.title, description: self.desc, pubDate: self.pubDate, imageUrl: self.imgUrl);
    }

    // see fireParsingFailedUI why this is a separate method
    func parseValueUI(decodedImage image: UIImage) {
         self.delegate?.parseValue?(decodedImage: image);
    }

    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        // note: Depending  how the RSS file is formatted, if it includes line breaks, foundCharacters will be called more than onc for the same XML elmt value.
        // therefore we need to append the string, and wait for didEndElement to submit the result to the delegate
        if (parseStack.parentElement() == "title" && parseStack.parentElement(2) == "channel" && parseStack.parentElement(3) == "rss") {
            title += string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil);
        } else if (parseStack.parentElement() == "description" && parseStack.parentElement(2) == "channel" && parseStack.parentElement(3) == "rss") {
            desc += string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil);
        } else if (parseStack.parentElement() == "pubDate" && parseStack.parentElement(2) == "channel" && parseStack.parentElement(3) == "rss") {
            pubDate += string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil);
        } else if (parseStack.parentElement() == "url" && parseStack.parentElement(2) == "image" && parseStack.parentElement(3) == "channel" && parseStack.parentElement(4) == "rss") {
            imgUrl += string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil);
            
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser!) {
        if (delegate != nil /* && self.delegate!.parseDone != nil */) {
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.parserDidEndDocumentUI();
            }
        }
    }
    
    func parserDidEndDocumentUI() {
        self.delegate!.parseDone?()
    }
}