//
//  MemeCreatorVC.swift
//  Meme App
//
//  Created by Jared Wong on 2/16/16.
//  Copyright © 2016 Apparatus Unlimited. All rights reserved.
//

import Foundation
import UIKit

class MemeCreatorVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    //Existing Meme reference.  Used only when editor will edit existing meme
    var userIsEditing = false
    var editMeme : Meme?
    var memedImage: UIImage!
    var selectedTextField: UITextField?
    var fontAttributes: FontAttributes!
    
    //Mark: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard:")
        view.addGestureRecognizer(tap)
       defaultUIState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        //Disable camera button if no camera
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        unsubscribeFromKeyboardNotifications()
    }
    
    //Hide status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
   // Set the state of userInterface to editing or creating. If you are editing a Meme, then configure and set the approriate fields and configure default state for textFields

    func defaultUIState() {
        let textFieldArray = [topTextField, bottomTextField]
        
        //Set the meme to edit if there is an editMeme
        if let editMeme = editMeme {
            navBar.topItem?.title = "Edit your Meme"
            
            topTextField.text = editMeme.top
            bottomTextField.text = editMeme.bottom
            imageView.image = editMeme.image
            userIsEditing = true
            fontAttributes = editMeme.fontAttributes
            configureTextFields(textFieldArray)
            
        } else {
            //Set the title if creating a Meme
            navBar.topItem?.title = "Create a Meme"
            fontAttributes = FontAttributes()
            configureTextFields(textFieldArray)
        }
        //Hide or show buttons based on whether the user is editing
        actionButton.enabled = userIsEditing
        cancelButton.enabled = userIsEditing
    }
    
    //Pass array of text fields and set default attributes
    func configureTextFields(textFields: [UITextField!]){
        for textField in textFields{
            textField.delegate = self
            
            //Define default attributes
            let memeTextAttributes = [
                NSStrokeColorAttributeName: UIColor.blackColor(),
                
                NSForegroundColorAttributeName: fontAttributes.fontColor,
                NSFontAttributeName: UIFont(name: fontAttributes.fontName, size: fontAttributes.fontSize)!,
                
                NSStrokeWidthAttributeName: -4.0
                ]
                textField.defaultTextAttributes = memeTextAttributes
                textField.textAlignment = .Center
        }
    }

    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder(){
            view.frame.origin.y = getKeyboardHeight(notification) * -1
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        if bottomTextField.isFirstResponder(){
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue //of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM"{
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func dismissKeyboard(sender: AnyObject) {
        topTextField.resignFirstResponder()
        bottomTextField.resignFirstResponder()
        view.endEditing(true)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = originalImage
            actionButton.enabled = true
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func cancelMeme(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveMeme(sender: AnyObject) {
        //Check if fields are filled
        if fieldCheck() {
            
            //Initialize new meme to save or update
            let memeCreated = Meme(top: topTextField.text, bottom: bottomTextField.text, image: imageView.image, fontAttributes: fontAttributes, memedImage: generateMemedImage())
            
            //If you are editing, updating, new, savie it.
            if userIsEditing {
                if let editMeme = editMeme {
                  MemeArray.update(atIndex: MemeArray.indexOf(editMeme), withMeme: memeCreated)
                }
                //move to table view once meme is updated
                performSegueWithIdentifier("unwindMemeCreator", sender: sender)
        } else {
            //Add Meme if user is not editing
            MemeArray.add(memeCreated)
            dismissViewControllerAnimated(true, completion: nil)
        }
    } else {
    //Alert user if something is missing and you can't save
            let okAction = UIAlertAction(title: "Save", style: .Default, handler: { Void in
                self.topTextField.text = ""
                self.bottomTextField.text = ""
                return
            })
            let editAction = UIAlertAction(title: "Edit", style: .Default, handler: nil)
            
            alertUser(message: "Your meme is missing something.", actions: [okAction, editAction])
        }
    }
    

    //Alert user if somethings missing before saving
    func alertUser(title: String! = "Title", message: String?, actions: [UIAlertAction]) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        for action in actions {
            ac.addAction(action)
        }
        presentViewController(ac, animated: true, completion: nil)
    }
    
    //Clear view if user presses cancel
    func clearView() {
    imageView.image = nil
    topTextField.text = nil
    bottomTextField.text = nil
    }

    func presentMemeTableView(){
        let memeTableView = storyboard!.instantiateViewControllerWithIdentifier("MemeTableView") as! MemeTableVC
        presentViewController(memeTableView, animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        hideItems(true)
        
        //Render view of an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //TODO: Show toolbar and navbar
        hideItems(false)
        
        return memedImage
    }
    
    //Make sure fields are filled
    func fieldCheck() -> Bool {
        if topTextField.text == nil || bottomTextField.text == nil || imageView.image == nil {
            return false
        }else{
            return true
        }
    }
    
    private func hideItems(hide: Bool){
        navigationController?.setNavigationBarHidden(hide, animated: false)
        navBar.hidden = hide
        toolBar.hidden = hide
    }
    
    //Present ActivityViewController to share meme
    @IBAction func sendMeme(sender: UIBarButtonItem) {
        let ac = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        ac.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.saveMeme(self)
            }
        }
        presentViewController(ac, animated: true, completion: nil)
    }
    
    //Clear view, if no other memes and diesmiss
    @IBAction func didTapCancel(sender: UIBarButtonItem) {
        if MemeArray.allMemes.count == 0 {
            clearView()
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func pickAnImageFromLibrary(sender: AnyObject) {
        presentImagePickerOfType(.PhotoLibrary)
    }
    
    @IBAction func takeAPicture(sender: AnyObject){
        presentImagePickerOfType(.Camera)
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    func presentImagePickerOfType(sourceType: UIImagePickerControllerSourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        presentViewController(imagePicker, animated: true, completion: nil)
    }
}