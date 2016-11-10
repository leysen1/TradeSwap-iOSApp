
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
// Add pop up full screen image view
// Maybe change the table view to include a description of each upload, then click for full size image

class SkillDescriptionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageFiles = [PFFile]()
    var descriptionLabel = [String]()
    var fileDescription = [String]()
    var newImage = UIImage()
    var screenImage = UIImage()
    var activityIndicator = UIActivityIndicatorView()
    var editMode = false
    var userSelectedSD = String()
    var skillDescriptionTitleSD = ""
    var hasSkillTableSD: Bool = true
  
    
    @IBOutlet var skillLabel: UILabel!
    @IBOutlet var descriptionText: UITextView!
    @IBOutlet var saveButton: UIBarButtonItem!
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
    
    
    
    @IBAction func save(_ sender: AnyObject) {
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
    
    var tField: UITextField!
    
    func configurationTextField(textField: UITextField!)
    {
        print("generating the TextField")
        textField.placeholder = "Enter an item"
        tField = textField
    }
    
    func handleCancel(alertView: UIAlertAction!)
    {
        print("Cancelled !!")
    }
    
    func newAlert() {
        let alert = UIAlertController(title: "Enter Input", message: "", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler:{ (UIAlertAction) in
            print("Done !!")
            
            print("Item : \(self.tField.text)")
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    var alertTextfield: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let imageProfile = info[UIImagePickerControllerOriginalImage] as? UIImage {
            newImage = imageProfile
            print("See new image")
            print(newImage)
            
            // pop up a textbox to put in title of image
            
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
            
            
            
            /*
            let alert = UIAlertView()
            alert.title = "Enter a title for your upload"
            alert.addButton(withTitle: "Save")
            alert.addButton(withTitle: "Cancel")
            alert.alertViewStyle = UIAlertViewStyle.plainTextInput
            self.alertTextfield = alert.textField(at: 0)!
            alert.addSubview(alertTextfield)
            
            alert.show()
            
            print("alertTextfield \(self.alertTextfield.text)")
 
            */
            
        }

    }
    
    func savePicture() {
        
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
                            
                            if row["description"] != nil {
                                self.descriptionLabel.append(row["description"] as! String)
                            } else {
                                self.descriptionLabel.append("Describe your expertise here.")
                            }
                            if row["fileDes"] != nil {
                                self.fileDescription.append(row["fileDes"] as! String)
                            } else {
                                self.fileDescription.append("Untitled")
                            }
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
        
        print("hasskill \(hasSkillTableSD)")
       
        if editMode == false {
            // viewing another user's skill description
            if self.hasSkillTableSD == true {
                // a skill the user has
                self.title = "Skill to Teach"
                greyLabel2.text = "Skill Demonstrated"
                
            } else {
                // a skill the user wants
                self.title = "Skill to Learn"
                greyLabel2.text = "What \(self.userSelectedSD) already knows"
            }
            descriptionText.isUserInteractionEnabled = false
            skillLabel.text = "\(self.userSelectedSD)'s \(self.skillDescriptionTitleSD)"
            greyLabel1.text = "Description"
            saveButton.isEnabled = false
            saveButton.tintColor = UIColor.clear
            addImageButton.isEnabled = false
            addImageButton.tintColor = UIColor.clear
            
        } else {
            // editMode is true - viewing your profile
            
            skillLabel.text = self.skillDescriptionTitleSD
            descriptionText.isUserInteractionEnabled = true
            if self.hasSkillTableSD == true {
            
                self.title = "Skill to Teach"
                greyLabel1.text = "Describe your expertise"
                descriptionText.text = "Description"
                greyLabel2.text = "Show us your skill"

            } else {
                // wants Skills view
                self.title = "Skill to Learn"
                greyLabel1.text = "Description"
                descriptionText.text = "Tell us what you're looking for and what you already know."
                greyLabel2.text = "Show us what you already know"
            }
        }
        print("hasSkillTableSD \(hasSkillTableSD)")
        refresh()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        refresh()
        self.tableView.reloadData()
        self.tableView.tableFooterView = UIView()
        

    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SkillDescriptionTableViewCell
        
        cell.evidenceLabel.text = fileDescription[indexPath.row]
        
        imageFiles[indexPath.row].getDataInBackground { (data, error) in
            
            if let imageData = data {
                if let downloadedImage = UIImage(data: imageData) {
                    cell.tableImage.image = downloadedImage
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.allowsSelectionDuringEditing = true
        
    }
    
    
    
    @IBAction func addImage(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "toSkillCellView", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toSkillCellView") {
            let skillCell = segue.destination as! SkillCellViewController
            skillCell.skillDescriptionTitleSC = skillDescriptionTitleSD
            skillCell.generalDescriptionText = descriptionText.text
            skillCell.hasSkillTableSC = hasSkillTableSD
    }
    
   /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SkillDescriptionTableViewCell


        if let fullImage: UIImage = cell.tableImage.image {
            let fullImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            fullImageView.image = fullImage
            self.view.addSubview(fullImageView)
            fullScreen = true
        }
        
        
    }
*/

    }
}
