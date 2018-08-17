import UIKit
import CoreData
import SDWebImage

class ClothesCollectionController: UITableViewController, ManagePhotoControllerDelegate, NSFetchedResultsControllerDelegate, ClothCellDelegate, ManagePhotoControllerDeleteImage  {

    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var clothesCollectionType: String = ""
    
    var temporalImages = NSMutableArray()
    
    var selectedCellIndexPath: IndexPath?
    var currentIndex: Int = 0

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
        
        // Modify the separators
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorColor = UIColor(red: 100.0/255.0, green: 150.0/255.0, blue: 240.0/255.0, alpha: 0.8)
        tableView.separatorEffect = .none
        
        // Remove the separators of the empty rows
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        //
        let isAccessedFromNewCombination = Constants.defaults.bool(forKey: "sholdOpenNewCombination")
        if isAccessedFromNewCombination {
            self.tabBarController?.tabBar.isHidden = false
        }
        
        
        let currentSeason = Constants.defaults.string(forKey: "currentSeason")
        let currentClothType = Constants.defaults.string(forKey: "currentClothType")
        
        // fetch the clothes with predicate only from certain season collection, then certain cloth type
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cloth")
        let sortDescriptor = NSSortDescriptor(key: "clothType", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let seasonPredicate: NSPredicate = NSPredicate(format: "seasonName == %@", currentSeason!)
        let clothTypePredicate: NSPredicate = NSPredicate(format: "clothType == %@", currentClothType!)
        let compoundPredicate: NSCompoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [seasonPredicate, clothTypePredicate])
        fetchRequest.predicate = compoundPredicate
        
        
        // loads all the images from the DB
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
    
    // In this function, we cache all the images initially, so when we are loading them for the second time, they load faster
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ClothesCell
        
        // Check if the current cell is clicked, so it knows when what to hide
        if selectedCellIndexPath != nil && selectedCellIndexPath == indexPath{
            cell.managePhoto.isHidden = false
            cell.deletePhoto.isHidden = false
            cell.blurEffectView.isHidden = false
        } else {
            cell.managePhoto.isHidden = true
            cell.deletePhoto.isHidden = true
            cell.blurEffectView.isHidden = true
        }
        
        let isAccessedFromNewCombination = Constants.defaults.bool(forKey: "sholdOpenNewCombination")
        
        if isAccessedFromNewCombination {
            let isSelected = self.clothes[indexPath.row].isSelected
            
            if (isSelected) {
                cell.markedRow.isHidden = false
            }
            else{
                cell.markedRow.isHidden = true
            }
        }
        
        // Here we get the "hash" string for the image, so we know where to cache it and eventually get it from the alredy existing images. If the image does not exist, we save the newly cached image.
        let sdWebImageManager: SDWebImageManager = SDWebImageManager.shared()
        let imageName = self.clothes[indexPath.row].clothImageName
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        let pathsNSURL = URL(string: paths)
        
        // caches the image if it doesn't alredy exist
        DispatchQueue.main.async {
            if !sdWebImageManager.cachedImageExists(for: pathsNSURL) {
                let imageToSet = UIImage(contentsOfFile: paths)
                sdWebImageManager.saveImage(toCache: imageToSet, for: URL(string: paths))
            }
            
            cell.clothImageView.sd_setImage(with: pathsNSURL)
        }
        
        // Enables the cell for recognizing gesture, so it knows when to delete an image
        cell.initiatePotentialCellDeletion()
        cell.selectionStyle = .none
        cell.delegate = self
        
        // Maps the cell cloth from the db, for potentiall deletion
        cell.clothToDelete = self.clothes[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! ClothesCell
        cell.selectionStyle = .none
        
        // Check whether the cloth collection is opened through the new combination controller. We have to know that in order not to increase the row height when clicked.
        
        let isAccessedFromNewCombination = Constants.defaults.bool(forKey: "sholdOpenNewCombination")
        
        if isAccessedFromNewCombination {
            
            if self.clothes[indexPath.row].isSelected {
                self.clothes[indexPath.row].isSelected = false
                cell.markedRow.isHidden = true
            } else {
                self.clothes[indexPath.row].isSelected = true
                cell.markedRow.isHidden = false
            }
            
            Constants.defaults.set(true, forKey: "newImageAdded")
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
            
            //You can also use this method followed by the endUpdates() method to animate the change in the row heights without reloading the cell. // apple
            tableView.beginUpdates()
            tableView.endUpdates()
            
            // This ensures, that the cell is fully visible once expanded
            if selectedCellIndexPath != nil {
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
            
            let isAccessedFromNewCombination = Constants.defaults.bool(forKey: "sholdOpenNewCombination")
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
            return Constants.clothesCollectionControllerSelectedCellHeight
        }
        
        return Constants.clothesCollectionControllerDeselectedCellHeight
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
    
    
    // Function for deleting given image as param from the DB. Usually gets called from the delegate of the ClothesCell
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
