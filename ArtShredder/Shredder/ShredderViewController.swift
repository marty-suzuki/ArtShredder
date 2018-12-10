//
//  ShredderViewController.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/10/27.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Prex
import UIKit
import WebKit
import MobileCoreServices
import GoogleMobileAds

final class ShredderViewController: UIViewController {

    @IBOutlet private(set) weak var selectImageButton: UIButton! {
        didSet {
            let imageName = LocalizedString.selectImageName
            guard let image = UIImage(named: imageName) else {
                return
            }
            selectImageButton.setImage(image, for: .normal)
            selectImageButton.imageView?.contentMode = .scaleAspectFit
            selectImageButton.contentHorizontalAlignment = .fill
            selectImageButton.contentVerticalAlignment = .fill
        }
    }
    @IBOutlet private(set) weak var saveImageButton: UIButton! {
        didSet {
            saveImageButton.isEnabled = false
            let title = LocalizedString.saveImageButton
            saveImageButton.setTitle(title, for: .normal)
        }
    }
    @IBOutlet private(set) weak var saveGifButton: UIButton! {
        didSet {
            saveGifButton.isEnabled = false
            let title = LocalizedString.saveGIFButton
            saveGifButton.setTitle(title, for: .normal)
        }
    }
    @IBOutlet private(set) weak var arButton: UIButton! {
        didSet {
            let title = LocalizedString.arModeTitle
            arButton.setTitle(title, for: .normal)
        }
    }

    @IBOutlet private(set) weak var indicatorView: UIActivityIndicatorView! {
        didSet {
            indicatorView.isHidden = true
            indicatorView.stopAnimating()
        }
    }

    @IBOutlet private(set) weak var bottomView: UIView!
    @IBOutlet private(set) weak var imageView: UIImageView!
    @IBOutlet private(set) weak var imageViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var containerView: UIView!
    @IBOutlet private(set) weak var bannerContainerView: UIView! {
        didSet {
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            bannerContainerView.addSubview(bannerView)
            bannerContainerView.addConstraints(
                [NSLayoutConstraint(item: bannerView,
                                    attribute: .top,
                                    relatedBy: .equal,
                                    toItem: bannerContainerView,
                                    attribute: .top,
                                    multiplier: 1,
                                    constant: 0),
                 NSLayoutConstraint(item: bannerView,
                                    attribute: .centerX,
                                    relatedBy: .equal,
                                    toItem: bannerContainerView,
                                    attribute: .centerX,
                                    multiplier: 1,
                                    constant: 0)
                ])
        }
    }
    private lazy var bannerView: GADBannerView = {
        let view = GADBannerView(adSize: kGADAdSizeBanner)
        view.adUnitID = AdMobConfig.make().banner.normalBottomAdID
        view.rootViewController = self
        view.delegate = delegateHandler
        view.load(GADRequest())
        return view
    }()

    private lazy var presenter = ShredderPresenter(view: self)
    private lazy var delegateHandler = ShredderViewDelegateHandler(presenter: self.presenter)

    override var prefersStatusBarHidden: Bool {
        return true
    }

    init() {
        super.init(nibName: "ShredderViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.createAndLoadInterstitial(referer: .arMode, delegate: delegateHandler)
        presenter.createAndLoadInterstitial(referer: .saveGIF, delegate: delegateHandler)
        _ = bannerView
    }

    @IBAction private func returnToMe(segue: UIStoryboardSegue) {}

    @IBAction private func selectPicture(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let title = LocalizedString.imageSourceSelectTitle
            let message = LocalizedString.imageSourceSelectMessage
            let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
                let rect = CGRect(x: view.center.x,
                                  y: containerView.frame.minY,
                                  width: view.bounds.size.width / 2,
                                  height: view.bounds.size.height / 2)
                alert.popoverPresentationController?.sourceRect = rect
                alert.popoverPresentationController?.sourceView = view
            }

            let cameraTitle = LocalizedString.imageSourceSelectCamera
            alert.addAction(UIAlertAction(title: cameraTitle, style: .default) { [weak self] _ in
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self?.delegateHandler
                self?.present(picker, animated: true, completion: nil)
            })

            let cameraRollTitle = LocalizedString.imageSourceSelectCameraRoll
            alert.addAction(UIAlertAction(title: cameraRollTitle, style: .default) { [weak self] _ in
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self?.delegateHandler
                self?.present(picker, animated: true, completion: nil)
            })

            let cancelTitle = LocalizedString.cancelAction
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = delegateHandler
        present(picker, animated: true, completion: nil)
    }

