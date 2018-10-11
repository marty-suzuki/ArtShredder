//
//  ViewController.swift
//  Shuretta
//
//  Created by marty-suzuki on 2018/10/10.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit
import WebKit
import MobileCoreServices
import GoogleMobileAds

final class ViewController: UIViewController {

    @IBOutlet private(set) weak var pictureSelectButton: UIButton!
    @IBOutlet private(set) weak var saveImageButton: UIButton! {
        didSet {
            saveImageButton.isEnabled = false
        }
    }
    @IBOutlet private(set) weak var saveGifButton: UIButton! {
        didSet {
            saveGifButton.isEnabled = false
        }
    }
    @IBOutlet private(set) weak var bottomView: UIView!
    @IBOutlet private(set) weak var imageView: UIImageView!
    @IBOutlet private(set) weak var imageViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var containerView: UIView!
    @IBOutlet private(set) weak var linkButtonCoutainer: UIView! {
        didSet {
            linkButtonCoutainer.layer.cornerRadius = 10
            linkButtonCoutainer.layer.masksToBounds = true
        }
    }

    private var timer: Timer?
    private var images: [UIImage] = []

    private lazy var interstitial = createAndLoadInterstitial()

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = interstitial
    }

    private func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: AdMobConfig.make().interstitialTestAdID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }

    @IBAction private func selectPicture(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    @IBAction private func openURL(_ sender: UIButton) {
        let url = URL(string: "https://www.freeiconspng.com/img/24597")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @IBAction private func saveImage(_ sender: UIButton) {
        defer {
            saveImageButton.isHidden = false
            pictureSelectButton.isHidden = false
        }
        saveImageButton.isHidden = true
        pictureSelectButton.isHidden = true

        guard let image = snapshot() else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(title: "Save done", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    override var prefersStatusBarHidden: Bool {
        return true
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
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            interstitial = createAndLoadInterstitial()
        }
    }

    private func createGIF() {
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("sample.gif")!
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeGIF, images.count, nil) else {
            print("CGImageDestinationの作成に失敗")
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

        if CGImageDestinationFinalize(destination) {
            print("GIF生成が成功")
        } else {
            print("GIF生成に失敗")
        }

        let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        imageViewCenterYConstraint.constant = 0
        pictureSelectButton.isEnabled = false
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
                    me.pictureSelectButton.isEnabled = true
                    me.saveImageButton.isEnabled = true
                    me.saveGifButton.isEnabled = true
                }
            }
        }
    }
}

extension ViewController: GADInterstitialDelegate {
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
        interstitial = createAndLoadInterstitial()
        createGIF()
    }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
}
