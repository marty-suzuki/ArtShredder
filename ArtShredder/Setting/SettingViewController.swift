//
//  SettingViewController.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/10/12.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Prex
import UIKit
import SafariServices

final class SettingViewController: UIViewController {
    @IBOutlet private(set) weak var versionLabel: UILabel!
    @IBOutlet private(set) weak var frameDescriptionLabel: UILabel!
    @IBOutlet private(set) weak var supportPageButton: UIButton!

    private lazy var doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                                  target: self,
                                                  action: #selector(self.doneButtonTap(_:)))

    private lazy var presenter = SettingPresenter(view: self)

    init() {
        super.init(nibName: "SettingViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = doneButton

        presenter.reflect()
    }

    @objc private func doneButtonTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func openFrameWebSite(_ sender: UIButton) {
        presenter.openURL(.frameWebSite)
    }

    @IBAction private func supportPageTap(_ sender: UIButton) {
        presenter.openURL(.supportPage)
    }

    @IBAction private func prexTap(_ sender: UIButton) {
        presenter.openURL(.prex)
    }

    @IBAction private func googleMobileAdsTap(_ sender: UIButton) {
        presenter.openURL(.googleMobleAdsSDK)
    }
}

extension SettingViewController: View {
    func reflect(change: StateChange<Setting.State>) {
        if let url = change.changedProperty(for: \.openURL)?.value {
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true, completion: nil)
        }

        if let text = change.changedProperty(for: \.frameDescription)?.value {
            frameDescriptionLabel.text = text
        }

        if let title = change.changedProperty(for: \.supportTitle)?.value {
            supportPageButton.setTitle(title, for: .normal)
        }

        if let text = change.changedProperty(for: \.version)?.value {
            versionLabel.text = text
        }
    }
}
