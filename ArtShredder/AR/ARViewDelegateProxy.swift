//
//  ARViewDelegateProxy.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/10/19.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import ARKit
import GoogleMobileAds
import SceneKit
import UIKit

final class ARViewDelegateProxy: NSObject {
    private let presenter: ARPresenter
    private let pointOfView: () -> SCNNode?

    init(presenter: ARPresenter, pointOfView: @escaping () -> SCNNode?) {
        self.presenter = presenter
        self.pointOfView = pointOfView
    }
}

extension ARViewDelegateProxy: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        presenter.setImage(info[.originalImage] as? UIImage)

        picker.dismiss(animated: true) { [weak self] in
            self?.presenter.startAnimation()
        }
    }
}

extension ARViewDelegateProxy: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        let semaphore = DispatchSemaphore(value: 1)
        DispatchQueue.main.async {
            if
                (anchor as? ARPlaneAnchor) != nil,
                self.presenter.shredderNode == nil,
                let node = self.pointOfView()
            {
                let shredderNode = ARShredderNode(node: node)
                self.presenter.setShredderNode(shredderNode)
            }
            semaphore.signal()
        }
        semaphore.wait()
    }
}

extension ARViewDelegateProxy: GADBannerViewDelegate {
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
