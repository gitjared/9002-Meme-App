//
//  MemeCollectionVC.swift
//  Meme App
//
//  Created by Jared Wong on 2/23/16.
//  Copyright © 2016 Apparatus Unlimited. All rights reserved.
//

import UIKit

class MemeCollectionVC: UICollectionViewController {
    //Remember to set the class in storyboard for the collection view class to MemeCollectionVC
    
    @IBOutlet weak var memeCollectionView: UICollectionView!
    
    let minimumSpacing: CGFloat = 5.0
    let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    
    //sent Meme list
    var selectedMemes = [NSIndexPath]()
    var editButton: UIBarButtonItem!
    var addDeleteButton: UIBarButtonItem!
    var editingMode = false
    
    //LifecycleMethods
    override func viewDidLoad() {
        super.viewDidLoad()
    //multiple cell selections
        memeCollectionView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        defaultUIState()
    }
    
    //Default UI state
    func defaultUIState() {
    //Initialize add and edit buttons
        editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "didTapEdit:")
        addDeleteButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "launchCreator:")
        
        navigationItem.rightBarButtonItem = addDeleteButton
        navigationItem.leftBarButtonItem = editButton
        navigationItem.leftBarButtonItem?.enabled = MemeArray.allMemes.count > 0
        
        //Cycle through each cell and index in selectMemes array to deselect and reinitialize
        for index in selectedMemes {
            memeCollectionView.deselectItemAtIndexPath(index, animated: true)
            let cell = memeCollectionView.cellForItemAtIndexPath(index) as! MemeCollectionViewCell
            cell.isSelected(false)
        }
        
        //Remove all items from the selected Memes array and reset layout
        selectedMemes.removeAll()
        memeCollectionView.reloadData()
        
        editingMode = false
        
        //If there are no saved memes, present the meme creator
        if MemeArray.allMemes.count == 0 {
            editButton.enabled = false
            launchCreator(self)
        } else {
            editButton.enabled = true
        }
    }
    
//Editing for collection view multi Selection
    func didTapEdit(sender: UIBarButtonItem?) {
        editingMode = !editingMode
        
        //If editing change edit button to done and add button to trash
        if editingMode {
            
            editButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "didTapEdit:")
            navigationItem.leftBarButtonItem = editButton
            
            //Set right bar button and diesable it until item is selected
            addDeleteButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "alertBeforeDeleting:")
            navigationItem.rightBarButtonItem = addDeleteButton
            navigationItem.rightBarButtonItem?.enabled = false
        } else {
            //if not editing, reinitialize ui to base layout
            defaultUIState()
        }
    }
    
    // Launch Meme Creator with cancel/share button enabled
    func launchCreator(sender: AnyObject){
        let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("MemeCreator")
        let createMemeVC = object as! MemeCreatorVC
        
        presentViewController(createMemeVC, animated: true, completion: {
            createMemeVC.cancelButton.enabled = true
            createMemeVC.actionButton.enabled = true
        })
    }
}

    //Mark: Delete Memes Ext
extension MemeCollectionVC {
    
    //Delete selected Memes when prompted
    func deleteSelectedMemes(sender: AnyObject) {
    if selectedMemes.count > 0 {
        
    //Sort the array of selected Memes for deletion
        let sortedMemes = selectedMemes.sort {
            return $0.item > $1.item
        }
    //Remove the memes by cycling through sorted array then reconfigure UI
        for index in sortedMemes {
            MemeArray.remove(atIndex: index.item)
        }
        defaultUIState()
        }
    }
    
   //Alert the user before deletion, giving an opportunity to cancel
    func alertBeforeDeleting(sender: AnyObject) {
        let ac = UIAlertController(title: "Delete Selected Memes", message: "Are you sure you want to delete selected Memes?", preferredStyle: .Alert)
    
    //Configure alert actions
        let deleteAction = UIAlertAction(title: "Delete Selected", style: .Destructive, handler: {
            action in self .deleteSelectedMemes(sender)
        })
        let stopAction = UIAlertAction(title: "Keep Them", style: .Default, handler: {
            action in self .defaultUIState()
        })
        
    //Add actions to present alert
        ac.addAction(deleteAction)
        ac.addAction(stopAction)
        presentViewController(ac, animated: true, completion: nil)
    }
}

//MARK: CollectionView Delegate and DataSource Methods
extension MemeCollectionVC {
    
    //Reture number of items in MemesArray
   override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MemeArray.allMemes.count
    }
    
    //Configure collection view cells for each Meme
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        
        let meme = MemeArray.allMemes[indexPath.item]
        cell.memeImage?.image = meme.memedImage
        
        return cell
    }
    
    //Define behavior when a cell is selected
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        //If editing, select/add array of indexes
        if editingMode {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MemeCollectionViewCell
            
            selectedMemes.append(indexPath)
            cell.isSelected(true)
            addDeleteButton.enabled = true
            
        } else {
            
        //If not, pass data from selected row to detailview and present it
            let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("MemeDetail")
            let detailVC = object as! MemeDetailVC
            
            detailVC.meme = MemeArray.allMemes[indexPath.item]
            navigationController!.pushViewController(detailVC, animated: true)
    }
}
    //Define cell deselect
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        //Enable delete button if cell is selected, disable if not
        navigationItem.rightBarButtonItem?.enabled = (selectedMemes.count > 0)
        
        //If editing, deselect and romve from array of selected memes
        if editingMode {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MemeCollectionViewCell
            selectedMemes.removeAtIndex(indexPath.item)
            cell.isSelected(false)
        }
    }

}
