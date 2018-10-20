//
//  ARPresenter.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/10/19.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Prex
import UIKit

final class ARPresenter: Presenter<AR.Action, AR.State> {

    var shredderNode: ARShredderNode? {
        return state.shredderNode
    }

    convenience init<T: View>(view: T) where T.State == AR.State {
        self.init(view: view, state: AR.State(), mutation: AR.Mutation())
    }

    func setShredderNode(_ node: ARShredderNode) {
        dispatch(.setIsImageSelectHidden(false))
        dispatch(.setShredderNode(node))
        node.animationFinished = { [weak self] in
            self?.dispatch(.setIsImageSelectHidden(false))
        }
    }

    func setImage(_ image: UIImage?) {
        if let image = image {
            dispatch(.setIsImageSelectHidden(true))
            dispatch(.setImage(image))
        }
    }

    func startAnimation() {
        dispatch(.startAnimation)
    }
}
