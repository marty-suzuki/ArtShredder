//
//  SettingViewController.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/10/12.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit
import SafariServices

final class SettingViewController: UIViewController {

    @IBOutlet private(set) weak var frameDescriptionLabel: UILabel! {
        didSet {
            let localized = NSLocalizedString("frame_description", comment: "")
            frameDescriptionLabel.text = String(format: localized, Const.urlString)
        }
    }

    private enum Const {
        static let urlString = "https://www.freeiconspng.com/img/24597"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction private func openFrameWebSite(_ sender: UIButton) {
        let url = URL(string: Const.urlString)!
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
}
