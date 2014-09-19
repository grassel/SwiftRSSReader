
import Foundation

@objc class RssFeedItemModel : NSObject {
    var ftitle  : String = "";
    var fdescription  : String = ""
    var link  : String = "";
    
    override init() {
        super.init();
        self.ftitle = "";
        self.fdescription = "";
        self.link = "";
    }
    
    init (ftitle : String, link : String, fdescription : String) {
        super.init();
        self.ftitle = ftitle;
        self.fdescription = fdescription;
        self.link = link;
    }
};