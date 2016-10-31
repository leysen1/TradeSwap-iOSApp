
//
//  SkillDescriptionViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Charlotte Leysen on 25/10/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

// When saving new image, may need to add a unique name of image, in order to find it when deleting
// In the load for wantSkillTable, change grey labels

class SkillDescriptionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageFiles = [PFFile]()
    var descriptionLabel = [String]()
    var newImage = UIImage()
    var activityIndicator = UIActivityIndicatorView()
    var editMode = false
    var userSelectedSD = String()
    var skillDescriptionTitleSD = ""
    var hasSkillTableSD: Bool = true
  
    
    @IBOutlet var skillLabel: UILabel!
    @IBOutlet var descriptionText: UITextView!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var addImageButton: UIBarButtonItem!
    
    
    @IBOutlet var greyLabel1: UILabel!
    @IBOutlet var greyLabel2: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in

        }))
        self.present(alert, animated: true, completion: nil)

    }
    


    @IBAction func saveDescription(_ sender: AnyObject) {
        // spinner
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let query = PFQuery(className: "SkillDescription")
        query.whereKey("skill", equalTo: skillDescriptionTitleSD)
        query.whereKey("username", equalTo: (PFUser.current()?.username!)!)
        if hasSkillTableSD == true {
            query.whereKey("hasSkill", equalTo: 1)
        } else {
            // wantsSkillTable
            query.whereKey("hasSkill", equalTo: 0)
        }
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                if let objects = objects {
                    if objects.count > 0 {
                        // objects found
                        print("found objects")
                        for object in objects {
                            object["description"] = self.descriptionText.text
                            object.saveInBackground(block: { (success, error) in
                            })
                        }
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.createAlert(title: "Saved", message: "Your description has been saved")
                } else {
                    // there are no objects yet 
                    print("no objects")
                    let descriptionObject = PFObject(className: "SkillDescription")
                    descriptionObject["skill"] = self.skillDescriptionTitleSD
                    descriptionObject["description"] = self.descriptionText.text
                    descriptionObject["username"] = PFUser.current()?.username
                    if self.hasSkillTableSD == true {
                        descriptionObject["hasSkill"] = 1
                    } else {
                        // wantsSkillTable
                        descriptionObject["hasSkill"] = 0
                    }

                    descriptionObject.saveInBackground { (success, error) in
                        if error != nil {
                            print("error found")
                            print(error)
                        } else {
                            print("saved")
                        }
                    }
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.createAlert(title: "Saved", message: "Your description has been saved")
                }
            }
        }
    }
}
    
    
    @IBAction func addSkillImage(_ sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let imageProfile = info[UIImagePickerControllerOriginalImage] as? UIImage {
            newImage = imageProfile
            print("See new image")
            print(newImage)
            
            // spinner
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
        // save picture
        let skillDescriptions = PFObject(className: "SkillDescription")
        skillDescriptions["skill"] = self.skillDescriptionTitleSD
        skillDescriptions["description"] = self.descriptionText.text
        skillDescriptions["username"] = PFUser.current()?.username
        if self.hasSkillTableSD == true {
            skillDescriptions["hasSkill"] = 1
        } else {
            // wantsSkillTable
            skillDescriptions["hasSkill"] = 0
        }

        let imageData = UIImageJPEGRepresentation(self.newImage, 0.8)
        skillDescriptions["skillFile"] = PFFile(name: "image.png", data: imageData!)
        
        
        skillDescriptions.saveInBackground { (success, error) in
            if error != nil {
                print("error found")
                print(error)
            } else {
                print("saved")
            }
        }
        self.dismiss(animated: true, completion: nil)
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
        createAlert(title: "Saved", message: "Your uploaded image has been saved")
            
        }
    }
    
    
    func refresh() {
        
        // spinner
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        imageFiles.removeAll()
        descriptionLabel.removeAll()
        
        // creating the image array from the saved PFFiles
        let query = PFQuery(className: "SkillDescription")
        if editMode == false {
            query.whereKey("username", equalTo: userSelectedSD)
        } else {
            query.whereKey("username", equalTo: (PFUser.current()?.username!)!)
        }
        query.whereKey("skill", equalTo: self.skillDescriptionTitleSD)
        
        if hasSkillTableSD == true {
            query.whereKey("hasSkill", equalTo: 1)
        } else {
            query.whereKey("hasSkill", equalTo: 0)
        }
 
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                // create image array
                if let rows = objects {
                    for row in rows {
                      // if let object = row as? PFObject {
                            if row["skillFile"] != nil {
                                self.imageFiles.append(row["skillFile"] as! PFFile)
                            }
                            if row["description"] != nil {
                                self.descriptionLabel.append(row["description"] as! String)
                        }
                      
                      //  }
                    }
                    self.tableView.reloadData()
                    
                    if self.descriptionLabel != [] {
                        self.descriptionText.text = self.descriptionLabel[0]
                    } else {
                        self.descriptionText.text = "Describe your expertise here"
                    }
                }
            }
        }
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if editMode == false {
            // viewing another user's skill description
            
            // hide and deactivate save and plus button
            skillLabel.text = "\(self.userSelectedSD)'s \(self.skillDescriptionTitleSD)"
            greyLabel1.text = "Description"
            greyLabel2.text = "Skill Demonstrated"
            saveButton.isEnabled = false
            saveButton.alpha = 0
            addImageButton.isEnabled = false
            // hide imagebutton
        } else {
            // editMode is true
            skillLabel.text = self.skillDescriptionTitleSD
            greyLabel1.text = "Describe your expertise"
            greyLabel2.text = "Show us your skill"
            if self.hasSkillTableSD == true {
                self.title = "Skills I have"
            } else {
                // wants Skills view
                self.title = "Skills I want"
            }
        }
        print("hasSkillTableSD \(hasSkillTableSD)")
        refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        

        self.tableView.reloadData()
    }


    func numberOfSections(in tableView: UITableView) -> Int {
 
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageFiles.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SkillDescriptionTableViewCell
        
        imageFiles[indexPath.row].getDataInBackground { (data, error) in
            
            if let imageData = data {
                if let downloadedImage = UIImage(data: imageData) {
                    cell.tableImage.image = downloadedImage
                }
            }
        }
        return cell
        
    }
    

}
