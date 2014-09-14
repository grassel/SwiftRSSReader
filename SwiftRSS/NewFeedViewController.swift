
import UIKit
import CoreData

class NewFeedViewController: UIViewController, RssFeedChannelParserDelegate {
   
    @IBOutlet weak var rssFiedUrlField: UITextField!
    @IBOutlet weak var rssFiedTitleLabel: UILabel!
    @IBOutlet weak var rssFeedImage: UIImageView!
    @IBOutlet weak var rssFeedDescriptionLabel: UILabel!
    @IBOutlet weak var rssFeedPubDateLabel: UILabel!

    // properties used to move data access from the ListTabletViewController
    var urlString : String = ""
    var titleString : String = ""
    var existingItem : NSManagedObject! = nil;

    // queue for doing RSS parsing in background thread
    let queue = NSOperationQueue()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        rssFeedDescriptionLabel.numberOfLines = 0; // unlimited number of lines
        rssFeedDescriptionLabel.sizeToFit();
        
        if existingItem != nil {
            rssFiedUrlField.text = urlString;
            rssFiedTitleLabel.text = titleString
            
            if (urlString != "") {
                var parser = RssFeedChannelParser();
                parser.delegate = self;
                parser.parseRssFeedChannel(urlString);
            }
        }
    }
    
    /* http://stackoverflow.com/questions/1054558/vertically-align-text-within-a-uilabel
        If your label is included in a nib or storyboard as a subview of the view of a ViewController that uses autolayout, then putting your sizeToFit call into viewDidLoad won't work, because autolayout sizes and positions the subviews after viewDidLoad is called and will immediately undo the effects of your sizeToFit call. However, calling sizeToFit from within viewDidLayoutSubviews will work.
    */
    override func viewDidLayoutSubviews() {
        rssFeedDescriptionLabel.sizeToFit();
    }
    
    @IBAction func fetchButtonSelected(sender: AnyObject) {
        var urlString = rssFiedUrlField!.text;
        
        /* http://stackoverflow.com/questions/24589575/how-to-do-multithreading-concurrency-or-parallelism-in-ios-swift
          func addOperationWithBlock(block: (() -> Void)!)
          block role is extraneous, and last func argument, can be shortened to
          queue.addOperationWithBlock() { ... }
        */
        queue.addOperationWithBlock() {
            var parser = RssFeedChannelParser();
            parser.delegate = self;
            parser.parseRssFeedChannel(urlString);
        }
    }
    
    
    func parseValue(title ftitle: String) {
        // update UILabel in UI thread
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            // when done, update your UI and/or model on the main queue
            self.rssFiedTitleLabel.text = ftitle;
        };
    }
    
    func parseValue(description fdescription: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.rssFeedDescriptionLabel.text = fdescription;
        }
    }
    
    func parseValue(pubDate fpubDateString : String) {
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.rssFeedPubDateLabel.text = "Published:\n\(fpubDateString)";
        }
    }
    
    func parseValue(imageUrl fimageUrlString :String) {
        // fetch the image data in the background
        queue.addOperationWithBlock() {
            let url = NSURL.URLWithString(fimageUrlString);
            var err: NSError?
            var imageData :NSData = NSData.dataWithContentsOfURL(url,options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err);
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                // set the image content in the foreground
                self.rssFeedImage.image = UIImage(data:imageData);
            }
        }
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
            var newItem = RssFeedModel(entity: en!, insertIntoManagedObjectContext: context)
            
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
