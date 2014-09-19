
import UIKit
import CoreData

class RssFeedChannelModel : NSManagedObject {

    @NSManaged var urlString : String;
    @NSManaged var titleString : String;

    /* see https://developer.apple.com/library/prerelease/mac/documentation/Swift/Conceptual/BuildingCocoaApps/WritingSwiftClassesWithObjective-CBehavior.html
    section : Implementing Core Data Managed Object Subclasses
    
    Swift classes are namespaced—they’re scoped to the module (typically, the project) they are compiled in. To use a Swift subclass of the NSManagedObject class with your Core Data model, prefix the class name in the Class field in the model entity inspector with the name of your module.
    */

}

