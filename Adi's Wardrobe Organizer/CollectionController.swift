//
//  CollectionController.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 4/21/16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit

class CollectionController: UITableViewController {
    var season = ""
    var clothesCollection = ""
    var selectedCellIndexPath: IndexPath?
    var currentDefaultImage: UIImageView!
    
    @IBOutlet var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
        
        let isAccessedFromNewCombination = Constants.defaults.bool(forKey: "sholdOpenNewCombination")
        if (isAccessedFromNewCombination) {
            self.tabBarController?.tabBar.isHidden = true
        }
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorColor = UIColor(red: 100.0/255.0, green: 150.0/255.0, blue: 240.0/255.0, alpha: 0.8)
        tableView.separatorEffect = .none
        tableView.separatorStyle = .none
        
        // Remove the separators of the empty rows
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! SeasonCollectionCell
        currentDefaultImage = cell.collectionImageView
        
        // This section is for the enlargement of the row
        if selectedCellIndexPath != nil && selectedCellIndexPath == indexPath {
            selectedCellIndexPath = nil
            cell.browseCollection.isHidden = true
            cell.blurEffectView.isHidden = true
        } else {
            selectedCellIndexPath = indexPath
        }
        
        if selectedCellIndexPath != nil {
            // This ensures, that the cell is fully visible once expanded
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        }
        
        // hide the button from every other cell that is present
        var visiableCells = self.tableView.indexPathsForVisibleRows
        let indexOfCurrentCell = visiableCells?.index(of: indexPath)
        visiableCells?.remove(at: indexOfCurrentCell!)
        
        for index in visiableCells! {
            let notClickedCell = tableView.cellForRow(at: index) as! SeasonCollectionCell
            notClickedCell.browseCollection.isHidden = true
            notClickedCell.blurEffectView.isHidden = true
        }
        
        // The beginUpdates() and endUpdates() calls are giving you an animated height change.
        tableView.beginUpdates()
        tableView.endUpdates()

        self.clothesCollection = cell.collectionType.text!
        
        // saving the current cloth type for the core data
        saveCurrentClothType(indexPath)
        
        // Gets to the next View, if the cell is clicked for the second time
        if selectedCellIndexPath == nil {
            self.performSegue(withIdentifier: "showClothesCollection", sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SeasonCollectionCell {
            
            UIView.animate(withDuration: 0.4, animations: {
                cell.browseCollection.isHidden = true
                cell.blurEffectView.isHidden = true
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SeasonCollectionCell
        
        if selectedCellIndexPath != nil && selectedCellIndexPath == indexPath {
           // cell.browseCollection.isHidden = false
            //cell.blurEffectView.isHidden = false
        } else {
            cell.browseCollection.isHidden = true
            cell.blurEffectView.isHidden = true
        }
        
        // TODO move this as array in constant struct and create method
        
        // Set the cell image and name
        let (collectionType,imageName) = getCollectionType(row: indexPath.row)
        cell.collectionType.text = collectionType
        cell.collectionImageView.image = imageName
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section:
        Int) -> Int {
        return 17
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        // Set the cell height
        if selectedCellIndexPath == indexPath{
            return Constants.collectionControllerSelectedCellHeight
        }
        
        return Constants.collectionControllerDeselectedCellHeight
    }
    
    // MARK: Additional Methods
    // Function for getting the collection type (String) and the image of the corresponding collection (UIImage)
    // Param: row: Integer
    func getCollectionType(row: Int) -> (String, UIImage) {
        return (Constants.collectionControllerCollectionTypes[row], Constants.collectionControllerCollectionImages[row])
    }

    // Function for setting the current navigation title, to the corresponded season, based on the clicked cell in the Seasons Controller
    func setTitle() -> Void {
        let season = Constants.defaults.value(forKey: "currentSeason")
        
        switch season as! String {
        case "spring":
            self.navigationItem.title = Constants.collectionControllerNavigationTitles[0]
            
        case "summer":
            self.navigationItem.title = Constants.collectionControllerNavigationTitles[1]
            
        case "fall":
            self.navigationItem.title = Constants.collectionControllerNavigationTitles[2]
            
        case "winter":
            self.navigationItem.title = Constants.collectionControllerNavigationTitles[3]
            
        default:
            break
        }
    }
    
    // Function for setting the current cloth type in UserDefaults, so when we save an image in the DB, it knows where to save it
    func saveCurrentClothType(_ indexPath: IndexPath) {
        Constants.defaults.setValue(Constants.collectionControllerNSUserDefaultsTitles[indexPath.row], forKey: "currentClothType")
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        //navigationController?.popViewController(animated: true)
        Constants.defaults.set(false, forKey: "sholdOpenNewCombination")
        
        
        // TODO: get all the clothes from the combinations which are selected from the core data
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showClothesCollection"{
            let destinationViewController = segue.destination as! ClothesCollectionController
            
            destinationViewController.defaultImage = self.currentDefaultImage
            destinationViewController.clothesCollectionType = self.clothesCollection
        }
    }
    
}
