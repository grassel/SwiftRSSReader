//
//  RSSTableViewController.swift
//  SwiftRSS
//
//  Created by albert mckeever on 8/4/14.
//  fized to work with XCODE 6 GM by grassel on Sept 12
//  Copyright (c) 2014 albert mckeever. All rights reserved.
//

import UIKit

class RSSTableViewController: UITableViewController, NSXMLParserDelegate {

    var parser = NSXMLParser()
    var feeds = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var ftitle = NSMutableString()
    var link = NSMutableString()
    var fdescription = NSMutableString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feeds = []
        var url: NSURL = NSURL.URLWithString("http://www.spiegel.de/schlagzeilen/tops/index.rss")
        parser = NSXMLParser(contentsOfURL: url)
        parser.delegate = self
        parser.shouldProcessNamespaces = false
        parser.shouldReportNamespacePrefixes = false
        parser.shouldResolveExternalEntities = false
        parser.parse()
        
    }
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        
        element = elementName
        
        // instantiate feed properties
        
        if (element as NSString).isEqualToString("item") {
            elements = NSMutableDictionary.alloc()
            elements = [:]
            ftitle = ""
            link = NSMutableString.alloc()
            link = ""
            fdescription = NSMutableString.alloc()
            fdescription = ""
        }
        
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
            // process feed elements
        if  (elementName == "item") {
            if ftitle != "" {
                elements.setObject(ftitle, forKey: "title")
            }
            
            if link != "" {
                elements.setObject(link, forKey: "link")
            }
            
            if fdescription != "" {
                elements.setObject(fdescription, forKey: "description")
            }
            
            feeds.addObject(elements)
        }
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        if element.isEqualToString("title") {
            let s = string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil);
            ftitle.appendString(s)
        } else if element.isEqualToString("link") {
            let s = string.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil);
            link.appendString(s)
        } else if element.isEqualToString("description") {
            let s = string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil);
            fdescription.appendString(s)
        }
        
    }
    
    func parserDidEndDocument(parser: NSXMLParser!) {
       self.tableView.reloadData()
    }

   
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return feeds.count
    }

    // cellForRowAtIndexPath
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        var index = indexPath.row;
        cell.textLabel!.text = feeds.objectAtIndex(index).objectForKey("title") as? String
        cell.detailTextLabel!.numberOfLines = 3
        cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail;
        cell.detailTextLabel!.text = feeds.objectAtIndex(index).objectForKey("description") as? String
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "webViewOpenSegue") {
            var index : Int! = self.tableView.indexPathForSelectedRow()?.row;
            var selectedLink : String! = feeds.objectAtIndex(index!).objectForKey("link") as? String
            
            let webViewControler : WebViewViewController = segue.destinationViewController as WebViewViewController
            webViewControler.url = selectedLink;
        } else if (segue.identifier == "feedsBookmarksSeque") {
            let feedsViewController : FeedsTableViewController = segue.destinationViewController as FeedsTableViewController;
           // pass parameters to  feedsViewController
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
