//
//  RSSTableViewController.swift
//  SwiftRSS
//
//  Created by albert mckeever on 8/4/14.
//  fized to work with XCODE 6 GM by grassel on Sept 12
//  Copyright (c) 2014 albert mckeever. All rights reserved.
//

import UIKit

class RSSTableViewController: UITableViewController, RSSFeedItemsParserDelegate {

    var urlString : String = "http://www.spiegel.de/schlagzeilen/tops/index.rss"   // url of the currently displayed RSS feed
    var feeds : NSMutableArray = []  // holds the result
    
    var parser : RSSFeedItemsParser = RSSFeedItemsParser();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parser.delegate = self;
        parser.parseRssFeedItemsAsync(urlString);
        // RSSFeedItemsParserDelegate delivers results
    }
    
    // RSSFeedItemsParserDelegate
    func parseItem(ftitle : NSMutableString, link : NSMutableString, fdescription : NSMutableString) {
        // FIXME, we need a new container RssFeedItem
        feeds.addObject(rssFeedItem);
        self.tableView.reloadData()
    }
    
    // RSSFeedItemsParserDelegate
  //  func parseDone() {
      //  self.tableView.reloadData()
   // }
   
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
