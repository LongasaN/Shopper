//
//  ShopperTableViewController.swift
//  Shopper
//
//  Created by Nina Longasa on 3/22/16.
//  Copyright © 2016 Aquino. All rights reserved.
//

import UIKit
import CoreData

class ShopperTableViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    var shoppingLists = [ShoppingList]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addShoppingList:"),
            UIBarButtonItem(title: "Filter", style: .Plain, target: self, action: "selectFilter:"),
            UIBarButtonItem(title: "Sort", style: .Plain, target: self, action: "selectSort:")]

        reloadData()
    }
    
    func reloadData(storeFilter: String? = nil, sortDescriptor: String? = nil) {
        
        let fetchRequest = NSFetchRequest(entityName: "ShoppingList")
        
        if let storeFilter = storeFilter {
            let storePredicate = NSPredicate(format: "store =[c] %@", storeFilter)
            fetchRequest.predicate = storePredicate
        }
        
        if let sortDescriptor = sortDescriptor {
            let sort = NSSortDescriptor(key: sortDescriptor, ascending: true)
                fetchRequest.sortDescriptors = [sort]
        }
        
        do {
            if let results = try managedObjectContext.executeFetchRequest(fetchRequest) as? [ShoppingList] {
                shoppingLists = results
                tableView.reloadData()
            }
        } catch {
             fatalError("There was an error fetching shopping lists!")
      }
        
    }
    
    func selectSort(sender: AnyObject?){
        
        let sheet = UIAlertController(title: "Sort", message: "Shopping Lists", preferredStyle: .ActionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {(action) -> Void in}))
        
        // By Store
        sheet.addAction(UIAlertAction(title: "By Store", style: .Default, handler: {(action) -> Void in
            self.reloadData(nil, sortDescriptor: "store")
        }))
        
        // By Name
        sheet.addAction(UIAlertAction(title: "By Name", style: .Default, handler: {(action) -> Void in
            self.reloadData(nil, sortDescriptor: "name")
        }))
        
        // By Date
        sheet.addAction(UIAlertAction(title: "By Date", style: .Default, handler: {(action) -> Void in
            self.reloadData(nil, sortDescriptor: "date")
        }))
        
        presentViewController(sheet, animated: true, completion: nil)
        
    }
    
    func selectFilter(sender: AnyObject?){
        
        let alert = UIAlertController(title: "Filter", message: "Shopping Lists", preferredStyle: .Alert)
        
        let filterAction = UIAlertAction(title: "Filter", style: .Default) {
            (action) -> Void in
            
            if let storeTextField = alert.textFields?[0], store = storeTextField.text {
                self.reloadData(store)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) {
            (action) -> Void in
            self.reloadData()
        }
        
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Store"
        }
        
        alert.addAction(filterAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func addShoppingList(sender: AnyObject?){
        
        let alert = UIAlertController(title: "Add", message: "ShoppingList", preferredStyle: .Alert)
        let addAction = UIAlertAction(title: "Add", style: .Default) { (action) -> Void in
            
            if let nameTextField = alert.textFields?[0], storeTextField = alert.textFields?[1], dateTextField = alert.textFields?[2], shoppingListEntity = NSEntityDescription.entityForName("ShoppingList", inManagedObjectContext: self.managedObjectContext), name = nameTextField.text, store = storeTextField.text, date = dateTextField.text
            {
                let newShoppingList = ShoppingList(entity: shoppingListEntity, insertIntoManagedObjectContext: self.managedObjectContext)
                
                newShoppingList.name = name
                newShoppingList.store = store
                newShoppingList.date = date
                
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print("Error saving the managed object context!")
                }
                
                self.reloadData()
                
            }
        
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action) -> Void in
            // This doesn't do anything
        }
        
        alert.addTextFieldWithConfigurationHandler { (textField) in textField.placeholder = "Name" }
        alert.addTextFieldWithConfigurationHandler { (textField) in textField.placeholder = "Store" }
        alert.addTextFieldWithConfigurationHandler { (textField) in textField.placeholder = "Date" }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shoppingLists.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ShoppingListCell", forIndexPath: indexPath)

        // Configure the cell...
        let shoppingList = shoppingLists[indexPath.row]
        
        cell.textLabel?.text = shoppingList.name
        cell.detailTextLabel?.text = shoppingList.store + " " + shoppingList.date

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let itemsTableViewController = storyboard?.instantiateViewControllerWithIdentifier("ShoppingListItems") as? ShoppingListTableViewController {
            let list = shoppingLists[indexPath.row]
            
            itemsTableViewController.managedObjectContext = managedObjectContext
            itemsTableViewController.selectedShoppingList = list
            
            navigationController?.pushViewController(itemsTableViewController, animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

   
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let item = shoppingLists[indexPath.row]
            
            managedObjectContext.deleteObject(item)
            
            do {
                try self.managedObjectContext.save()
            } catch {
                print("Error saving the managed object context!")
            }
            
            reloadData()
        }    
    }
   

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
