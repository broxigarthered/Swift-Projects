//
//  CombinationsController.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 5/19/16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit
import CoreData

class CombinationsController: UITableViewController,
NSFetchedResultsControllerDelegate, CombinationCellDelegate {
    
    private let deselectedCellHeight: CGFloat = 200.0
    private let selectedCellHeight: CGFloat = 300.0
    
    var selectedCellIndexPath: IndexPath?
    var currentRow: Int?
    var isCellClicked = false
    
    // Core data
    var fetchResultConroller: NSFetchedResultsController<NSFetchRequestResult>!
    var combinations: [CombinationMO] = []
    var combinationImageRelation: CombinationImageMO!
    var currentCombination: CombinationMO!
    var currentlyClickedCombination: CombinationMO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Combination")
        let sortDescriptor = NSSortDescriptor(key: "rating", ascending: false)
        
        let currentSeason = UserDefaults.standard.string(forKey: "currentSeason")
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "season == %@", currentSeason!)
        
        // todo: add predicates to fish the combinations only for the current season
        
        if let moc = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
            fetchResultConroller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
            
            fetchResultConroller.delegate = self
            
            do {
                try fetchResultConroller.performFetch()
                self.combinations = fetchResultConroller.fetchedObjects as! [CombinationMO]
            } catch {
                print(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as!
        CombinationsCell
        
        cell.cellStarRating.settings.updateOnTouch = false
        // change the color cell.cellStarRating.settings.filledColor = UIColor.blueColor()
        
        cell.tagOne.text = ""
        cell.tagTwo.text = ""
        //cell.browseCombination.isHidden = true
        
        if selectedCellIndexPath != nil && selectedCellIndexPath == indexPath {
            cell.tagOne.isHidden = false
            cell.tagTwo.isHidden = false
            cell.browseCombination.isHidden = false
        } else {
            cell.tagOne.isHidden = true
            cell.tagTwo.isHidden = true
            cell.browseCombination.isHidden = true
        }
        
        // First figure out how many sections there are
        let lastSectionIndex = self.tableView.numberOfSections - 1
        
        // Then grab the number of rows in the last section
        let lastRowIndex = self.tableView!.numberOfRows(inSection: lastSectionIndex) - 1
      
        // if the new combination cell -> hide everything else
        if lastRowIndex == indexPath.row {
            cell.combinationsImage.isHidden = true
            cell.cellStarRating.isHidden = true
            cell.combinationsMainTag.isHidden = true
            
            cell.newCombinationButton.isHidden = false
            
        } else {
            // edit the cell entirely
            cell.combinationsImage.isHidden = false
            cell.cellStarRating.isHidden = false
            cell.combinationsMainTag.isHidden = false
            cell.newCombinationButton.isHidden = true
            
            currentCombination = self.combinations[indexPath.row]
            cell.cellStarRating.rating = currentCombination.rating
            
            cell.combinationsMainTag.text = currentCombination.tags[0]
            
            
            if currentCombination.tags.count > 1 {
                cell.tagOne.text = currentCombination.tags[1]
            }
            
            if currentCombination.tags.count > 2 {
                cell.tagTwo.text =  currentCombination.tags[2]
            }
            
         let imageRelation = currentCombination.mutableSetValue(forKey: "images").allObjects
            
            //TODO: set images to switch with one another
            
            let image = imageRelation[0]

            let imageToSet = image as! CombinationImageMO
            
            cell.combinationsImage.image = UIImage(data: imageToSet.image! as Data)
            
            // this is for the "swipe to delete function"
            cell.activateShit()
            cell.selectionStyle = .none
            cell.delegate = self
            cell.combinationToDelete = self.combinations[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let cell = tableView.cellForRow(at: indexPath) as! CombinationsCell
        self.currentRow = indexPath.row
        
        // height regulator
        if selectedCellIndexPath != nil && selectedCellIndexPath == indexPath{
            selectedCellIndexPath = nil
            cell.tagOne.isHidden = true
            cell.tagTwo.isHidden = true
            cell.browseCombination.isHidden = true
        } else {
            selectedCellIndexPath = indexPath
            cell.tagOne.isHidden = false
            cell.tagTwo.isHidden = false
            cell.browseCombination.isHidden = false
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
        if selectedCellIndexPath != nil {
            // This ensures, that the cell is fully visible once expanded
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        }
        
        // hide the button from every other cell that is present
        var visiableCells = self.tableView.indexPathsForVisibleRows
        let indexOfCurrentCell = visiableCells?.index(of: indexPath)
        visiableCells?.remove(at: indexOfCurrentCell!)
        
        for index in visiableCells! {
            let notClickedCell = tableView.cellForRow(at: index) as! CombinationsCell
            notClickedCell.browseCombination.isHidden = true
            notClickedCell.tagOne.isHidden = true
            notClickedCell.tagTwo.isHidden = true
        }
        
        self.currentlyClickedCombination = self.combinations[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CombinationsCell{
            UIView.animate(withDuration: 0.4, animations: {
                cell.tagOne.isHidden = true
                cell.tagTwo.isHidden = true
                cell.browseCombination.isHidden = true
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.combinations.count + 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if selectedCellIndexPath == indexPath{
            return selectedCellHeight
        }
        
        return deselectedCellHeight
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let defaults = UserDefaults.standard
        
        if segue.identifier == "manageCombination" {
            
            let destinationController = segue.destination as! NewCombination
            
            // works
            let tagsToModify = self.currentlyClickedCombination.tags
            
            destinationController.currentCombinationToModify = currentlyClickedCombination
            
            defaults.set(true, forKey: "shouldLoadCombination")
            defaults.setValue(tagsToModify, forKey: "tagsToModify")
            defaults.set(self.currentRow!, forKey: "currentRowToModify")
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
        
        else{
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            defaults.set(false, forKey: "shouldLoadCombination")
        }
    }
    
    // MARK: Segues manager this is being returned when pressed x
    @IBAction func unwindToCombinations(_ segue: UIStoryboardSegue){
   
        
    }
    
    // MARK: Managing core data
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let _newIndexPath = newIndexPath{
                tableView.insertRows(at: [_newIndexPath], with: .fade)
            }
        case .delete:
            if let _indexPath = indexPath{
                tableView.deleteRows(at: [_indexPath], with: .fade)
            }
        case .update:
            if let _indexPath = indexPath{
                tableView.reloadRows(at: [_indexPath], with: .fade)
            }
        default:
            tableView.reloadData()
        }
        
        combinations = controller.fetchedObjects as! [CombinationMO]
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
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
    
    func deleteItem(_ item: CombinationMO) {
        if let moc = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext{
            
            tableView.beginUpdates()
            moc.delete(item)
            
            do{
                try moc.save()
            } catch {
                print(error)
            }
            
            tableView.endUpdates()
        }
    }
    
    static func instantiate() -> CombinationsController
    {
        return UIStoryboard(name: "testvam", bundle: nil).instantiateViewController(withIdentifier: "testvam") as! CombinationsController
    }
}
