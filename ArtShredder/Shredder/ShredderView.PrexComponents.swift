//
//  ShredderView.PrexComponents.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/12/07.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Prex
import UIKit
import GoogleMobileAds

enum Shredder {
    enum Action: Prex.Action {
        case setGifURL(URL?)
        case setIsCapturing(Bool)
        case setInterstitialForAR(GADInterstitial?)
        case setInterstitialForGIF(GADInterstitial?)
        case setInterstitial(Interstitial?)
        case setShouldShowAR(Bool)
        case shouldPrepareAnimationWithImage(UIImage?)
    }

    struct State: Prex.State {
        fileprivate(set) var gifURL: URL?
        fileprivate(set) var isCapturing = false
        fileprivate(set) var interstitialForAR: GADInterstitial?
        fileprivate(set) var interstitialForGIF: GADInterstitial?
        fileprivate(set) var interstitial: Interstitial?
        fileprivate(set) var shouldShowAR = false
        fileprivate(set) var shouldPrepareAnimationWithImage: UIImage?
    }

    struct Mutation: Prex.Mutation {
        func mutate(action: Action, state: inout State) {
            switch action {
            case let .setGifURL(url):
                state.gifURL = url
            case let .setIsCapturing(isCapturing):
                state.isCapturing = isCapturing
            case let .setInterstitialForAR(interstitial):
                state.interstitialForAR = interstitial
            case let .setInterstitialForGIF(interstitial):
                state.interstitialForGIF = interstitial
            case let .setInterstitial(interstitial):
                state.interstitial = interstitial
            case let .setShouldShowAR(shouldShowAR):
                state.shouldShowAR = shouldShowAR
            case let .shouldPrepareAnimationWithImage(image):
                state.shouldPrepareAnimationWithImage = image
            }
        }
    }

    enum Interstitial: Equatable {
        case saveGIF(GADInterstitial)
        case arMode(GADInterstitial)
    }
}

extension Shredder.Interstitial {
    var rawValue: GADInterstitial {
        switch self {
        case let .arMode(value),
             let .saveGIF(value):
            return value
        }
    }
}
