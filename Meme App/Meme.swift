//
//  Meme.swift
//  Meme App
//
//  Created by Jared Wong on 2/17/16.
//  Copyright © 2016 Apparatus Unlimited. All rights reserved.
//

import Foundation
import UIKit

//Setting Meme Elements
struct Meme {
    var top: String!
    var bottom: String!
    var image: UIImage!
    var fontAttributes: FontAttributes!
    
//Meme image built by meme elements
    var memedImage: UIImage!
}

// Add the Equatable Protocol and make equal if the memedImages match
extension Meme: Equatable{}

func ==(lhs: Meme, rhs: Meme) -> Bool {
    return lhs.memedImage == rhs.memedImage
}

//Convenience Methods & variables for updating or altering Array of memes
//MemeCollection
struct MemeArray {
    //Get all meemes from appDelegate
    static var allMemes: [Meme] {
        return memeStorage().memes
}

    //Returen a Meme at given index
    static func getMeme(atIndex index: Int) -> Meme {
        return allMemes[index]
    }
    
    //Find the index of a given Meme
    static func indexOf(meme: Meme) -> Int {
        //If meme is in Array, return first index, or return count of Memes.
        if let index = allMemes.indexOf({$0 == meme}) {
            return Int(index)
        } else {
            print(allMemes.count)
            return allMemes.count
        }
    }
    
    //Add a meme to the last position of the MemeArray
    static func add(meme: Meme){
        memeStorage().memes.append(meme)
    }
    
    //Update Meme with a new Meme at given index
    static func update(atIndex index: Int, withMeme meme: Meme) {
        memeStorage().memes[index] = meme
    }
    
    //Remove a Meme at given index
    static func remove(atIndex index: Int) {
        memeStorage().memes.removeAtIndex(index)
    }
    
    //Get count of all Memes in Meme Array
    static func count() -> Int {
        return memeStorage().memes.count
    }
    
    //Meme storage location in AppDelegate
    //GetMemeStorage
    static func memeStorage() -> AppDelegate {
        let object = UIApplication.sharedApplication().delegate
    return object as! AppDelegate
    }
}

//Stores font attributes for meme
struct FontAttributes {
    var fontSize: CGFloat = 40.0
    var fontName = "HelveticaNeue-CondensedBlack"
    var fontColor = UIColor.whiteColor()
    var borderColor = UIColor.blackColor()
}


