//
//  SkillCellViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Charlotte Leysen on 10/11/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class SkillCellViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var activityIndicator = UIActivityIndicatorView()
    var newImage: UIImage?
    var skillDescriptionTitleSC = String()
    var generalDescriptionText = String()
    var hasSkillTableSC = Bool()
    var addNewImage = Bool()
    var evidenceTitle = ""
    var chosenImage = [PFFile]()
    
    @IBOutlet var imageTitle: UITextView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var pageLabel: UILabel!
    @IBOutlet var addImageButton: UIBarButtonItem!
    
    
    
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func addImage(_ sender: AnyObject) {
        
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
            imageView.image = newImage
        }
         self.dismiss(animated: true, completion: nil)
    }
    
   
    

    func savePage(sender: UIBarButtonItem) {
        
        if newImage != nil {
        
        print("saved")
        
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
        skillDescriptions["skill"] = self.skillDescriptionTitleSC
        skillDescriptions["description"] = self.generalDescriptionText
        skillDescriptions["username"] = PFUser.current()?.username
        if self.hasSkillTableSC == true {
            skillDescriptions["hasSkill"] = 1
        } else {
            // wantsSkillTable
            skillDescriptions["hasSkill"] = 0
        }
        if imageTitle.text != "" {
            skillDescriptions["fileDes"] = imageTitle.text
        } else {
            let randNumber = Int(arc4random_uniform(10000) + 1 + 1000)
            skillDescriptions["fileDes"] = String("Untitled\(randNumber)")
        }
        
        
        let imageData = UIImageJPEGRepresentation(self.newImage!, 0.8)
        skillDescriptions["skillFile"] = PFFile(name: "image.png", data: imageData!)
        
        
        skillDescriptions.saveInBackground { (success, error) in
            if error != nil {
                print("error found")
                print(error)
            } else {
                print("saved")
            }
        }
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
        createAlert(title: "Saved", message: "Your uploaded image has been saved")
        
        } else {
            // no image selected
            createAlert(title: "No Image Chosen", message: "Please try again")
        }
    }
        

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if addNewImage {
            self.title = "Import an Image"
            // save button
            self.pageLabel.isHidden = false
            self.imageTitle.isEditable = true
            self.addImageButton.isEnabled = true
            self.addImageButton.tintColor = UIColor.blue
            self.imageTitle.backgroundColor = UIColor.groupTableViewBackground
            
            let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(savePage))
            self.navigationItem.rightBarButtonItem  = saveButton
        
            print("skill title \(skillDescriptionTitleSC)")
            print("des text \(generalDescriptionText)")
        
        } else {
            // clicked on existing image
            self.title = evidenceTitle
            self.pageLabel.isHidden = true
            self.imageTitle.isEditable = false
            self.addImageButton.isEnabled = false
            self.addImageButton.tintColor = UIColor.clear
            self.imageTitle.backgroundColor = UIColor.clear
            self.imageView.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
            
            // add image
            self.chosenImage[0].getDataInBackground { (data, error) in
            if let imageData = data {
                if let downloadedImage = UIImage(data: imageData) {
                    self.imageView.image = downloadedImage
                }
            }
        }
        
        }

    }
    

}
