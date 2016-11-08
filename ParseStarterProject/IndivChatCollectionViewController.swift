//
//  IndivChatCollectionViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Charlotte Leysen on 03/11/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse


class IndivChatCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var respondent = String()
    var members = [String]()
    var content = [String]()
    var isSender = [Bool]()
    var bottomConstraint: NSLayoutConstraint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = respondent
        navigationController?.toolbar.isHidden = true
        
        getData()
        


   
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // add container view
        
        view.addSubview(messageInputContainerView)
        setupInputComponents()
        
        let containerView = ["containerView" : messageInputContainerView]
        let horizontalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: containerView)
        let verticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:[containerView(48)]", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: containerView)
        
        NSLayoutConstraint.activate(horizontalConstraint)
        NSLayoutConstraint.activate(verticalConstraint)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)

       
        // send button
        sendButton.addTarget(self, action: #selector(sendMessage), for: UIControlEvents.touchUpInside)
        
        // rid keyboard
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(dismissKeyboard)
        
        let scrollDown = IndexPath(item: self.content.count - 1, section: 0)
        self.collectionView?.scrollToItem(at: scrollDown, at: .bottom, animated: true)
        
   
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        
        
        UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            }, completion: { (completed) in
                self.inputTextField.resignFirstResponder()
        })
    }
    
    func getData() {
        
        // get messages
        
        let members = [respondent, (PFUser.current()?.username!)!]
        
        content.removeAll()
        
        let query = PFQuery(className: "Messages")
        query.whereKey("recipient", containedIn: members)
        query.whereKey("sender", containedIn: members)
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                print("found objects")
                if let objects = objects {
                    for object in objects {
                        print("content \(object["content"])")
                        self.content.append(object["content"] as! String)
                        if (object["sender"] as! String) == (PFUser.current()?.username!)! {
                            self.isSender.append(true)
                        } else {
                            self.isSender.append(false)
                        }
                        self.collectionView?.reloadData()
                        print("sender \(self.isSender) \(self.content)")
                    }
                }
            }
        }
        
}

    
    // container view setup
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: UIControlState())
        let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        button.setTitleColor(titleColor, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
        
    }()
    
    
    let topBorder: UIView = {
        let border = UIView()
        border.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        border.translatesAutoresizingMaskIntoConstraints = false
        return border
    }()

    
    func setupInputComponents() {
   
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorder)
        
        let views = ["text" : inputTextField, "send": sendButton]
        let greyborder = ["border" : topBorder]
        
        let horizontalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[text][send(60)]|", options: [], metrics: nil, views: views)
        let verticalConstraintText = NSLayoutConstraint.constraints(withVisualFormat: "V:|[text(48)]-0-|", options: [], metrics: nil, views: views)
        let verticalConstraintSend = NSLayoutConstraint.constraints(withVisualFormat: "V:|[send(48)]-0-|", options: [], metrics: nil, views: views)
        

        let horizontalConstraintBorder = NSLayoutConstraint.constraints(withVisualFormat: "H:|[border]|", options: [], metrics: nil, views: greyborder)
        let verticalConstraintBorder = NSLayoutConstraint.constraints(withVisualFormat: "V:|[border(0.5)]", options: [], metrics: nil, views: greyborder)
        
        NSLayoutConstraint.activate(horizontalConstraint)
        NSLayoutConstraint.activate(verticalConstraintText)
        NSLayoutConstraint.activate(verticalConstraintSend)
        NSLayoutConstraint.activate(horizontalConstraintBorder)
        NSLayoutConstraint.activate(verticalConstraintBorder)
        
    }
    
    //send button
    
    func sendMessage() {
        print("button tapped")
        
        if inputTextField.text != "" {
            let newMessage = PFObject(className: "Messages")
            newMessage["content"] = inputTextField.text
            newMessage["sender"] = PFUser.current()?.username
            newMessage["recipient"] = respondent
            newMessage.saveInBackground()
         
            viewDidLoad()
            
            inputTextField.text = ""
            
        }


    }
 
    
    // keyboard
    
    func keyboardWasShown(notification: NSNotification) {
        if let info = notification.userInfo {
            let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            print("keyboard \(keyboardFrame)")
            
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame.height : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: { (completed) in
                    
                    if isKeyboardShowing {
                        let scrollDown = IndexPath(item: self.content.count - 1, section: 0)
                        self.collectionView?.scrollToItem(at: scrollDown, at: .bottom, animated: true)
                }
            })
        }
    }
    
    // message view
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return content.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! IndivChatCollectionViewCell
        
        cell.messageLabel.text = content[indexPath.row]
        cell.messageLabel.isEditable = false
        cell.messageLabel.isScrollEnabled = true

        let messageText = content[indexPath.row]
        print("messageText \(messageText)")
        
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)
        
        if isSender[indexPath.row] == true {
            // current user is sending
            cell.messageLabel.frame = CGRect(x: self.view.frame.width - estimatedFrame.width - 8 , y: 0, width: estimatedFrame.width, height: estimatedFrame.height + 25 )
            cell.textBubble.frame = CGRect(x: self.view.frame.width - estimatedFrame.width - 8 - 8, y: 0, width: estimatedFrame.width + 8, height: estimatedFrame.height + 25 )
            
            cell.textBubble.backgroundColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
            cell.messageLabel.textColor = UIColor.white
            
        } else {
            // received message
            cell.messageLabel.frame = CGRect(x: 8, y: 0, width: estimatedFrame.width, height: estimatedFrame.height + 25 )
            cell.textBubble.frame = CGRect(x: 0, y: 0, width: estimatedFrame.width + 8, height: estimatedFrame.height + 25 )
            cell.textBubble.backgroundColor = UIColor(white: 0.95, alpha: 1)
            cell.messageLabel.textColor = UIColor.black

            
       }

        cell.textBubble.layer.cornerRadius = 15
        cell.textBubble.layer.masksToBounds = true

        // Configure the cell
    
        return cell
    }

   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let messageText = content[indexPath.row]

            
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)

        return CGSize(width: view.frame.width, height: estimatedFrame.height + 25 )
        
        
    }
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }


}




