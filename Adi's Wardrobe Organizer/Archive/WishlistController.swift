//
//  WishlistController.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 9/10/16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit

class WishlistController: UITableViewController {
    
    let deselectedCellHeight: CGFloat = 200.0
    let selectedCellHeight: CGFloat = 300.0
    var wishlistItems: [Int] = []
    var currentRow: Int?
    var selectedCellIndexPath: IndexPath?
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WishlistCell
        
        // First figure out how many sections there are
        let lastSectionIndex = self.tableView.numberOfSections - 1
        
        // Then grab the number of rows in the last section
        let lastRowIndex = self.tableView!.numberOfRows(inSection: lastSectionIndex) - 1
        
        if lastRowIndex == indexPath.row{
            cell.newItem.isHidden = false
        } else {
            cell.newItem.isHidden = true
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wishlistItems.count + 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let cell = tableView.cellForRow(at: indexPath) as! WishlistCell
        self.currentRow = indexPath.row
        
        // height regulator
        if selectedCellIndexPath != nil && selectedCellIndexPath == indexPath{
            selectedCellIndexPath = nil
        } else {
            selectedCellIndexPath = indexPath
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
        if selectedCellIndexPath != nil {
            // This ensures, that the cell is fully visible once expanded
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        }
      
        cell.newItem.isHidden = false
        
        if cell.bounds.height == selectedCellHeight{
            UIView.animate(withDuration: 0.4, animations: {
                cell.newItem.isHidden = false
            })
            
        } else {
            cell.newItem.isHidden = true
        }
        
        //        let imageRelation = currentCombination.mutableSetValueForKey("images").allObjects[0] as! CombinationImageMO
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? WishlistCell{
            UIView.animate(withDuration: 0.4, animations: {
                cell.newItem.isHidden = true
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if selectedCellIndexPath == indexPath{
            return selectedCellHeight
        }
        
        return deselectedCellHeight
    }
    
    // MARK: Custom Methods
    func setTitle() -> Void {
        let defaults = UserDefaults.standard
        let season = defaults.value(forKey: "currentSeason")
        
        switch season as! String {
        case "spring":
            self.navigationItem.title = "Spring Combinations"
            
        case "summer":
            self.navigationItem.title = "Summer Combinations"
            
        case "fall":
            self.navigationItem.title = "Fall Combinations"
            
        case "winter":
            self.navigationItem.title = "Winter Combinations"
            
        default:
            break
        }
    }

}
