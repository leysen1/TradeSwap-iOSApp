//
//  ChatTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Charlotte Leysen on 03/11/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class ChatTableViewController: UITableViewController {
    
    // in cell write most recent message content

    var chatArray = [String]()
    var respondentCT = String()
    var respondentImageArray = [UIImage]()
    var respondentImageCT = UIImage()
    let username = (PFUser.current()?.username!)!
    
    var content = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let testArray = PFUser.current()?["MatchAccepted"] as? NSArray {
            for i in testArray {
                chatArray.append(i as! String)
            }
            print("chatArray \(chatArray)")
        }
        
        tableView.tableFooterView = UIView()
        self.title = "Chats"

    }
    
    override func viewDidAppear(_ animated: Bool) {
          navigationController?.toolbar.isHidden = false
    }
    
    func getData() {
        
        // get messages
        

        
    }



    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chatArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatTableViewCell
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        // get photo
        let queryPhoto = PFQuery(className: "_User")
        queryPhoto.whereKey("username", equalTo: chatArray[indexPath.row])
        queryPhoto.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                if let objects = objects {
                    for object in objects {
                        if object["photo"] != nil {
                            print("photo found")
                            let profileData = object["photo"] as! PFFile
                            print("profile Data \(profileData)")
                            profileData.getDataInBackground { (data, error) in
                                if let imageData = data {
                                    if let downloadedImage = UIImage(data: imageData) {
                                        self.respondentImageArray.append(downloadedImage)
                                        cell.profileImage.image = downloadedImage
                                        cell.profileImage.layer.cornerRadius = 25
                                        cell.profileImage.layer.masksToBounds = true
                                    }
                                }
                            }
                        } else {
                            // no image found
                            self.respondentImageArray.append(UIImage(named: "profile.png")!)
                            cell.profileImage.image = UIImage(named: "profile.png")
                            cell.profileImage.layer.cornerRadius = 25
                            cell.profileImage.layer.masksToBounds = true
                        }
                    }
                } else {
                    print("no objects")
                }
            }
        }
        
        // get last message sent 
        
        content.removeAll()
        
        let queryContent = PFQuery(className: "Messages")
        queryContent.whereKey("recipient", equalTo: chatArray[indexPath.row])
        queryContent.whereKey("sender", equalTo: self.username)
        queryContent.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                print("found objects")
                if let objects = objects {
                    
                    var tempContent = [String]()
                    for object in objects {
                        tempContent.removeAll()
                        tempContent.append(object["content"] as! String)
                    }
                    if tempContent.count > 0 {
                        let contentIndexNumber = tempContent.count - 1
                        self.content.append(tempContent[contentIndexNumber])
                    } else {
                        self.content.append(" ")
                    }
                    
                    cell.contentLabel.text = self.content[indexPath.row]
                    tableView.reloadData()
                }
            }
        }
        
        cell.usernameLabel.text = chatArray[indexPath.row]

        UIApplication.shared.endIgnoringInteractionEvents()
        
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if respondentImageArray.count > 0 {
            respondentCT = chatArray[indexPath.row]
            respondentImageCT = respondentImageArray[indexPath.row]
            performSegue(withIdentifier: "ChatWithSegue", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ChatWithSegue") {
            let IndivChat = segue.destination as! IndivChatCollectionViewController
            IndivChat.respondent = respondentCT
            IndivChat.respondentImage = respondentImageCT
            
        }

        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
