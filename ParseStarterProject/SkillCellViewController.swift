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
    var newImage = UIImage()
    var skillDescriptionTitleSC = String()
    var generalDescriptionText = String()
    var hasSkillTableSC = Bool()
    @IBOutlet var imageTitle: UITextView!
    @IBOutlet var imageView: UIImageView!
    
    
    
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
            skillDescriptions["fileDes"] = "Untitled"
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
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
        createAlert(title: "Saved", message: "Your uploaded image has been saved")
        
        }
        

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Import an Image"
        
        // save button
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(savePage))
        self.navigationItem.rightBarButtonItem  = saveButton
        
        print("skill title \(skillDescriptionTitleSC)")
        print("des text \(generalDescriptionText)")
        

    }
    

}
