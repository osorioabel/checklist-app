//
//  AllListViewController.swift
//  checklist-app
//
//  Created by Abel Osorio on 2/16/16.
//  Copyright © 2016 Abel Osorio. All rights reserved.
//

import UIKit

class AllListViewController: UITableViewController,ListDetailViewControllerDelegate,UINavigationControllerDelegate {
    
    var dataModel: DataModel!
    
    
    // MARK: - LifeCycle
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        navigationController?.delegate = self
        let index = dataModel.indexOfSelectedChecklist
        
        if index >= 0 && index < dataModel.lists.count{
            
            let checklist = dataModel.lists[index]
            performSegueWithIdentifier("ShowChecklist", sender: checklist)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - UITableView DataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataModel.lists.count
    }
    
    override func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = cellForTableView(tableView)
        
        let checklist = dataModel.lists[indexPath.row]
        
        cell.textLabel!.text = checklist.name
        
        cell.accessoryType = .DetailDisclosureButton
        
        let count = checklist.countUncheckedItems()
        if checklist.items.count == 0 {
            cell.detailTextLabel!.text = "(No Items)"
        } else if count == 0 {
            cell.detailTextLabel!.text = "All Done!"
        } else {
            cell.detailTextLabel!.text = "\(count) Remaining"
        }
        
        cell.imageView!.image = UIImage(named: checklist.iconName)
        
        return cell
    }
    
    func cellForTableView(tableView: UITableView) -> UITableViewCell {
        
        let cellIdentifier = "Cell"
        if let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) {
            return cell
        } else {
            return UITableViewCell(style: .Subtitle,reuseIdentifier: cellIdentifier)
        }
        
    }
    
    // MARK: - UITableView Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        dataModel.indexOfSelectedChecklist = indexPath.row
        
        let checklist = dataModel.lists[indexPath.row]
        performSegueWithIdentifier("ShowChecklist", sender: checklist)
    }
    
    override func tableView(tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,forRowAtIndexPath indexPath: NSIndexPath) {
        dataModel.lists.removeAtIndex(indexPath.row)
        let indexPaths = [indexPath]
        tableView.deleteRowsAtIndexPaths(indexPaths,withRowAnimation: .Automatic)
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
            
            let navigationController = storyboard!.instantiateViewControllerWithIdentifier("ListDetailNavigationController") as! UINavigationController
            let controller = navigationController.topViewController as! ListDetailViewController
            controller.delegate = self
            let checklist = dataModel.lists[indexPath.row]
            controller.checklistToEdit = checklist
            presentViewController(navigationController, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Navegation
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
                
                if viewController === self{
        
                    dataModel.indexOfSelectedChecklist = -1
                }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if segue.identifier == "ShowChecklist"{
        
        let controller = segue.destinationViewController as! CheckListTableViewController
            controller.checklist = sender as! Checklist
    }else if segue.identifier == "AddChecklist"{
        
        let navigationController = segue.destinationViewController as! UINavigationController
        let controller = navigationController.topViewController as! ListDetailViewController
        controller.delegate = self
        controller.checklistToEdit = nil
        
    }else if segue.identifier == "EditChecklist"{
        
        let navigationController = segue.destinationViewController as! UINavigationController
        let controller = navigationController.topViewController as! ListDetailViewController
        controller.delegate = self
        if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell){
            controller.checklistToEdit = dataModel.lists[indexPath.row]
        }
        }
    }
    
    
    // MARK: - ListDetailViewController Delegate
    
    
    func listDetailViewControllerDidCancel(controller: ListDetailViewController) {
            dismissViewControllerAnimated(true, completion: nil)
    }
    
    func listDetailViewController(controller: ListDetailViewController, didFinishAddingChecklist checklist: Checklist) {
        
        dataModel.lists.append(checklist)
        dataModel.sortChecklists()
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func listDetailViewController(controller: ListDetailViewController,didFinishEditingChecklist checklist: Checklist) {
        
        dataModel.sortChecklists()
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }    
    
}

