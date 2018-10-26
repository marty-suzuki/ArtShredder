//
//  ShredderViewController.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/10/27.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

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
        view.delegate = self
        view.load(GADRequest())
        return view
    }()

    private var timer: Timer?
    private var images: [UIImage] = []
    private var interstitialReferer: InterstitialReferer?

    private lazy var interstitialForAR = createAndLoadInterstitial(referer: .arMode)
    private lazy var interstitialForGIF = createAndLoadInterstitial(referer: .saveGIF)

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

        _ = interstitialForAR
        _ = interstitialForGIF
        _ = bannerView
    }

    private func createAndLoadInterstitial(referer: InterstitialReferer) -> GADInterstitial {
        let adUnitID: String
        switch referer {
        case .arMode:
            adUnitID = AdMobConfig.make().interstitial.arButtonAdID
        case .saveGIF:
            adUnitID = AdMobConfig.make().interstitial.gifButtonAdID
        }
        let interstitial = GADInterstitial(adUnitID: adUnitID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
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
                picker.delegate = self
                self?.present(picker, animated: true, completion: nil)
            })

            let cameraRollTitle = LocalizedString.imageSourceSelectCameraRoll
            alert.addAction(UIAlertAction(title: cameraRollTitle, style: .default) { [weak self] _ in
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self?.present(picker, animated: true, completion: nil)
            })

            let cancelTitle = LocalizedString.cancelAction
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
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

    @objc private func timerHandler(_ timer: Timer) {
        DispatchQueue.main.async {
            let size = self.view.bounds.size
            guard let image = self.snapshot(size: CGSize(width: size.width / 2, height: size.height / 2), scale: 1.0) else {
                return
            }
            self.images += [image]
        }
    }

    @IBAction func saveGif(_ sender: UIButton) {
        if interstitialForGIF.isReady {
            interstitialReferer = .saveGIF
            interstitialForGIF.present(fromRootViewController: self)
        } else {
            createGIF()
            interstitialForGIF = createAndLoadInterstitial(referer: .saveGIF)
        }
    }

    @IBAction func arButtonTap(_ sender: UIButton) {
        if interstitialForAR.isReady {
            interstitialReferer = .arMode
            interstitialForAR.present(fromRootViewController: self)
        } else {
            showAR()
            interstitialForAR = createAndLoadInterstitial(referer: .arMode)
        }
    }

    @IBAction func settingButtonTap(_ sender: UIButton) {
        let vc = SettingViewController()
        let nc = UINavigationController(rootViewController: vc)
        nc.modalTransitionStyle = .flipHorizontal
        present(nc, animated: true, completion: nil)
    }

    private func showAR() {
        let vc = ARViewController()
        vc.modalTransitionStyle = .flipHorizontal
        present(vc, animated: true, completion: nil)
    }

    private func createGIF() {
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("sample.gif")!
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeGIF, images.count, nil) else {
            // CGImageDestinationの作成に失敗
            return
        }

        let properties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]
        CGImageDestinationSetProperties(destination, properties as CFDictionary)

        let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 0.2]]
        for image in images {
            if let cgImage = image.cgImage {
                CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
            }
        }

        guard CGImageDestinationFinalize(destination) else {
            // GIF生成に失敗
            return
        }

        let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
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
}

extension ShredderViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        imageViewCenterYConstraint.constant = 0
        selectImageButton.isEnabled = false
        saveImageButton.isEnabled = false
        saveGifButton.isEnabled = false

        dismiss(animated: true) { [weak self] in
            guard let me = self else { return }

            me.containerView.layoutIfNeeded()
            me.imageViewCenterYConstraint.constant = me.bottomView.frame.size.height

            me.images.removeAll()
            me.timer = Timer.scheduledTimer(timeInterval: 0.05, target: me, selector: #selector(me.timerHandler(_:)), userInfo: nil, repeats: true)

            UIView.animate(withDuration: 5, delay: 2, options: .curveEaseInOut, animations: {
                me.containerView.layoutIfNeeded()
            }) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    me.timer?.invalidate()
                    me.timer = nil
                    me.selectImageButton.isEnabled = true
                    me.saveImageButton.isEnabled = true
                    me.saveGifButton.isEnabled = true
                }
            }
        }
    }
}

extension ShredderViewController: GADInterstitialDelegate {
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }

    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }

    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")

        switch interstitialReferer {
        case .saveGIF?:
            interstitialForGIF = createAndLoadInterstitial(referer: .saveGIF)
            createGIF()
        case .arMode?:
            interstitialForAR = createAndLoadInterstitial(referer: .arMode)
            showAR()
        case .none:
            interstitialForGIF = createAndLoadInterstitial(referer: .saveGIF)
            interstitialForAR = createAndLoadInterstitial(referer: .arMode)
        }
        interstitialReferer = nil
    }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
}

extension ShredderViewController: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}

extension ShredderViewController {
    private enum InterstitialReferer {
        case saveGIF
        case arMode
    }
}

