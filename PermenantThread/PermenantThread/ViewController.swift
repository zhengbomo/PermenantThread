//
//  ViewController.swift
//  PermenantThread
//
//  Created by bomo on 2020/6/17.
//  Copyright © 2020 bomo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var thread = PermenantThread()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.thread.run()
    }

    @IBAction func stop(_ sender: Any) {
        self.thread.stop()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.thread.execute {
            print("task ------ \(Thread.current)")
        }
    }
    
    deinit {
        print("VC释放了")
    }
}

