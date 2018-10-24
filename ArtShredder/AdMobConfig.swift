//
//  AdMobConfig.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/10/12.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

struct AdMobConfig {
    let appID: String
    let interstitial: Interstitial
    let banner: Banner
}

extension AdMobConfig {
    struct Interstitial {
        let gifButtonAdID: String
        let arButtonAdID: String
    }

    struct Banner {
        let normalBottomAdID: String
        let arBottomAdID: String
    }
}
