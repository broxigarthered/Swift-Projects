//
//  CombinationsCell.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 5/19/16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit

protocol CombinationCellDelegate
{
    func deleteItem(_ item: CombinationMO)
}

class CombinationsCell: UITableViewCell {
    
    @IBOutlet weak var combinationsImage: UIImageView!
    
    @IBOutlet weak var combinationsMainTag: UILabel!
    @IBOutlet weak var tagOne: UILabel!
    @IBOutlet weak var tagTwo: UILabel!
    
    @IBOutlet weak var browseCombination: UIButton!
    @IBOutlet weak var newCombinationButton: UIButton!
    
    @IBOutlet weak var cellStarRating: CosmosView!
    
    var delegate: CombinationCellDelegate?
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    var combinationToDelete: CombinationMO?
    
    func activateShit(){
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(CombinationsCell.handlePan(_:)))
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
                    delegate!.deleteItem(combinationToDelete!)
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
