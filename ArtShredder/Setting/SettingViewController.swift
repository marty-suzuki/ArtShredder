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
    @IBOutlet private(set) weak var versionLabel: UILabel! {
        didSet {
            guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                versionLabel.text = "Version: unknown"
                return
            }
            versionLabel.text = "Version: \(version)"
        }
    }

    @IBOutlet private(set) weak var frameDescriptionLabel: UILabel! {
        didSet {
            let localized = NSLocalizedString("frame_description", comment: "")
            frameDescriptionLabel.text = String(format: localized, Const.urlString)
        }
    }
    @IBOutlet private(set) weak var supportPageButton: UIButton! {
        didSet {
            let localized = NSLocalizedString("supprot_title", comment: "")
            supportPageButton.setTitle(localized, for: .normal)
        }
    }

    private lazy var doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                                  target: self,
                                                  action: #selector(self.doneButtonTap(_:)))

    private enum Const {
        static let urlString = "https://www.freeiconspng.com/img/24597"
    }

    init() {
        super.init(nibName: "SettingViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = doneButton
    }

    @objc private func doneButtonTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func openFrameWebSite(_ sender: UIButton) {
        let url = URL(string: Const.urlString)!
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }

    @IBAction private func supportPageTap(_ sender: UIButton) {
        let string = NSLocalizedString("support_url", comment: "")
        guard  let url = URL(string: string) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }

    @IBAction private func prexTap(_ sender: UIButton) {
        guard  let url = URL(string: "https://github.com/marty-suzuki/Prex") else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }

    @IBAction private func googleMobileAdsTap(_ sender: UIButton) {
        guard  let url = URL(string: "https://cocoapods.org/pods/Google-Mobile-Ads-SDK") else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
}
