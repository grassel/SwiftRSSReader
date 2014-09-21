
import UIKit
import CoreData

let rssFeedChannelTableName = "RSSFeedChannelsEntity";

class RssFeedsChannelListTableViewController: UITableViewController {
    
    @IBOutlet weak var rightSideButton: UIBarButtonItem!
    @IBOutlet weak var leftSideButton: UIBarButtonItem!
    
    var feedsList : Array<AnyObject> = []
    var inEditMode : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        println("viewWillAppear");
        
        let appDel : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate;
        let context : NSManagedObjectContext = appDel.managedObjectContext!;
        let freq = NSFetchRequest(entityName: rssFeedChannelTableName);
        
        feedsList = context.executeFetchRequest(freq, error: nil)!
        
        inEditMode = false;
        rightSideButton.title = "Edit";
        leftSideButton.title = "Back";
        
        tableView.allowsSelectionDuringEditing = true; //needed, otherwise we do not get item selections while ableView.setEditing(true,...)
        tableView.setEditing(false, animated: false);
        tableView.reloadData()
    }
    
    @IBAction func leftButtonSelected(sender: AnyObject) {
        if inEditMode {
            exitEditMode();
        } else {
            gotoRssFeedWithoutChange();
        }
    }
    
    func gotoRssFeedWithoutChange() {
        // go back to the RSS Feed without changing to another feed
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // the button has done functions, depending on inEditMode
    // inEditMode: add new RSS feed
    // !inEditMode: enter edit mode
    @IBAction func rightButtonSelected(sender: AnyObject) {
        if inEditMode {
            addNewFeedSelected();
        } else {
            enterEditMode();
        }
    }
    
    func addNewFeedSelected() {
        if let newViewController  = self.storyboard?.instantiateViewControllerWithIdentifier("NewFeedViewController") as? NewFeedViewController {
            self.navigationController?.pushViewController(newViewController , animated: true);
        }
    }
    
    func enterEditMode() {
        if (inEditMode) {
            return;
        }
        
        rightSideButton.title = "+";
        leftSideButton.title = "Done";
        inEditMode = true;
        tableView.setEditing(true, animated: true);
    }
    
    func exitEditMode() {
        if (!inEditMode) {
            return;
        }
        
        rightSideButton.title = "Edit";
        leftSideButton.title = "Back";
        inEditMode = false;
        tableView.setEditing(false, animated: true);
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var index = self.tableView.indexPathForSelectedRow()?.row;
        var selectedItem : NSManagedObject = feedsList[index!] as NSManagedObject
        
        if (inEditMode) {
            if let newFeedViewController  = self.storyboard?.instantiateViewControllerWithIdentifier("NewFeedViewController") as? NewFeedViewController {
                newFeedViewController.urlString = selectedItem.valueForKey("urlString") as String;
                newFeedViewController.titleString = selectedItem.valueForKey("titleString") as String;
                newFeedViewController.existingItem = selectedItem
                self.navigationController?.pushViewController(newFeedViewController , animated: true);
            }
        } else {
            if let vcStack = self.navigationController?.viewControllers {
                var newFeedViewController = vcStack[vcStack.count-2] as RssFeedItemListTableViewController;
                newFeedViewController.urlString = selectedItem.valueForKey("urlString") as String;
                newFeedViewController.titleString = selectedItem.valueForKey("titleString") as String;
                newFeedViewController.reloadFeed();
                self.navigationController?.popToViewController(newFeedViewController, animated: true);
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return feedsList.count;
    }
    
    
    // returns the cell or given index
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // configure the cell.
        let cellID : NSString = "feedsCell"; // match what's been defined in the storyboard.
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellID) as UITableViewCell;
        
        let ip = indexPath
        var data : NSManagedObject = feedsList[ip.row] as NSManagedObject;
        
        cell.textLabel?.text = data.valueForKey("titleString") as? String;
        cell.detailTextLabel?.text = data.valueForKey("urlString") as? String;
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return inEditMode;
    }
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {
    
    }
    */
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return false;
    }
    
    
    // MARK: - Navigation
    
    //   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //   }
}
