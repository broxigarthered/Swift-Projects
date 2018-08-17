//
//  SeasonsTableViewController.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 4/19/16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit

class SeasonsTableViewController: UITableViewController {
    var season = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.hidesBarsOnSwipe = false
        //navigationController?.setNavigationBarHidden(false, animated: true)
        
        //removing the title of the back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SeasonCell
        
        switch indexPath.row {
        case 0:
            cell.season.text = "Spring"
            cell.seasonImageView.image = UIImage(named: "spring")
            
        case 1:
            cell.season.text = "Summer"
            cell.seasonImageView.image = UIImage(named: "summer")
            
        case 2:
            cell.season.text = "Fall"
            cell.seasonImageView.image = UIImage(named: "fall")
            
        case 3 :
            cell.season.text = "Winter"
            cell.seasonImageView.image = UIImage(named: "winter")
            
        default:
            break
        }
        
        return cell
    }
    
    // Here we set the current season, so the next VCs (Clothes Collection, Clothes Combination.. etc) know to which key to store the upcoming data
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentIndexRow = indexPath.row
        switch currentIndexRow {
        case 0:
            Constants.defaults.setValue("spring", forKey: "currentSeason")
        case 1:
            Constants.defaults.setValue("summer", forKey: "currentSeason")
        case 2:
            Constants.defaults.setValue("fall", forKey: "currentSeason")
        case 3:
            Constants.defaults.setValue("winter", forKey: "currentSeason")
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section:
        Int) -> Int {
        return 4
    }
    
}
