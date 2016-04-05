//
//  ShoppingListTableViewController.swift
//  Shopper
//
//  Created by student on 3/31/16.
//  Copyright © 2016 Aquino. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListTableViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    
    var selectedShoppingList: ShoppingList?
    
    var shoppingListItems = [ShoppingListItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addShoppingListItem:")

        reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadData() {
        
        if let selectedShoppingList = selectedShoppingList {
            
            if let listItems = selectedShoppingList.items?.allObjects as? [ShoppingListItem] {
                shoppingListItems = listItems
            }
        }
        
        tableView.reloadData()
        
    }
    
    func addShoppingListItem(sender: AnyObject?) {
    
        let alert = UIAlertController(title: "Add", message: "Shopping List Item", preferredStyle: .Alert)
        
        let addAction = UIAlertAction(title: "Add", style: .Default) { (action) -> Void in
            
            if let nameTextField = alert.textFields?[0], priceTextField = alert.textFields?[1], quantityTextField = alert.textFields?[2], shoppingListItemEntity = NSEntityDescription.entityForName("ShoppingListItem", inManagedObjectContext: self.managedObjectContext), name = nameTextField.text, price = priceTextField.text, quantity = quantityTextField.text {
                
                let newShoppingListItem = ShoppingListItem(entity: shoppingListItemEntity, insertIntoManagedObjectContext: self.managedObjectContext)
                
                newShoppingListItem.name = name
                newShoppingListItem.quantity = Int(quantity)!
                newShoppingListItem.price = Double(price)!
                newShoppingListItem.purchased = false
                newShoppingListItem.shoppingList = self.selectedShoppingList
                
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print("Error saving the managed objec context!")
                }
                
                self.reloadData()
                
            }
        }
        
        let cancelAction = UIAlertAction (title: "Cancel", style: .Default) { (action) -> Void in }
        
        alert.addTextFieldWithConfigurationHandler { (textField) in textField.placeholder = "Name" }
        alert.addTextFieldWithConfigurationHandler { (textField) in textField.placeholder = "Price" }
        alert.addTextFieldWithConfigurationHandler { (textField) in textField.placeholder = "Quantity" }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shoppingListItems.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ShoppingListItemCell", forIndexPath: indexPath)

        // Configure the cell...
        let shoppingListItem = shoppingListItems[indexPath.row]
        
        
        let sQuantity = String(shoppingListItem.quantity)
        let sPrice = String(shoppingListItem.price)
        let purchase = shoppingListItem.purchased
        
        cell.textLabel?.text = shoppingListItem.name
        cell.detailTextLabel?.text = sQuantity + " | $" + sPrice

        if purchase == false {
            cell.accessoryType = .None
        } else {
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
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
