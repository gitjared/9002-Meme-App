//
//  ViewController.swift
//  Meme App
//
//  Created by Jared Wong on 2/16/16.
//  Copyright © 2016 Apparatus Unlimited. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    var meme : Meme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField("TOP", textField: topTextField)
        setupTextField("BOTTOM", textField: bottomTextField)
        actionButton.enabled = false
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard:")
        view.addGestureRecognizer(tap)
        
        if let existingMeme = meme {
            setupTextField(existingMeme.top, textField: topTextField)
            setupTextField(existingMeme.bottom, textField: bottomTextField)
            imageView.image = existingMeme.image
            actionButton.enabled = true
        }else{
            setupTextField("TOP", textField: topTextField)
            setupTextField("BOTTOM", textField: bottomTextField)
            actionButton.enabled = false
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
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
    
    @IBAction func sendMeme(sender: UIBarButtonItem) {
        let memedImage = generateMemedImage()
        
        let activity = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activity.completionWithItemsHandler = { (activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError: NSError?) -> Void in
            if completed {
                self.saveMeme(memedImage)
                activity.dismissViewControllerAnimated(true, completion: nil)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        presentViewController(activity, animated: true, completion: nil)
    }
    
    @IBAction func cancelMeme(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveMeme(memedImage: UIImage) {
        let meme = Meme(top: topTextField.text!, bottom: bottomTextField.text!, image: imageView.image!, memedImage: memedImage)
        meme
    }
    
    func generateMemedImage() -> UIImage {
        hideItems(true)
        
        //Render view of an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //TODO: Show toolbar and navbar
        hideItems(false)
        
        return memedImage
    }
    
    private func hideItems(hide: Bool){
        navigationController?.setNavigationBarHidden(hide, animated: false)
        navBar.hidden = hide
        toolBar.hidden = hide
    }
    
    func setupTextField(string: String, textField: UITextField) {
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -3.6
        ]
        
        let attributedString = NSAttributedString(string: string, attributes:  memeTextAttributes)
        textField.attributedText = attributedString
        textField.defaultTextAttributes = memeTextAttributes
        textField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        textField.textAlignment = .Center
        textField.textColor = UIColor.whiteColor()
        textField.delegate = self
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