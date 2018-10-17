//
//  ARShredderNode.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/10/17.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import ARKit
import SceneKit
import QuartzCore

final class ARShredderNode: SCNNode {

    private enum Const {
        static let animationKey = "shredderLayer.imageLayer.transform.translation.y"
        static let animationKeyPath = "transform.translation.y"
    }

    let shredderLayer = ARShredderLayer()

    var animationFinished: (() -> ())?

    init(node: SCNNode) {
        super.init()

        let size = CGSize(width: 514, height: 743)
        let scale: CGFloat = 0.3
        let geometry = SCNPlane(width: size.width * scale / size.height, height: scale)

        let material = SCNMaterial()
        material.diffuse.contents = shredderLayer
        geometry.materials = [material]

        self.geometry = geometry
        self.position = node.convertPosition(SCNVector3(x: 0, y: 0, z: -0.5), to: nil)
    }

    init(anchor: ARPlaneAnchor) {
        super.init()

        let size = CGSize(width: 514, height: 743)
        let scale: CGFloat = 0.3
        let geometry = SCNPlane(width: size.width * scale / size.height, height: scale)

        let material = SCNMaterial()
        material.diffuse.contents = shredderLayer
        geometry.materials = [material]

        self.geometry = geometry
        self.transform = SCNMatrix4MakeRotation(-.pi / 2, 1, 0, 0)

        update(anchor: anchor)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setImage(_ image: UIImage) {
        [shredderLayer.baseImageLayer, shredderLayer.shredImageLayer].forEach {
            $0.removeAnimation(forKey: Const.animationKey)
        }
        shredderLayer.shredImageLayer.frame.origin.y = 232
        shredderLayer.baseImageLayer.frame.origin.y = 0
        shredderLayer.setImage(image)
    }

    func startAnimation() {
        [shredderLayer.baseImageLayer, shredderLayer.shredImageLayer].forEach {
            $0.removeAnimation(forKey: Const.animationKey)
            let animation = CABasicAnimation(keyPath: Const.animationKeyPath)
            animation.duration = 5
            animation.beginTime = CACurrentMediaTime() + 2
            animation.fromValue = 0
            animation.toValue = -232
            animation.isRemovedOnCompletion = false
            animation.fillMode = .forwards
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.delegate = self
            $0.add(animation, forKey: Const.animationKey)
        }
    }

    func update(anchor: ARPlaneAnchor) {
        position = SCNVector3Make(anchor.center.x, anchor.transform.columns.3.y, anchor.center.z)
    }
}

extension ARShredderNode: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard
            flag,
            let animation = anim as? CABasicAnimation,
            animation.keyPath == Const.animationKeyPath
        else {
            return
        }
        animationFinished?()
    }
}
