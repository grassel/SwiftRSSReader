
import Foundation

@objc protocol RSSFeedItemsParserDelegate {
    optional func parseItem(ftitle : NSMutableString, link : NSMutableString, fdescription : NSMutableString);
    optional func parseDone();
}