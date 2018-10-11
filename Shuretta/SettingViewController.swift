//
//  SettingViewController.swift
//  Shuretta
//
//  Created by marty-suzuki on 2018/10/12.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit
import SafariServices

final class SettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction private func openFrameWebSite(_ sender: UIButton) {
        let url = URL(string: "https://www.freeiconspng.com/img/24597")!
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
}
