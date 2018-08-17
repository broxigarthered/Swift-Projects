//
//  TagsTableViewController.swift
//  Adi's Wardrobe Organizer
//
//  Created by Nikolay on 6/9/16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit
class TagsTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var mainTagTextField: YoshikoTextField!
    @IBOutlet weak var secondTagTextField: YoshikoTextField!
    @IBOutlet weak var thirdTagTextField: YoshikoTextField!
    
    var tagsToModify: [String] = []
    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = UIColor.black
        self.hideKeyboardWhenTappedAround()
        
        self.mainTagTextField.font = UIFont(name: "Hiragino Sans W3", size: 20.0)
        self.secondTagTextField.font = UIFont(name: "Hiragino Sans W3", size: 20.0)
        self.thirdTagTextField.font = UIFont(name: "Hiragino Sans W3", size: 20.0)
        
        self.mainTagTextField.delegate = self
        self.secondTagTextField.delegate = self
        self.thirdTagTextField.delegate = self
        
        // Change the return type on the keyboard from next line to done
        mainTagTextField.returnKeyType = .done
        secondTagTextField.returnKeyType = .done
        thirdTagTextField.returnKeyType = .done

        // if managbleOption mode is true, set the tags in the bars
        let defaults = UserDefaults.standard
        let shouldLoadTags = defaults.bool(forKey: "shouldLoadCombination")
        
        if shouldLoadTags {
            mainTagTextField.text = self.tagsToModify[0]
            
            if tagsToModify.count > 1 {
                secondTagTextField.text = tagsToModify[1]
            }
            
            if tagsToModify.count > 2 {
                thirdTagTextField.text=tagsToModify[2]
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.selectionStyle = .none
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    /**
     Manages the keyboard hiding when pressing done.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func getTags() -> [String] {
        var tags: [String] = []
        
        // validate main
        var mainString: String!
        if !(self.mainTagTextField.text?.isEmpty)! || self.mainTagTextField.text != nil{
            mainString = (self.mainTagTextField.text?.replacingOccurrences(of: "#", with: ""))!
        }
        
        
        if mainString!.isEmpty {
            
            let errorMenu = UIAlertController(title: "Error 304", message: "A new combination cannot be created without a main tag.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            errorMenu.addAction(cancelAction)
            self.present(errorMenu, animated: true, completion: nil)
        }
        else {
            tags.append("#" + mainString!)
            
            var temporalString: String!
            if !(self.secondTagTextField.text?.isEmpty)! || self.secondTagTextField.text != nil{
                temporalString = (self.secondTagTextField.text?.replacingOccurrences(of: "#", with: ""))!
            }
            
            if !temporalString.isEmpty {
                tags.append("#"+temporalString)
            }
            
            if !(self.thirdTagTextField.text?.isEmpty)! || self.thirdTagTextField.text != nil{
                temporalString = (self.thirdTagTextField.text?.replacingOccurrences(of: "#", with: ""))!
            }
            
            if !temporalString.isEmpty {
                tags.append("#"+temporalString)
            }
        }
        
        return tags
    }
}
