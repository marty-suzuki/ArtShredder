//
//  ARPrexComponent.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/10/19.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Prex
import UIKit

enum AR {
    enum Action: Prex.Action {
        case setShredderNode(ARShredderNode?)
        case setImage(UIImage)
        case startAnimation
        case setIsImageSelectHidden(Bool)
    }

    struct State: Prex.State {
        fileprivate(set) weak var shredderNode: ARShredderNode?
        fileprivate(set) var isImageSelectHidden = true
    }

    struct Mutation: Prex.Mutation {
        func mutate(action: Action, state: inout State) {
            switch action {
            case let .setShredderNode(node):
                state.shredderNode = node

            case let .setImage(image):
                state.shredderNode?.setImage(image)

            case .startAnimation:
                state.shredderNode?.startAnimation()

            case let .setIsImageSelectHidden(isHidden):
                state.isImageSelectHidden = isHidden
            }
        }
    }
}
