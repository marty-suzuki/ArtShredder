//
//  Secret.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/10/12.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

extension AdMobConfig {
    static func make() -> AdMobConfig {
        return AdMobConfig(appID: "",
                           interstitial: Interstitial(gifButtonAdID: "",
                                                      arButtonAdID: ""),
                           banner: Banner(normalBottomAdID: "",
                                          arBottomAdID: "")
        )
    }
}
