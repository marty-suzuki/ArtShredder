//
//  SettingView.PrexComponets.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/10/27.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Prex

enum Setting {
    private enum Const {
        static let frameWebSiteURL = "https://www.freeiconspng.com/img/24597"
    }

    enum Action: Prex.Action {
        case openURL(URLType?)
    }

    struct State: Prex.State {
        let frameDescription: String = {
            let localized = LocalizedString.frameDescription
            return String(format: localized, Const.frameWebSiteURL)
        }()

        let version: String = {
            let version = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown"
            return "Version: \(version)"
        }()

        let supportTitle = LocalizedString.supprotTitle
        fileprivate(set) var openURL: URL?
    }

    struct Mutation: Prex.Mutation {
        func mutate(action: Action, state: inout State) {
            switch action {
            case let .openURL(value):
                state.openURL = value.flatMap { URL(string: $0.url) }
            }
        }
    }
}

extension Setting.Action {
    enum URLType {
        case frameWebSite
        case supportPage
        case prex
        case googleMobleAdsSDK

        fileprivate var url: String {
            switch self {
            case .frameWebSite:
                return Setting.Const.frameWebSiteURL
            case .supportPage:
                return LocalizedString.supportURL
            case .prex:
                return "https://github.com/marty-suzuki/Prex"
            case .googleMobleAdsSDK:
                return "https://cocoapods.org/pods/Google-Mobile-Ads-SDK"
            }
        }
    }
}
