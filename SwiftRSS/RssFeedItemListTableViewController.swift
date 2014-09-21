//
//  RSSTableViewController.swift
//  SwiftRSS
//
//  Created by albert mckeever on 8/4/14.
//  fized to work with XCODE 6 GM by grassel on Sept 12
//  Copyright (c) 2014 albert mckeever. All rights reserved.
//

import UIKit

class RssFeedItemListTableViewController: UITableViewController, RSSFeedItemsParserDelegate {

    var urlString : String = "http://www.spiegel.de/schlagzeilen/tops/index.rss"   // url of the currently displayed RSS feed
    var titleString : String = "FIXME";
    
    var feeds : Array<RssFeedItemModel> = []  // holds the result
    
    var parser : RSSFeedItemsParser = RSSFeedItemsParser();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parser.delegate = self;
        
        self.reloadFeed();
    }
    
    // FIXME: put some logic here to only reload the feed when needed, 
    // needed when comming here from RssFeedsChannelListTableViewController
    // otherwise not
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
    }
    
    func reloadFeed() {
        self.feeds.removeAll(keepCapacity: true);
        self.tableView.reloadData()
        parser.parseRssFeedItemsAsync(urlString);
        // RSSFeedItemsParserDelegate delivers results
    }
    
    // RSSFeedItemsParserDelegate
    func parseItem(feedItem : RssFeedItemModel) {
        //println("parseItem: appending \(feedItem.ftitle), \(feedItem.link).");
        feeds.append(feedItem)
       // self.tableView.reloadData()
    }
    
    // RSSFeedItemsParserDelegate
    func parseDone() {
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
        var feedItem = feeds[index];
        cell.textLabel!.text = feedItem.ftitle;
        cell.detailTextLabel!.numberOfLines = 3
        cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail;
        cell.detailTextLabel!.text = feedItem.fdescription;
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "webViewOpenSegue") {
            var index : Int! = self.tableView.indexPathForSelectedRow()?.row;
            var feedItem = feeds[index];
            let webViewControler : WebViewViewController = segue.destinationViewController as WebViewViewController
            webViewControler.url = feedItem.link;
        } else if (segue.identifier == "feedsBookmarksSeque") {
            let feedsViewController : RssFeedsChannelListTableViewController = segue.destinationViewController as RssFeedsChannelListTableViewController;
           // pass parameters to  feedsViewController
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
