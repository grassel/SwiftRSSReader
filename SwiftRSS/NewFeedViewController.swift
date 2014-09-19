
import UIKit
import CoreData

class NewFeedViewController: UIViewController, RssFeedChannelParserDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var rssFiedUrlField: UITextField!
    @IBOutlet weak var rssFiedTitleLabel: UILabel!
    @IBOutlet weak var rssFeedImage: UIImageView!
    @IBOutlet weak var rssFeedDescriptionLabel: UILabel!
    @IBOutlet weak var rssFeedPubDateLabel: UILabel!
    @IBOutlet weak var updateFeedButton: UIButton!

    // properties used to move data access from the ListTabletViewController
    var urlString : String = ""
    var titleString : String = ""
    var existingItem : NSManagedObject! = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rssFeedDescriptionLabel.numberOfLines = 0; // unlimited number of lines
        rssFeedDescriptionLabel.hidden = true;
        rssFeedPubDateLabel.hidden = true;
        rssFeedPubDateLabel.hidden = true;
        updateFeedButton.hidden = true;
        
        if existingItem != nil {
            rssFiedUrlField.text = urlString;
            rssFiedTitleLabel.text = titleString
            
            if (urlString != "") {
                parseRSSFeedChannelAsync(urlString);
            }
        }else {
            rssFiedTitleLabel.hidden = true;

        }
    }
    
    
    /* http://stackoverflow.com/questions/1054558/vertically-align-text-within-a-uilabel
    If your label is included in a nib or storyboard as a subview of the view of a ViewController that uses autolayout, then putting your sizeToFit call into viewDidLoad won't work, because autolayout sizes and positions the subviews after viewDidLoad is called and will immediately undo the effects of your sizeToFit call. However, calling sizeToFit from within viewDidLayoutSubviews will work.
    */
    override func viewDidLayoutSubviews() {
        rssFeedDescriptionLabel.sizeToFit();
    }
    
    // UITextFieldDelegate delegate
    func textFieldDidEndEditing(textField: UITextField) {
        if (rssFiedUrlField != textField) {
            return; // defensive programming: since we only have one TextField this should never happen.
        }
        textField.resignFirstResponder();
        if (urlString != textField.text!) {
            // the url has been entered from scratch or it has been edited
            // fetch the feed description
            parseRSSFeedChannelAsync(rssFiedUrlField!.text);
        }
    }
    
    func parseRSSFeedChannelAsync(urlToRssFeed : String) {
        var parser = RssFeedChannelParser();
        parser.delegate = self;
        parser.parseRssFeedChannelAsync(urlToRssFeed);
        // RssFeedChannelParserDelegate.parseValue(role: ...) deliver the results.
    }
    
    // RssFeedChannelParserDelegate
    func parseValue(title ftitle: String) {
        rssFeedDescriptionLabel.hidden = false;
        rssFiedTitleLabel.text = ftitle;
    }
    
    // RssFeedChannelParserDelegate
    func parseValue(description fdescription: String) {
        rssFeedDescriptionLabel.hidden = false;
        rssFeedDescriptionLabel.text = fdescription;
    }
    
    // RssFeedChannelParserDelegate
    func parseValue(pubDate fpubDateString : String) {
        rssFeedPubDateLabel.hidden = false;
        rssFeedPubDateLabel.text = "Published:\n\(fpubDateString)";
    }
    
    // RssFeedChannelParserDelegate
    func parseValue(imageUrl fimageUrlString: String) {
        // do nothing, wait for UIImage
        /*
        FIXME: use optional method in protocol, but how to check i delegate implements the method
        (the issue is about checking if a delegate implements the method inside the block argument
        of addOperationWithBlock(block: { ... } )
        */
    }
    
    // RssFeedChannelParserDelegate
    func parseValue(decodedImage image: UIImage) {
        rssFeedImage.hidden = false;
        rssFeedImage.image = image;
    }
    
    
    // RssFeedChannelParserDelegate
    func parseDone() {
        updateFeedButton.hidden = false;
    }
    
    @IBAction func saveButtonSelected(sender: AnyObject) {
        // reference app delegate
        let appDel : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        // referene managed object context
        let context : NSManagedObjectContext = appDel.managedObjectContext!
        let en = NSEntityDescription.entityForName("RssFeeds1", inManagedObjectContext: context)
        
        // check if item exists
        if existingItem != nil {
            existingItem.setValue(rssFiedUrlField.text, forKey: "urlString");
            existingItem.setValue(rssFiedTitleLabel.text, forKey: "titleString");
            
            println("existing item saved: \(existingItem)");
        } else {
            // create instance of pur data model and initialize
            var newItem = RssFeedChannelModel(entity: en!, insertIntoManagedObjectContext: context)
            
            // map properties
            newItem.urlString = rssFiedUrlField!.text;
            newItem.titleString = rssFiedTitleLabel!.text!;
            
            println("new item saved: \(newItem)");
        }
        
        // save context
        context.save(nil) // no error handling
        
        
        // navigate back to RSSFeeds View Controller view controller, animated
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
}
