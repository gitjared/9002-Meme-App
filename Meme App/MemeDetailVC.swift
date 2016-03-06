//
//  MemeDetailVC.swift
//  Meme App
//
//  Created by Jared Wong on 2/25/16.
//  Copyright © 2016 Apparatus Unlimited. All rights reserved.
//

import Foundation
import UIKit

class MemeDetailVC: UIViewController {
    // ImageView that will contain memed image
    @IBOutlet weak var imageView: UIImageView!
    
    var meme: Meme?
    
    //Mark: View life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //unwrap meme and set imageView to the memed image
        if let meme = meme {
            imageView.image = meme.memedImage
        }
    }

    //Set creatememe when opening the meme editor
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMemeCreator" {
            let editVC = segue.destinationViewController as! MemeCreatorVC
            editVC.editMeme = meme
            editVC.userIsEditing = true
        }
    }
}