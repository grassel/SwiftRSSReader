
import Foundation
import UIKit

@objc protocol RssFeedChannelParserDelegate {
    
    optional func parseValue(title ftitle : String,
        description fdescription: String,
        pubDate fpubDateString : String,
        imageUrl fimageUrlString :String);
    
    optional func parseValue(decodedImage image: UIImage);
    
    // end of document reached
    // not sure this is of much value
    optional func parseDone();
    
    // retrieving or parsing has failed
   optional func parsingFaied();
    
    // retrieving and parsing has succeeded
    optional func parsingSucceeded();
}