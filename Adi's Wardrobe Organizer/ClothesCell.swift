//
//  ClothesCell.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 4/25/16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit

// A protocol that the TableViewCell uses to inform its delegate of state change
protocol ClothCellDelegate{
    func deleteClothImage(_ item: ClothMO)
}

class ClothesCell: UITableViewCell {
    @IBOutlet weak var clothImageView: UIImageView!
    @IBOutlet weak var managePhoto: UIButton!
    @IBOutlet weak var deletePhoto: UIButton!
    @IBOutlet var markedRow: UIImageView!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    
    
    var delegate: ClothCellDelegate?
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    var clothToDelete: ClothMO?
    
    
    func activateShit(){
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(ClothesCell.handlePan(_:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }
    
    //MARK: - horizontal pan gesture methods
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        // 1
        if recognizer.state == .began {
            // when the gesture begins, record the current center location
            originalCenter = center
        }
        // 2
        if recognizer.state == .changed {
            let translation = recognizer.translation(in: self)
            center = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y)
            // has the user dragged the item far enough to initiate a delete/complete?
            deleteOnDragRelease = frame.origin.x < -frame.size.width/3
           
        }
        // 3
        if recognizer.state == .ended {
            // the frame this cell had before user dragged it
            let originalFrame = CGRect(x: 0, y: frame.origin.y,
                                       width: bounds.size.width, height: bounds.size.height)
            if !deleteOnDragRelease {
                // if the item is not being deleted, snap back to the original location
                UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
            }
            
            if deleteOnDragRelease {
                
                if delegate != nil {
                    // notify the delegate that this item should be deleted
                    delegate!.deleteClothImage(clothToDelete!)
                }
            }
        }
    }
    
    
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
}



