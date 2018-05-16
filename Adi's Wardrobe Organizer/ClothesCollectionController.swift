import UIKit
import CoreData
import SDWebImage

class ClothesCollectionController: UITableViewController, ManagePhotoControllerDelegate, NSFetchedResultsControllerDelegate, ClothCellDelegate, ManagePhotoControllerDeleteImage  {
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        let dbManager = ImageSaveManager.sharedInstance
        
        DispatchQueue.main.async {
            for clothEntity in self.clothes {
                let imageName = clothEntity.clothImageName
                dbManager.cacheImage(imageName: imageName)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorColor = UIColor(red: 100.0/255.0, green: 150.0/255.0, blue: 240.0/255.0, alpha: 0.8)
        tableView.separatorEffect = .none
        
        // Remove the separators of the empty rows
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        //
        let isAccessedFromNewCombination = self.defaults.bool(forKey: "sholdOpenNewCombination")
        if isAccessedFromNewCombination {
            self.tabBarController?.tabBar.isHidden = true
        }
        
        
        let currentSeason = defaults.string(forKey: "currentSeason")
        let currentClothType = defaults.string(forKey: "currentClothType")
        
        // fetch the clothes with predicate only from certain season collection, then certain cloth type
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cloth")
        let sortDescriptor = NSSortDescriptor(key: "clothType", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let seasonPredicate: NSPredicate = NSPredicate(format: "seasonName == %@", currentSeason!)
        let clothTypePredicate: NSPredicate = NSPredicate(format: "clothType == %@", currentClothType!)
        let compoundPredicate: NSCompoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [seasonPredicate, clothTypePredicate])
        fetchRequest.predicate = compoundPredicate
        
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
            cell.managePhoto.isHidden = false
            cell.deletePhoto.isHidden = false
            cell.blurEffectView.isHidden = false
        } else {
            cell.managePhoto.isHidden = true
            cell.deletePhoto.isHidden = true
            cell.blurEffectView.isHidden = true
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
        
        //self.clothImageRelation = self.clothes[indexPath.row].value(forKey: "imageTest") as! ClothImageMO
        //cell.clothImageView?.image = UIImage(data: self.clothImageRelation.image! as Data)
        //print((self.clothImageRelation.image?.count)!/1024)
        let sdWebImageManager: SDWebImageManager = SDWebImageManager.shared()
        let imageName = self.clothes[indexPath.row].clothImageName
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        let pathsNSURL = URL(string: paths)
        
        DispatchQueue.main.async {
            if !sdWebImageManager.cachedImageExists(for: pathsNSURL) {
                let imageToSet = UIImage(contentsOfFile: paths)
                sdWebImageManager.saveImage(toCache: imageToSet, for: URL(string: paths))
            }
            
            cell.clothImageView.sd_setImage(with: pathsNSURL)
        }
        
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
                cell.managePhoto.isHidden = true
                cell.deletePhoto.isHidden = true
                cell.blurEffectView.isHidden = true
            } else {
                selectedCellIndexPath = indexPath
                cell.managePhoto.isHidden = false
                cell.deletePhoto.isHidden = false
                cell.blurEffectView.isHidden = false
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
                let notClickedCell = tableView.cellForRow(at: index) as! ClothesCell
                notClickedCell.managePhoto.isHidden = true
                notClickedCell.deletePhoto.isHidden = true
                notClickedCell.blurEffectView.isHidden = true
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
                    cell.managePhoto.isHidden = true
                    cell.deletePhoto.isHidden = true
                    cell.blurEffectView.isHidden = true
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
            destinationController.mpcDeleteImageDelegate = self
            destinationController.arrayIndex = self.currentIndex
            
            let imageSaverInstance = ImageSaveManager.sharedInstance
            let imageName = self.clothes[currentIndex].clothImageName
            let image = imageSaverInstance.getImage(currentIndex, imageName)
            destinationController.currentImage = image
            destinationController.dbCurrentIndex = currentIndex
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
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        
        if self.selectedCellIndexPath != nil {
            self.deleteClothImage(self.clothes[(selectedCellIndexPath?.row)!])
        }
        
    }
    
    func deleteClothImage(_ item: ClothMO){
        
        let alertController = UIAlertController(title: "Delete", message: "Do you want to delete this image?", preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "No", style: .default) { (alertController) in
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
        }
        
        let yesActionController = UIAlertAction(title: "Yes", style: .cancel) { (
            alertAction) in
            if let moc = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
                
                let dbManager = ImageSaveManager.sharedInstance
                let imageName = item.clothImageName
                dbManager.removeImage(itemName: imageName)
                
                self.tableView.beginUpdates()
                
                self.selectedCellIndexPath = nil
                moc.delete(item)
                
                do{
                    try moc.save()
                } catch {
                    print(error)
                }
                
                self.tableView.endUpdates()
            }
            
        }
        
        alertController.addAction(yesActionController)
        alertController.addAction(noAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteImageAtIndex(_ index: Int) {
        let clothMOToDelete = self.clothes[index]
        self.deleteClothImage(clothMOToDelete)
    }
    
    
    func changePhotoAtIndex(_ image: UIImage, index: Int){
        //TODO
        
    }
}
