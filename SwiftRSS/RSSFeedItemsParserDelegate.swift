
import Foundation

@objc protocol RSSFeedItemsParserDelegate {
    optional func parseItem(feedIem : RssFeedItemModel);
    
    // end of document reached
    // not sure this is of much value
    optional func parseDone();
    
    // retrieving or parsing has failed
 //   optional func parsingFaied();
    
    // retrieving and parsing has succeeded
 //   optional func parsingSucceeded();
}