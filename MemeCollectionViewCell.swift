//
//  MemeCollectionViewCell.swift
//  Meme App
//
//  Created by Jared Wong on 2/23/16.
//  Copyright © 2016 Apparatus Unlimited. All rights reserved.
//

import Foundation
import UIKit

class MemeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var memeImage: UIImageView!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    //Show or hide the checkmark if cell is selected 
    func isSelected(selected: Bool) {
        if selected {
            selectedImageView.hidden = false
        } else {
            selectedImageView.hidden = true
        }
    }
}