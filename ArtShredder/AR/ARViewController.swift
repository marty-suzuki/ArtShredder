//
//  ARViewController.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/10/16.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

final class ARViewController: UIViewController {

    @IBOutlet private(set) var sceneView: ARSCNView!

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.debugOptions = .showFeaturePoints
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }

    @IBAction private func buttonTap(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.modalPresentationStyle = .overFullScreen
            present(picker, animated: true, completion: nil)
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user

    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay

    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required

    }
}

extension ARViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

    }
}

extension ARViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private func addImageNode(with image: UIImage) {
        guard let camera = sceneView.pointOfView else {
            return
        }

        let position = camera.convertPosition(SCNVector3(x: 0, y: 0, z: -0.5), to: nil)
        let size = CGSize(width: 514, height: 743)
        let node = SCNNode()
        let scale: CGFloat = 0.3
        let geometry = SCNPlane(width: size.width * scale / size.height, height: scale)

        let shredderLayer = ARShredderLayer()
        shredderLayer.setImage(image)

        [shredderLayer.baseImageLayer, shredderLayer.shredImageLayer].forEach {
            let animation = CABasicAnimation(keyPath: "transform.translation.y")
            animation.duration = 5
            animation.beginTime = CACurrentMediaTime() + 2
            animation.fromValue = 0
            animation.toValue = -232
            animation.isRemovedOnCompletion = false
            animation.fillMode = .forwards
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            $0.add(animation, forKey: "move")
        }

        let material = SCNMaterial()
        material.diffuse.contents = shredderLayer
        geometry.materials = [material]
        node.geometry = geometry
        node.position = position

        sceneView.scene.rootNode.addChildNode(node)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        picker.dismiss(animated: true) { [weak self] in
            guard
                let me = self,
                let image = info[.originalImage] as? UIImage
            else { return }
            me.addImageNode(with: image)
        }
    }
}
