//
//  ViewController.swift
//  Shuretta
//
//  Created by marty-suzuki on 2018/10/10.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit
import WebKit

final class ViewController: UIViewController {

    @IBOutlet private(set) weak var pictureSelectButton: UIButton!
    @IBOutlet private(set) weak var saveImageButton: UIButton! {
        didSet {
            saveImageButton.isEnabled = false
        }
    }
    @IBOutlet private(set) weak var bottomView: UIView!
    @IBOutlet private(set) weak var imageView: UIImageView!
    @IBOutlet private(set) weak var imageViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var containerView: UIView!
    @IBOutlet private(set) weak var linkButtonCoutainer: UIView! {
        didSet {
            linkButtonCoutainer.layer.cornerRadius = 10
            linkButtonCoutainer.layer.masksToBounds = true
        }
    }

    @IBAction private func selectPicture(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    @IBAction private func openURL(_ sender: UIButton) {
        let url = URL(string: "https://www.freeiconspng.com/img/24597")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @IBAction private func saveImage(_ sender: UIButton) {
        defer {
            saveImageButton.isHidden = false
            pictureSelectButton.isHidden = false
        }
        saveImageButton.isHidden = true
        pictureSelectButton.isHidden = true

        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return
        }
        view.layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return
        }
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(title: "Save done", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        imageViewCenterYConstraint.constant = 0
        pictureSelectButton.isEnabled = false
        saveImageButton.isEnabled = false

        dismiss(animated: true) { [weak self] in
            guard let me = self else { return }
            me.containerView.layoutIfNeeded()
            me.imageViewCenterYConstraint.constant = me.bottomView.frame.size.height
            UIView.animate(withDuration: 5, delay: 2, options: .curveEaseInOut, animations: {
                me.containerView.layoutIfNeeded()
            }) { _ in
                me.pictureSelectButton.isEnabled = true
                me.saveImageButton.isEnabled = true
            }
        }
    }
}
