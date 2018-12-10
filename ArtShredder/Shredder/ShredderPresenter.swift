//
//  ShredderPresenter.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/12/07.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Prex
import UIKit
import GoogleMobileAds

final class ShredderPresenter: Presenter<Shredder.Action, Shredder.State> {

    private let screenToGIFManager: ScreenToGIFManager

    init<T: View>(view: T,
                  screenToGIFManager: ScreenToGIFManager = .init()) where T.State == Shredder.State {
        self.screenToGIFManager = screenToGIFManager
        super.init(view: view, flux: Flux(state: Shredder.State(), mutation: Shredder.Mutation()))
    }

    func createGIF() {
        screenToGIFManager.didCreateGIFWithURL = { [weak self] url in
            self?.dispatch(.setGifURL(url))
        }
        screenToGIFManager.createGIF()
    }

    func startCapture() {
        screenToGIFManager.startCapture { [weak self] _ in
            self?.dispatch(.setIsCapturing(true))
        }
    }

    func stopCapture() {
        screenToGIFManager.stopCapture()
        dispatch(.setIsCapturing(false))
    }

    func createAndLoadInterstitial(referer: InterstitialReferer, delegate: GADInterstitialDelegate) {
        let adUnitID: String
        switch referer {
        case .arMode:
            adUnitID = AdMobConfig.make().interstitial.arButtonAdID
        case .saveGIF:
            adUnitID = AdMobConfig.make().interstitial.gifButtonAdID
        }
        let interstitial = GADInterstitial(adUnitID: adUnitID)
        interstitial.delegate = delegate
        interstitial.load(GADRequest())

        switch referer {
        case .arMode:
            dispatch(.setInterstitialForAR(interstitial))
        case .saveGIF:
            dispatch(.setInterstitialForGIF(interstitial))
        }
    }

    func setInterstitial(_ interstitial: GADInterstitial, referer: InterstitialReferer) {
        switch referer {
        case .arMode:
            dispatch(.setInterstitial(.arMode(interstitial)))
        case .saveGIF:
            dispatch(.setInterstitial(.saveGIF(interstitial)))
        }
    }

    func clearInterstitial() {
        dispatch(.setInterstitial(nil))
    }

    func showAR() {
        dispatch(.setShouldShowAR(true))
        dispatch(.setShouldShowAR(false))
    }

    func prepareImageAnimation(with image: UIImage?) {
        dispatch(.shouldPrepareAnimationWithImage(image))
        dispatch(.shouldPrepareAnimationWithImage(nil))
    }
}

extension ShredderPresenter {
    enum InterstitialReferer {
        case saveGIF
        case arMode
    }
}
