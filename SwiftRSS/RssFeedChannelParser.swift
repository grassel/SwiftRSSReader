//
//  RssFeedChannelParser.swift
//  SwiftRSS
//
//  Created by Guido Grassel on 13/09/14.
//  Copyright (c) 2014 albert mckeever. All rights reserved.
//

import Foundation

class RssFeedChannelParser : NSObject, NSXMLParserDelegate {

    var parser = NSXMLParser()
    
    // values of the elements we are looking for
    var ftitle : String = ""             // channel/title element
    var fpubDateString : String = ""     // channel/pubDate element
    var fdescription : String = ""       // channel/description element
    var fimageUrlString : String = ""    // channel/image/url element

    var parsedElements : NSMutableArray = NSMutableArray();
    var delegate : RssFeedChannelParserDelegate! = nil;
    
    override init() {
        super.init()
    }
    
    func parseRssFeedChannel(urlString : String) {
        var url: NSURL = NSURL.URLWithString(urlString)
        parser = NSXMLParser(contentsOfURL: url)
        parser.delegate = self
        parser.shouldProcessNamespaces = false
        parser.shouldReportNamespacePrefixes = false
        parser.shouldResolveExternalEntities = false
        
        parsedElements = [];     // no elements parsed
        ftitle  = ""             // channel/title element
        fpubDateString = ""      // channel/pubDate element
        fdescription  = ""       // channel/description element
        fimageUrlString = ""     // channel/image/url element
        
        parser.parse()
    }
    
    func parentElement() -> String {
        return ((parsedElements.count > 0) ? parsedElements.lastObject as String : "");
    }
    
    func grandParentElement() -> String {
        return ((parsedElements.count > 1) ? parsedElements[parsedElements.count-2] as String : "");
    }

    func grangrandParentElement() -> String {
        return ((parsedElements.count > 2) ? parsedElements[parsedElements.count-3] as String : "");
    }
    
    func isTitleTextContent() -> Bool {
        return (parentElement() == "title" && grandParentElement() == "channel" && grangrandParentElement() == "rss");
    }
    
    func pushElement(newElmt : String) {
        parsedElements.addObject(newElmt);
    }
    
    func popElement() -> String {
        var lastElmt = parsedElements.count > 0 ? parsedElements.lastObject as String : "";
        parsedElements.removeLastObject();
        return lastElmt as String;
    }
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        pushElement(elementName);
    }

    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        var poppedElmt : String = popElement();
        
        if (elementName != poppedElmt) {
            println("ERROR in parsing, unexpected end element \(elementName)!");
        }
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        if (parentElement() == "title" && grandParentElement() == "channel" && grangrandParentElement() == "rss") {
            ftitle = string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil);
        } else if (parentElement() == "description" && grandParentElement() == "channel" && grangrandParentElement() == "rss") {
            fdescription = string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil);
        } else if (parentElement() == "pubDate" && grandParentElement() == "channel" && grangrandParentElement() == "rss") {
            fpubDateString = string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil);
        } else if (parentElement() == "url" && grandParentElement() == "image" && grangrandParentElement() == "channel") {
            fimageUrlString = string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil);
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser!) {
        println("Fround ftitle=\(ftitle), fdescription=\(fdescription), fpubDateString=\(fpubDateString), fimageUrlString=\(fimageUrlString).");
        delegate.onParseResult(title: self.ftitle, pubDate: self.fpubDateString, description: self.fdescription, imageUrl: self.fimageUrlString)
    }
}