
import Foundation

@objc protocol RSSFeedItemsParserDelegate {
    optional func parseItem(feedIem : RssFeedItemModel);
    optional func parseDone();
}