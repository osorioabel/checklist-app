//
//  IconPickerViewController.swift
//  checklist-app
//
//  Created by Abel Osorio on 2/16/16.
//  Copyright © 2016 Abel Osorio. All rights reserved.
//

import UIKit

protocol IconPickerViewControllerDelegate : class{
    
    func iconPicker(picker: IconPickerViewController, didPickIcon iconName : String)

}

class IconPickerViewController: UITableViewController {
    
    weak var delegate : IconPickerViewControllerDelegate?
    
    let icons = [ "No Icon","Appointments", "Birthdays", "Chores", "Drinks", "Folder", "Groceries", "Inbox", "Photos", "Trips" ]
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Choose Icon"
    }
    
    
    // MARK: - TableView DataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return icons.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("IconCell", forIndexPath: indexPath)
        
        let iconName = icons[indexPath.row]
        cell.textLabel!.text = iconName
        cell.imageView!.image = UIImage(named: iconName)
        return cell
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let delegate = delegate {
            let iconName = icons[indexPath.row]
            delegate.iconPicker(self, didPickIcon: iconName)
        }
    }
    
    
}