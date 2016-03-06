//
//  MemeTableVC.swift
//  Meme App
//
//  Created by Jared Wong on 2/23/16.
//  Copyright © 2016 Apparatus Unlimited. All rights reserved.
//

import Foundation
import UIKit

//Sent Memes
class MemeTableVC: UITableViewController {
    
    var creatorNotPresented = true
    var memeIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup Edit Button in NavBar
        navigationItem.leftBarButtonItem = editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem?.enabled = MemeArray.count() > 0
        tableView!.reloadData()
    }
    
    //Mark: Actions
    @IBAction func createMeme(sender: AnyObject) {
        //presents memeEditor in Creation mode
        let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("MemeCreator")
        let newMeme = object as! MemeCreatorVC
        presentViewController(newMeme, animated: true, completion: {
            newMeme.cancelButton.enabled = true
        })
    }
    
    @IBAction func unwindForSegue(unwindSegue: UIStoryboardSegue) {
        tableView!.reloadData()
    }
    
    //Mark: Utilities
    
    //Removes the meme from model and table
    func removeMemeAtIndexPath(indexPath: NSIndexPath) {
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
    
    //Delegate Methods for editing tableView
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    //Set editing and configure UI
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if !tableView.editing {
            tableView.setEditing(editing, animated: animated)
        }
    }
}

// MARK: Extend MemeTableVC for UITableViewDataSource and delegate methods
extension MemeTableVC {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //Set number of rows in section based on count of Memes
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MemeArray.count()
    }
    
    //Configure table view Cells
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableCell", forIndexPath: indexPath)
        
        let meme = MemeArray.allMemes[indexPath.row]
        cell.imageView!.image = meme.image
        cell.textLabel!.text = "\(meme.top) \(meme.bottom)"
        
        return cell
    }
    
    //Add tableView editing
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //Delete Meme
        switch editingStyle {
        case .Delete:
            
            MemeArray.remove(atIndex: indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            //If no saved Memes present Meme Creator
            if MemeArray.count() == 0 {
                let object: AnyObject =
                storyboard!.instantiateViewControllerWithIdentifier("MemeCreator")
                let memeCreator = object as! MemeCreatorVC
                presentViewController(memeCreator, animated: false, completion: nil)
            }
        default:
            return
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //If not editing perform segue defined in Storyboard
        if !tableView.editing {
            let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("MemeDetail")
            let detailVC = object as! MemeDetailVC
            
            //Pass data from selected row to detail view and present it
            detailVC.meme = MemeArray.allMemes[indexPath.row]
            navigationController!.pushViewController(detailVC, animated: true)
        }
    }
}
