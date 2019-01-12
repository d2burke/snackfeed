//
//  FeedViewController.swift
//  SnackFeed
//
//  Created by Daniel Burke on 9/17/17.
//  Copyright © 2017 SnackFeed. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {
    
    let newSnackButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.backgroundColor = UIColor.lightGray.cgColor
        button.clipsToBounds = true
        button.layer.cornerRadius = 35
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 4
        button.alpha = 0
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
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
