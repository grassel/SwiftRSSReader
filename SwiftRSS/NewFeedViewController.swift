
import UIKit
import CoreData

class NewFeedViewController: UIViewController {
   
    @IBOutlet weak var rssFiedUrlField: UITextField!
    @IBOutlet weak var rssFiedTitleLabel: UILabel!
    
    // properties used to move data access from the ListTabletViewController
    var urlString : String = ""
    var titleString : String = ""
    var existingItem : NSManagedObject! = nil;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if existingItem != nil {
            rssFiedUrlField.text = urlString;
            rssFiedTitleLabel.text = titleString
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
