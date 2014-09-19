
import UIKit
import CoreData

let rssFeedChannelTableName = "RSSFeedChannelsEntity";

class RssFeedsChannelListTableViewController: UITableViewController {
    
    var feedsList : Array<AnyObject> = []

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
        tableView.reloadData()
    }
    
    @IBAction func doeSelected(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func addNewFeedSelected(sender: AnyObject) {
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
    
    /*
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

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

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "updateFeedInfo") {
            var index = self.tableView.indexPathForSelectedRow()?.row;
            var selectedItem : NSManagedObject = feedsList[index!] as NSManagedObject
            
            let newFeedViewController : NewFeedViewController = segue.destinationViewController as NewFeedViewController
            newFeedViewController.urlString = selectedItem.valueForKey("urlString") as String;
            newFeedViewController.titleString = selectedItem.valueForKey("titleString") as String;
            newFeedViewController.existingItem = selectedItem
        }
    }
}
