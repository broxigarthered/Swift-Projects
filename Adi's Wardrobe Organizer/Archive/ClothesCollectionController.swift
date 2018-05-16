import UIKit
import CoreData

class ClothesCollectionController: UITableViewController, ManagePhotoControllerDelegate, NSFetchedResultsControllerDelegate, ClothCellDelegate  {
    
    var clothesCollectionType: String = ""
    
    let defaults = UserDefaults.standard
    
    var temporalImages = NSMutableArray()
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var selectedCellIndexPath: IndexPath?
    var currentIndex: Int = 0
    
    var deselectedCellHeight: CGFloat = 150.0
    var selectedCellHeight: CGFloat = 300.0
    var currentImage: UIImageView!
    var defaultImage: UIImageView!
    
    var images: [UIImage] = [UIImage]()
    var temporalImagesAsArray: [Data] = [Data]()
    
    var fetchResultController: NSFetchedResultsController<NSFetchRequestResult>!
    var clothes: [ClothMO] = []
    var clothImageRelation: ClothImageMO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorColor = UIColor(red: 100.0/255.0, green: 150.0/255.0, blue: 240.0/255.0, alpha: 0.8)
        tableView.separatorEffect = .none
        
        // Remove the separators of the empty rows
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // get the temporal images
        let isAccessedFromNewCombination = self.defaults.bool(forKey: "sholdOpenNewCombination")
        if isAccessedFromNewCombination {
            self.tabBarController?.tabBar.isHidden = true
        }
        
        let currentSeason = defaults.value(forKey: "currentSeason")
        let currentClothType = defaults.value(forKey: "currentClothType")
        
        // fetch the clothes with predicate only from certain season collection, then certain cloth type
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cloth")
        let sortDescriptor = NSSortDescriptor(key: "clothType", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "seasonName == %@", currentSeason as! String)
        fetchRequest.predicate = NSPredicate(format: "clothType == %@", currentClothType as! String)
        
        if let moc = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext{
            
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do{
                try fetchResultController.performFetch()
                self.clothes = fetchResultController.fetchedObjects as! [ClothMO]
            } catch {
                print(error)
            }
        }
        
        // set the title of the controller
        self.navigationItem.title = clothesCollectionType
        
        // Remove the separators of the empty rows
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ClothesCell
        
        if selectedCellIndexPath != nil && selectedCellIndexPath == indexPath{
            cell.managePhoto?.alpha = 1
            cell.managePhoto?.isEnabled = true
            cell.deletePhoto?.alpha = 1
            cell.deletePhoto?.isEnabled = true
        } else {
            cell.managePhoto?.alpha = 0.0
            cell.managePhoto?.isEnabled = false
            cell.deletePhoto?.alpha = 0
            cell.deletePhoto?.isEnabled = false
        }
        
        let isAccessedFromNewCombination = self.defaults.bool(forKey: "sholdOpenNewCombination")
        
        if isAccessedFromNewCombination {
            let isSelected = self.clothes[indexPath.row].isSelected
            
           if (isSelected) {
               cell.markedRow.isHidden = false
           }
           else{
               cell.markedRow.isHidden = true
           }
        }
        
        self.clothImageRelation = self.clothes[indexPath.row].value(forKey: "imageTest") as! ClothImageMO
        
        cell.clothImageView?.image = UIImage(data: self.clothImageRelation.image! as Data)
        
        cell.activateShit()
        cell.selectionStyle = .none
        cell.delegate = self
        
        cell.clothToDelete = self.clothes[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! ClothesCell
        cell.selectionStyle = .none
        
        // Check whether the cloth collection is opened through the new combination controller. We have to know that in order not to increase the row height when clicked.
        
        let isAccessedFromNewCombination = self.defaults.bool(forKey: "sholdOpenNewCombination")
        
        if isAccessedFromNewCombination {
            
            if self.clothes[indexPath.row].isSelected {
                self.clothes[indexPath.row].isSelected = false
                cell.markedRow.isHidden = true
            } else {
                self.clothes[indexPath.row].isSelected = true
                cell.markedRow.isHidden = false
            }
            
            self.defaults.set(true, forKey: "newImageAdded")
        }
        else {
            
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
            
            cell.managePhoto.isEnabled = true
            cell.deletePhoto.isEnabled = true
            if cell.bounds.height == selectedCellHeight{
                UIView.animate(withDuration: 0.4, animations: {
                    cell.managePhoto.alpha = 1.0
                    cell.deletePhoto.alpha = 1.0
                })
            } else {
                UIView.animate(withDuration: 0.4, animations: {
                    cell.managePhoto.alpha = 0.0
                    cell.deletePhoto.alpha = 0.0
                })
            }
        }
        
        self.currentIndex = indexPath.row
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? ClothesCell {
            
            let isAccessedFromNewCombination = self.defaults.bool(forKey: "sholdOpenNewCombination")
            if isAccessedFromNewCombination {
                self.clothes[indexPath.row].isSelected = false
                cell.markedRow.isHidden = true
            }
            else{
                UIView.animate(withDuration: 0.4, animations: {
                    cell.managePhoto.isEnabled = false
                    cell.managePhoto.alpha = 0.0
                    cell.deletePhoto.isEnabled = false
                    cell.deletePhoto.alpha = 0.0
                })
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if selectedCellIndexPath == indexPath{
            return selectedCellHeight
        }
        
        return deselectedCellHeight
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section:
        Int) -> Int {
        //return images.count
        return self.clothes.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: Segues manager this is being returned when pressed x
    @IBAction func unwindToHomeScreen(_ segue: UIStoryboardSegue){
        
        let destinationController = segue.source as! ManipulateImageController
        
        let hasChosenImage = destinationController.hasChosenImage
        
        // get the UIImage from the destination controller
        if hasChosenImage == true {
            
            self.images.append(destinationController.backgroundImage.image!)
            tableView.reloadData()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "manipulateImageSegue"{
            let destinationController = segue.destination as! ManipulateImageController
            
            destinationController.currentDefaultImage = defaultImage.image
            destinationController.clothImage = self.currentImage
        }
        
        if segue.identifier == "managePhoto"{
            let destinationController = segue.destination as! ManagePhotoController
            
            destinationController.delegate = self
            //destinationController.currentImage = self.currentImage?.image
            destinationController.arrayIndex = self.currentIndex
            
            self.clothImageRelation = self.clothes[currentIndex].value(forKey: "imageTest") as! ClothImageMO
            destinationController.currentImage = UIImage(data:clothImageRelation.image! as Data)
        }
        
        if segue.identifier == "openClothCollection" {
            print("kori")
        }
    }
    
    // MARK: Managing the core data shit methods
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type{
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
        
        clothes = controller.fetchedObjects as! [ClothMO]
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // MARK: Custom methods
    
    @IBAction func showManagedPopOver(_ sender: UIButton) {
        
    }
    
    func toDoItemDeleted(_ item: ClothMO){
        if let moc = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
            
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
    
    func changePhotoAtIndex(_ image: UIImage, index: Int){
        if let moc = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
            //var currentImage = self.clothes[index].value(forKey: "imageTest") as! ClothImageMO
            
            (self.clothes[index].value(forKey: "imageTest") as! ClothImageMO).image = image.mediumQualityJPEGNSData
            
            do {
                try moc.save()
            } catch {
                print(error)
                return
            }
        }
        
        tableView.reloadData()
        let indexPath = IndexPath(row: index, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! ClothesCell
        
        cell.deletePhoto.isEnabled = true
        cell.managePhoto.isEnabled = true
        cell.deletePhoto.alpha = 1.0
        cell.managePhoto.alpha = 1.0
    }
}
