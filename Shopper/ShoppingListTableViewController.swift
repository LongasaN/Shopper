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
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addShoppingListItem:"), UIBarButtonItem(title: "Filter", style: .Plain, target: self, action: "selectFilter:"), UIBarButtonItem(title: "Sort", style: .Plain, target: self, action: "selectSort:")]

        reloadData()
        
        var totalCost = 0.0
        
        for list in shoppingListItems {
            totalCost += Double(list.price) * Double(list.quantity)
        }
        
        if let selectedShoppingList = selectedShoppingList {
            title = selectedShoppingList.name + String(format: " $%.2f", totalCost)
        } else {
            title = "Shopping List Detail"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadData(nameFilter: String? = nil, sortDescriptor: String? = nil ) {
        
        let fetchRequest = NSFetchRequest(entityName: "ShoppingListItem")
        
        //first predicate
        let listPredicate = NSPredicate(format: "shoppingList =[c] %@", selectedShoppingList!)
    
        //second predicate
        if let nameFilter = nameFilter {
            let namePredicate = NSPredicate(format: "name =[c] %@", nameFilter)
            fetchRequest.predicate = namePredicate
            
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [listPredicate, namePredicate])
            
            fetchRequest.predicate = compoundPredicate
        } else {
            fetchRequest.predicate = listPredicate
        }
        
        if let sortDescriptor = sortDescriptor {
            let sort = NSSortDescriptor(key: sortDescriptor, ascending: true)
            fetchRequest.sortDescriptors = [sort]
        }
        
        /*if let selectedShoppingList = selectedShoppingList {
            
            if let listItems = selectedShoppingList.items?.allObjects as? [ShoppingListItem] {
                shoppingListItems = listItems
            }
        }
        
        tableView.reloadData() */
        
        do {
            if let results = try managedObjectContext.executeFetchRequest(fetchRequest) as? [ShoppingListItem] {
                shoppingListItems = results
                tableView.reloadData()
            }
        } catch {
            fatalError("There was an error fetching shopping lists!")
        }

        
    }
    
    func selectSort(sender: AnyObject?){
        
        let sheet = UIAlertController(title: "Sort", message: "Shopping List Items", preferredStyle: .ActionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {(action) -> Void in}))
        
        // By Store
        sheet.addAction(UIAlertAction(title: "By Name", style: .Default, handler: {(action) -> Void in
            self.reloadData(nil, sortDescriptor: "name")
        }))
        
        // By Name
        sheet.addAction(UIAlertAction(title: "By Price", style: .Default, handler: {(action) -> Void in
            self.reloadData(nil, sortDescriptor: "price")
        }))
        
        // By Date
        sheet.addAction(UIAlertAction(title: "By Quantity", style: .Default, handler: {(action) -> Void in
            self.reloadData(nil, sortDescriptor: "quantity")
        }))
        
        presentViewController(sheet, animated: true, completion: nil)
    }
    
    
    func selectFilter(sender: AnyObject?){
        
        let alert = UIAlertController(title: "Filter", message: "Shopping Lists", preferredStyle: .Alert)
        
        let filterAction = UIAlertAction(title: "Filter", style: .Default) {
            (action) -> Void in
            
            if let nameTextField = alert.textFields?[0], name = nameTextField.text {
                self.reloadData(name)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) {
            (action) -> Void in
            self.reloadData()
        }
        
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Name"
        }
        
        alert.addAction(filterAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
        
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ShoppingListItemCell", forIndexPath: indexPath)
        
        let shoppingListItem = shoppingListItems[indexPath.row]
        
        let sQuantity = String(shoppingListItem.quantity)
        let sPrice = String(shoppingListItem.price)
        
        if shoppingListItem.purchased == true {
            cell.accessoryType = .None
            shoppingListItem.purchased = false
        } else {
            cell.accessoryType = .Checkmark
            shoppingListItem.purchased = true
        }
        
        cell.textLabel?.text = shoppingListItem.name
        cell.detailTextLabel?.text = sQuantity + " | $" + sPrice
        
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Error saving the managed object context!")
        }
        
        reloadData()
        
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
            
            let item = shoppingListItems[indexPath.row]
            
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
