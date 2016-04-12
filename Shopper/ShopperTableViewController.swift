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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addShoppingList:")

        reloadData()
    }
    
    func reloadData() {
        
        let fetchRequest = NSFetchRequest(entityName: "ShoppingList")
        
        do{
            if let results = try managedObjectContext.executeFetchRequest(fetchRequest) as? [ShoppingList] {
                shoppingLists = results
                tableView.reloadData()
            }
        } catch {
             fatalError("There was an error fetching shopping lists!")
      }
        
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
