
import Foundation
import UIKit

protocol RssFeedChannelParserDelegate {
    func parseValue(title ftitle : String);
    func parseValue(description fdescription: String);
    func parseValue(pubDate fpubDateString : String);
    func parseValue(imageUrl fimageUrlString :String);
    func parseValue(decodedImage image: UIImage);
    func parseDone();
}