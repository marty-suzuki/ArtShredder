//
//  SettingPresenter.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/10/27.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Prex
import UIKit

final class SettingPresenter: Presenter<Setting.Action, Setting.State> {

    convenience init<T: View>(view: T) where T.State == Setting.State {
        self.init(view: view, state: Setting.State(), mutation: Setting.Mutation())
    }

    func openURL(_ urlType: Setting.Action.URLType) {
        dispatch(.openURL(urlType))
        dispatch(.openURL(nil))
    }
}
