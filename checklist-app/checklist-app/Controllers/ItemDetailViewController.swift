//
//  ItemDetailViewController.swift
//  checklist-app
//
//  Created by Abel Osorio on 2/16/16.
//  Copyright © 2016 Abel Osorio. All rights reserved.
//

import UIKit

protocol ItemDetailViewControllerDelegate: class {
    
    func itemDetailViewControllerDidCancel(controller: ItemDetailViewController)
    func itemDetailViewController(controller: ItemDetailViewController,didFinishAddingItem item: CheckListItem)
    func itemDetailViewController(controller: ItemDetailViewController, didFinishEditingItem item: CheckListItem)
}

class ItemDetailViewController: UITableViewController,UITextFieldDelegate{
    
    @IBOutlet weak var itemTextField: UITextField!
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    
    @IBOutlet weak var dueDateLabel: UILabel!
    
    weak var delegate: ItemDetailViewControllerDelegate?
    
    var itemToEdit: CheckListItem?
    
    var dueDate = NSDate()
    
    var datePickerVisible = false
    
    @IBOutlet weak var datePickerCell: UITableViewCell!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        doneBarButton.enabled = false
        itemTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Item"
        
        if let item = itemToEdit {
            title = "Edit Item"
            itemTextField.text = item.text
            shouldRemindSwitch.on = item.shouldRemind
            dueDate = item.dueDate
        }
        
        updateDueDate()
    }
    
    // MARK: - TableView DataSource
    
    override func tableView(tableView: UITableView,heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 1 && indexPath.row == 2 {
            return 217
        } else {
            return super.tableView(tableView,heightForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 && datePickerVisible {
            return 3
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(tableView: UITableView,var indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        
        if indexPath.section == 1 && indexPath.row == 2 {
            indexPath = NSIndexPath(forRow: 0, inSection: indexPath.section)
        }
        return super.tableView(tableView,indentationLevelForRowAtIndexPath: indexPath)
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 2 {
            return datePickerCell
        } else {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        if indexPath.section == 1 && indexPath.row == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView,didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        itemTextField.resignFirstResponder()
        
        if indexPath.section == 1 && indexPath.row == 1 {
            if !datePickerVisible{
                showDatePicker()
            }else{
                hideDatePicker()
            }
            
        }
    }
    
    // MARK: - Actions
    
    @IBAction func cancelPressed(sender: AnyObject) {
        delegate?.itemDetailViewControllerDidCancel(self)
        
    }
    
    @IBAction func addPressed(sender: AnyObject) {
        if let item = itemToEdit {
            item.text = itemTextField.text!
            item.shouldRemind = shouldRemindSwitch.on
            item.dueDate = dueDate
            item.scheduleNotification()
            delegate?.itemDetailViewController(self, didFinishEditingItem: item)
            
        } else {
            let item = CheckListItem()
            item.text = itemTextField.text!
            item.checked = false
            item.shouldRemind = shouldRemindSwitch.on
            item.dueDate = dueDate
            item.scheduleNotification()
            delegate?.itemDetailViewController(self, didFinishAddingItem: item)
        }
    }
    
    @IBAction func shouldRemindToggled(switchControl: UISwitch) {
        itemTextField.resignFirstResponder()
        if switchControl.on {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert , .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        }
    }
    
    @IBAction func dateChanged(datePicker: UIDatePicker) {
        dueDate = datePicker.date
        updateDueDate()
        
    }
    
    // MARK: - Due Date Functions
    
    func showDatePicker() {
        
        datePickerVisible = true
        
        let indexPathDatePicker = NSIndexPath(forRow: 2, inSection: 1)
        let indexPathDateRow = NSIndexPath(forRow: 1, inSection: 1)
        
        if let dateCell = tableView.cellForRowAtIndexPath(indexPathDateRow){
            dateCell.detailTextLabel!.textColor = dateCell.detailTextLabel!.tintColor
        }
        
        tableView.beginUpdates()
        
        tableView.insertRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
        tableView.reloadRowsAtIndexPaths([indexPathDateRow], withRowAnimation: .None)

        tableView.endUpdates()
        
        datePicker.setDate(dueDate, animated: false)
    }
    
    func hideDatePicker(){
        
        if datePickerVisible{
        
            datePickerVisible = false
            
            let indexPathDatePicker = NSIndexPath(forRow: 2, inSection: 1)
            let indexPathDateRow = NSIndexPath(forRow: 1, inSection: 1)
            
            if let cell = tableView.cellForRowAtIndexPath(indexPathDateRow){
                cell.detailTextLabel!.textColor = cell.detailTextLabel!.tintColor
            }
            
            tableView.beginUpdates()
            
            tableView.deleteRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
            tableView.reloadRowsAtIndexPaths([indexPathDateRow], withRowAnimation: .None)
            
            tableView.endUpdates()

            
        }
    
    }
    
    func updateDueDate(){
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        dueDateLabel.text = formatter.stringFromDate(dueDate)
        
    }
    
    // MARK: - TextField delegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let oldText : NSString = textField.text!
        let newText : NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
        
        doneBarButton.enabled = (newText.length > 0)
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        hideDatePicker()
    }
    
    
}
