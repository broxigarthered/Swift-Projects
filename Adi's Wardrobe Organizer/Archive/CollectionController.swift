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
    var selectedCellHeight: CGFloat = 280.0
    var deselectedCellHeight: CGFloat = 150.0
    var currentDefaultImage: UIImageView!
    let defaults = UserDefaults.standard
    
    @IBOutlet var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
        
        let isAccessedFromNewCombination = defaults.bool(forKey: "sholdOpenNewCombination")
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
        
        if selectedCellIndexPath != nil && selectedCellIndexPath == indexPath {
            selectedCellIndexPath = nil
            cell.browseCollection.isHidden = true
        } else {
            selectedCellIndexPath = indexPath
            cell.browseCollection.isHidden = false
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
        }
        
        // The beginUpdates() and endUpdates() calls are giving you an animated height change.
        tableView.beginUpdates()
        tableView.endUpdates()

        self.clothesCollection = cell.collectionType.text!
        
        // saving the current cloth type for the core data
        saveCurrentClothType(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SeasonCollectionCell {
            
            UIView.animate(withDuration: 0.4, animations: {
                cell.browseCollection.isHidden = true
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SeasonCollectionCell
        
        if selectedCellIndexPath != nil && selectedCellIndexPath == indexPath {
            cell.browseCollection.isHidden = false
        } else {
            cell.browseCollection.isHidden = true
        }
        
        switch indexPath.row {
        case 0:
            cell.collectionType.text = "Outwear"
            cell.collectionImageView.image = UIImage(named: "outwear")
            
        case 1:
            cell.collectionType.text = "Blazers"
            cell.collectionImageView.image = UIImage(named: "blazers")
            
        case 2:
            cell.collectionType.text = "Dresses"
            cell.collectionImageView.image = UIImage(named: "dresses")
            
        case 3:
            cell.collectionType.text = "Jumpsuits"
            cell.collectionImageView.image = UIImage(named: "jumpsuits")
            
        case 4:
            cell.collectionType.text = "Tops"
            cell.collectionImageView.image = UIImage(named: "tops")
            
        case 5:
            cell.collectionType.text = "Trousers"
            cell.collectionImageView.image = UIImage(named: "trousers")
            
        case 6:
            cell.collectionType.text = "Jeans"
            cell.collectionImageView.image = UIImage(named: "jeans")
            
        case 7:
            cell.collectionType.text = "Shorts"
            cell.collectionImageView.image = UIImage(named: "shorts")
            
        case 8:
            cell.collectionType.text = "Skirts"
            cell.collectionImageView.image = UIImage(named: "skirts")
            
        case 9:
            cell.collectionType.text = "Knitwear"
            cell.collectionImageView.image = UIImage(named: "knitwear")
            
        case 10:
            cell.collectionType.text = "T-Shirts"
            cell.collectionImageView.image = UIImage(named: "t-shirts")
            
        case 11:
            cell.collectionType.text = "Sweatshirts"
            cell.collectionImageView.image = UIImage(named: "sweatshirts")
            
        case 12:
            cell.collectionType.text = "Beachwear"
            cell.collectionImageView.image = UIImage(named: "beachwear")
            
        case 13:
            cell.collectionType.text = "Gymwear"
            cell.collectionImageView.image = UIImage(named: "gymwear")
            
        case 14:
            cell.collectionType.text = "Shoes"
            cell.collectionImageView.image = UIImage(named: "shoes")
            
        case 15:
            cell.collectionType.text = "Bags"
            cell.collectionImageView.image = UIImage(named: "bags")
            
        case 16:
            cell.collectionType.text = "Accessories"
            cell.collectionImageView.image = UIImage(named: "accessories")
            
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section:
        Int) -> Int {
        return 17
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if selectedCellIndexPath == indexPath{
            
            
            return selectedCellHeight
        }
        
        return deselectedCellHeight
    }
    
    // MARK: Additional Methods
    func setTitle() -> Void {
        let defaults = UserDefaults.standard
        let season = defaults.value(forKey: "currentSeason")
        
        switch season as! String {
        case "spring":
            self.navigationItem.title = "Spring Collection"
            
        case "summer":
            self.navigationItem.title = "Summer Collection"
            
        case "fall":
            self.navigationItem.title = "Fall Collection"
            
        case "winter":
            self.navigationItem.title = "Winter Collection"
            
        default:
            break
        }
    }
    
    func saveCurrentClothType(_ indexPath: IndexPath) {
        
        let defaults = UserDefaults.standard
        
        switch indexPath.row {
        case 0:
            defaults.setValue("outwear", forKey: "currentClothType")
        case 1:
            defaults.setValue("blazers", forKey: "currentClothType")
        case 2:
            defaults.setValue("dresses", forKey: "currentClothType")
        case 3:
            defaults.setValue("jumpsuits", forKey: "currentClothType")
        case 4:
            defaults.setValue("tops", forKey: "currentClothType")
        case 5:
            defaults.setValue("trousers", forKey: "currentClothType")
        case 6:
            defaults.setValue("jeans", forKey: "currentClothType")
        case 7:
            defaults.setValue("shorts", forKey: "currentClothType")
        case 8:
            defaults.setValue("skirts", forKey: "currentClothType")
        case 9:
            defaults.setValue("knitwear", forKey: "currentClothType")
        case 10:
            defaults.setValue("tshirts", forKey: "currentClothType")
        case 11:
            defaults.setValue("sweatshirts", forKey: "currentClothType")
        case 12:
            defaults.setValue("beachwear", forKey: "currentClothType")
        case 13:
            defaults.setValue("gymwear", forKey: "currentClothType")
        case 14:
            defaults.setValue("shoes", forKey: "currentClothType")
        case 15:
            defaults.setValue("bags", forKey: "currentClothType")
        case 16:
            defaults.setValue("accessories", forKey: "currentClothType")
        default:
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        //navigationController?.popViewController(animated: true)
        self.defaults.set(false, forKey: "sholdOpenNewCombination")
        
        
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
