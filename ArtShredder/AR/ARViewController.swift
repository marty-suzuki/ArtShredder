//
//  ARViewController.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/10/16.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import GoogleMobileAds

final class ARViewController: UIViewController {

    @IBOutlet private(set) weak var sceneView: ARSCNView!
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
    @IBOutlet private(set) weak var selectImageButton: UIButton! {
        didSet {
            let title = NSLocalizedString("select_to_add_art_title", comment: "")
            selectImageButton.setTitle(title, for: .normal)
            selectImageButton.isHidden = true
            selectImageButton.layer.borderWidth = 2
            selectImageButton.layer.borderColor = UIColor.white.cgColor
            selectImageButton.layer.cornerRadius = 4
            selectImageButton.layer.masksToBounds = true
        }
    }

    private lazy var bannerView: GADBannerView = {
        let view = GADBannerView(adSize: kGADAdSizeBanner)
        view.adUnitID = AdMobConfig.make().bannerAdID
        view.rootViewController = self
        view.delegate = self
        view.load(GADRequest())
        return view
    }()

    private weak var shredderNode: ARShredderNode? {
        didSet {
            shredderNode?.animationFinished = { [weak self] in
                DispatchQueue.main.async {
                    self?.selectImageButton.isHidden = false
                }
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.debugOptions = .showFeaturePoints

        _ = bannerView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }

    @IBAction private func doneTap(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func selectTap(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.modalPresentationStyle = .overFullScreen
            present(picker, animated: true, completion: nil)
        }
    }
}

extension ARViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        let semaphore = DispatchSemaphore(value: 1)
        DispatchQueue.main.async {
            if
                (anchor as? ARPlaneAnchor) != nil,
                self.shredderNode == nil,
                let node = self.sceneView.pointOfView {
                let shredderNode = ARShredderNode(node: node)
                self.sceneView.scene.rootNode.addChildNode(shredderNode)
                self.shredderNode = shredderNode
                self.sceneView.debugOptions = []
                self.selectImageButton.isHidden = false
            }
            semaphore.signal()
        }
        semaphore.wait()
    }
}

extension ARViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if
            let image = info[.originalImage] as? UIImage,
            let node = shredderNode
        {
            node.setImage(image)
        }

        dismiss(animated: true) { [weak self] in
            self?.shredderNode?.startAnimation()
            self?.selectImageButton.isHidden = true
        }
    }
}

extension ARViewController: GADBannerViewDelegate {
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
