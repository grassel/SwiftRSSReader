
import UIKit
import CoreData

class NewFeedViewController: UIViewController, RssFeedChannelParserDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var rssFeedUrlField: UITextField!
    @IBOutlet weak var rssFeedTitleLabel: UILabel!
    @IBOutlet weak var rssFeedImage: UIImageView!
    @IBOutlet weak var rssFeedDescriptionLabel: UILabel!
    @IBOutlet weak var rssFeedPubDateLabel: UILabel!
    @IBOutlet weak var updateFeedButton: UIButton!

    // properties used to move data access from the ListTabletViewController
    var urlString : String = ""
    var titleString : String = ""
    var existingItem : NSManagedObject! = nil;
    
    var checkedUrl : String!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rssFeedUrlField.delegate = self;
        rssFeedUrlField.enabled = true;
        rssFeedUrlField.textColor = UIColor.darkTextColor();

        rssFeedDescriptionLabel.numberOfLines = 0; // unlimited number of lines
        rssFeedDescriptionLabel.hidden = true;
        
        rssFeedPubDateLabel.hidden = true;
        rssFeedPubDateLabel.hidden = true;
        
        updateFeedButton.hidden = true;
        
        if existingItem == nil {
            rssFeedTitleLabel.hidden = true;
        } else {
            rssFeedUrlField.text = urlString;
            rssFeedTitleLabel.text = titleString
            
            if (urlString != "") {
                parseRSSFeedChannelAsync(urlString);
            }
        } 
    }
 
    
    /* http://stackoverflow.com/questions/1054558/vertically-align-text-within-a-uilabel
    If your label is included in a nib or storyboard as a subview of the view of a ViewController that uses autolayout, then putting your sizeToFit call into viewDidLoad won't work, because autolayout sizes and positions the subviews after viewDidLoad is called and will immediately undo the effects of your sizeToFit call. However, calling sizeToFit from within viewDidLayoutSubviews will work.
    */
    override func viewDidLayoutSubviews() {
        rssFeedDescriptionLabel.sizeToFit();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // URL TextField gains input focus, keyboard appears
        rssFeedUrlField.becomeFirstResponder();
    }
    
    // 1. method to end the UITextField entry:
    // called whenever touching outside a UI element
    // take the url from the entry fielf and attempt to
    // load and parse the RSS feed
    @IBAction func onTapGesture(sender: UITapGestureRecognizer) {
        //println("Gesture tap")
        evalUrlEntry();
    }
    
    // 2. method to end the UITextField entry:
    // UITextFieldDelegate delegate, 'Return' / 'Done' key touched
    // The text field calls this method whenever the user taps the return button. You can use this method to implement any custom behavior when the button is tapped.
    // Return Value: true if the text field should implement its default behavior for the return button; otherwise, false.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //println("textFieldShouldReturn")
        return !evalUrlEntry()
    }
    
    func evalUrlEntry() -> Bool {
        // TODO check entry
        if (checkedUrl == nil || checkedUrl! != rssFeedUrlField!.text) {
            checkedUrl = rssFeedUrlField!.text
            parseRSSFeedChannelAsync(checkedUrl!);
            return true;
        }
        return true;
    }
    
    
    func parseRSSFeedChannelAsync(urlToRssFeed : String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
        var parser = RssFeedChannelParser();
        parser.delegate = self;
        parser.parseRssFeedChannelAsync(urlToRssFeed);
        // RssFeedChannelParserDelegate.parseValue(role: ...) deliver the results.
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
    func parseValue(title ftitle: String, description fdescription: String, pubDate fpubDateString: String, imageUrl fimageUrlString: String) {
        rssFeedTitleLabel.text = ftitle;
        
        rssFeedDescriptionLabel.hidden = false;
        rssFeedDescriptionLabel.text = fdescription;

        rssFeedPubDateLabel.hidden = false;
        rssFeedPubDateLabel.text = "Published:\n\(fpubDateString)";
    }
    
    func parseValue(decodedImage image: UIImage) {
        rssFeedImage.hidden = false;
        rssFeedImage.image = image;
    }
    
    
 //   func parseDone() {
 //       updateFeedButton.hidden = false;
 //   }
    
    // RssFeedChannelParserDelegate
    func parsingSucceeded() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
        updateFeedButton.hidden = false;
       // rssFeedUrlField.enabled = false;
        rssFeedUrlField.textColor = UIColor.darkTextColor()
        rssFeedUrlField.enabled = true;
        rssFeedUrlField.resignFirstResponder();
    }
    
    // RssFeedChannelParserDelegate
    func  parsingFaied() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
        updateFeedButton.hidden = true;
        rssFeedUrlField.enabled = true;
        rssFeedUrlField.textColor = UIColor.redColor();
        rssFeedUrlField.becomeFirstResponder();
    }
    
    @IBAction func saveButtonSelected(sender: AnyObject) {
        // reference app delegate
        let appDel : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        // referene managed object context
        let context : NSManagedObjectContext = appDel.managedObjectContext!
        let en = NSEntityDescription.entityForName("RssFeeds1", inManagedObjectContext: context)
        
        // check if item exists
        if existingItem != nil {
            existingItem.setValue(rssFeedUrlField.text, forKey: "urlString");
            existingItem.setValue(rssFeedTitleLabel.text, forKey: "titleString");
            
            println("existing item saved: \(existingItem)");
        } else {
            // create instance of pur data model and initialize
            var newItem = RssFeedChannelModel(entity: en!, insertIntoManagedObjectContext: context)
            
            // map properties
            newItem.urlString = rssFeedUrlField!.text;
            newItem.titleString = rssFeedTitleLabel!.text!;
            
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
