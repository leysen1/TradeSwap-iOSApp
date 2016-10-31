//
//  NeighbourhoodsTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Charlotte Leysen on 28/10/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class NeighbourhoodsTableViewController: UITableViewController {

    // List all boroughs in neighbourhood array
    // Maybe convert this to a nearby radius...
    var neighbourhoodArray = ["Kensington and Chelsea","Hammersmith and Fulham", "Camden", "Westminster", "Greenwich", "Hampstead"]
    var neighbourhoodDict = [String: Bool]()
    var chosenHoods = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        for i in neighbourhoodArray {
            self.neighbourhoodDict[i] = false
        }
        
        if let testArray = PFUser.current()?["neighbourhoods"] as? NSArray {
        print(testArray)
            for i in testArray {
            chosenHoods.append(i as! String)
            }
            for i in chosenHoods {
                self.neighbourhoodDict[i] = true
            }
            print("neighbourhood \(neighbourhoodDict)")
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = neighbourhoodArray[indexPath.row]
        if neighbourhoodDict[neighbourhoodArray[indexPath.row]] == true {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if neighbourhoodDict[neighbourhoodArray[indexPath.row]] == true {
            // uncheck
            neighbourhoodDict[neighbourhoodArray[indexPath.row]] = false
            cell?.accessoryType = UITableViewCellAccessoryType.none
            
            PFUser.current()?.remove(self.neighbourhoodArray[indexPath.row], forKey: "neighbourhoods")
            PFUser.current()?.saveInBackground(block: { (success, error) in
                if error != nil {
                    print(error)
                } else {
                    print("uncheck saved")
                }
            })

            
        } else {
            // check
            neighbourhoodDict[neighbourhoodArray[indexPath.row]] = true
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
            
            PFUser.current()?.addUniqueObject(self.neighbourhoodArray[indexPath.row], forKey: "neighbourhoods")
            PFUser.current()?.saveInBackground(block: { (success, error) in
                if error != nil {
                    print(error)
                } else {
                    print("check saved")
                }
            })
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
