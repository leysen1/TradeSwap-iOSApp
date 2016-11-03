//
//  IndivChatViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Charlotte Leysen on 03/11/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class IndivChatViewController: UIViewController {
    
    var respondent = String()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("respondent \(respondent)")
        self.title = respondent
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
