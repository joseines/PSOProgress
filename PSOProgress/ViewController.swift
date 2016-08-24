//
//  ViewController.swift
//  PSOProgress
//
//  Created by Jose Ines Cantu Arrambide on 8/23/16.
//  Copyright © 2016 Jose Ines Cantu Arrambide. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let progress = NSProgress()
        if #available(iOS 9.0, *) {
            progress.addChild(NSProgress(totalUnitCount: 10), withPendingUnitCount: 1)
        } else {
            // Fallback on earlier versions
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

