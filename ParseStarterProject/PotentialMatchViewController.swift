//
//  PotentialMatchViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Charlotte Leysen on 31/10/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class PotentialMatchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var userProfileLabel: UILabel!
    @IBAction func matchButton(_ sender: AnyObject) {
    }
    
    @IBOutlet var userSkillsLabel: UILabel!
    @IBOutlet var userWantsLabel: UILabel!
    @IBOutlet var skillsTable: UITableView!
    @IBOutlet var wantsTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        userProfileLabel.text = "\(userSelected)'s Profile"
        userSkillsLabel.text = "\(userSelected)'s Skills"
        userWantsLabel.text = "\(userSelected) would like to learn:"
        
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == skillsTable {
        return 4
        } else {
            // wantsTable
            return 4
        }
        
    }
 

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if tableView == skillsTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SkillCell", for: indexPath)
            cell.textLabel?.text = "Test 1"
            return cell
        } else {
            // wants Table
            let cell = tableView.dequeueReusableCell(withIdentifier: "WantsCell", for: indexPath)
            cell.textLabel?.text = "Test 2"
            return cell
        }
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