    @IBAction private func saveImage(_ sender: UIButton) {
        defer {
            saveImageButton.isHidden = false
            selectImageButton.isHidden = false
        }
        saveImageButton.isHidden = true
        selectImageButton.isHidden = true

        guard let data = snapshot()?.pngData() else {
            return
        }

        let controller = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            let rect = CGRect(x: view.center.x,
                              y: containerView.frame.minY,
                              width: view.bounds.size.width / 2,
                              height: view.bounds.size.height / 2)
            controller.popoverPresentationController?.sourceRect = rect
            controller.popoverPresentationController?.sourceView = view
        }
        controller.completionWithItemsHandler = { [weak self] activityType, isCompleted, returnedItems, error in
            guard isCompleted && activityType == .saveToCameraRoll else {
                return
            }
            DispatchQueue.main.async {
                self?.saveFinishedAlert()
            }
        }
        present(controller, animated: true, completion: nil)
    }

    private func saveFinishedAlert() {
        let title = LocalizedString.didSaveToCameraRollTitle
        let message = LocalizedString.didSaveToCameraRollMessage
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            let rect = CGRect(x: view.center.x,
                              y: containerView.frame.minY,
                              width: view.bounds.size.width / 2,
                              height: view.bounds.size.height / 2)
            alert.popoverPresentationController?.sourceRect = rect
            alert.popoverPresentationController?.sourceView = view
        }
        present(alert, animated: true, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            alert.dismiss(animated: true, completion: nil)
        }
    }

    private func snapshot(size: CGSize? = nil, scale: CGFloat = 0.0) -> UIImage? {
        let _size = size ?? view.bounds.size
        let _rect = size.map { CGRect(x: 0, y: 0, width: $0.width, height: $0.height) } ?? view.bounds

        UIGraphicsBeginImageContextWithOptions(_size, false, scale)
        view.drawHierarchy(in: _rect, afterScreenUpdates: false)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        return image
    }

    @IBAction func saveGif(_ sender: UIButton) {
        if let interstitial = presenter.state.interstitialForGIF, interstitial.isReady {
            presenter.setInterstitial(interstitial, referer: .saveGIF)
        } else {
            presenter.createGIF()
            presenter.createAndLoadInterstitial(referer: .saveGIF, delegate: delegateHandler)
        }
    }

    @IBAction func arButtonTap(_ sender: UIButton) {
        if let interstitial = presenter.state.interstitialForAR, interstitial.isReady {
            presenter.setInterstitial(interstitial, referer: .arMode)
        } else {
            presenter.showAR()
            presenter.createAndLoadInterstitial(referer: .arMode, delegate: delegateHandler)
        }
    }

    @IBAction func settingButtonTap(_ sender: UIButton) {
        let vc = SettingViewController()
        let nc = UINavigationController(rootViewController: vc)
        nc.modalTransitionStyle = .flipHorizontal
        present(nc, animated: true, completion: nil)
    }
}

extension ShredderViewController: View {
    func reflect(change: StateChange<Shredder.State>) {
        
        if let url = change.changedProperty(for: \.gifURL)?.value {
            let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
                let rect = CGRect(x: view.center.x,
                                  y: containerView.frame.minY,
                                  width: view.bounds.size.width / 2,
                                  height: view.bounds.size.height / 2)
                controller.popoverPresentationController?.sourceRect = rect
                controller.popoverPresentationController?.sourceView = view
            }
            controller.completionWithItemsHandler = { activityType, isCompleted, returnedItems, error in
                guard isCompleted && activityType == .saveToCameraRoll else {
                    return
                }
                DispatchQueue.main.async {
                    self.saveFinishedAlert()
                }
            }
            present(controller, animated: true, completion: nil)
        }

        if change.changedProperty(for: \.isCapturing)?.value == true {
            containerView.layoutIfNeeded()
            imageViewCenterYConstraint.constant = bottomView.frame.size.height

            indicatorView.isHidden = false
            indicatorView.startAnimating()

            UIView.animate(withDuration: 5, delay: 2, options: .curveEaseInOut, animations: {
                self.containerView.layoutIfNeeded()
            }) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    self.presenter.stopCapture()
                    self.indicatorView.isHidden = true
                    self.indicatorView.stopAnimating()
                    self.selectImageButton.isEnabled = true
                    self.saveImageButton.isEnabled = true
                    self.saveGifButton.isEnabled = true
                }
            }
        }

        if let interstitial = change.changedProperty(for: \.interstitial)?.value {
            interstitial.rawValue.present(fromRootViewController: self)
        }

        if change.changedProperty(for: \.shouldShowAR)?.value == true {
            let vc = ARViewController()
            vc.modalTransitionStyle = .flipHorizontal
            present(vc, animated: true, completion: nil)
        }

        if let image = change.changedProperty(for: \.shouldPrepareAnimationWithImage)?.value {
            imageView.image = image
            imageViewCenterYConstraint.constant = 0
            selectImageButton.isEnabled = false
            saveImageButton.isEnabled = false
            saveGifButton.isEnabled = false

            dismiss(animated: true) { [weak self] in
                self?.presenter.startCapture()
            }
        }
    }
}
