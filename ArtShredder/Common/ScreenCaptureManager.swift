//
//  ScreenCaptureManager.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/12/03.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import CoreMedia
import CoreImage
import UIKit

protocol ScreenCaptureManagerType: AnyObject {
    var images: [UIImage] { get }
    func startCapture(completion: ((Error?) -> ())?)
    func stopCapture(failure: ((Error) -> ())?)
    func createImageHolder() -> ImageHolder?
}

extension ScreenCaptureManagerType {
    func startCapture() {
        startCapture(completion: nil)
    }

    func stopCapture() {
        stopCapture(failure: nil)
    }
}

/// ReplayKit based ScreenCaptureManager
final class ScreenRecorderManager: ScreenCaptureManagerType {

    private let recorder: ScreenRecorderType

    private(set) var images: [UIImage] = []
    private let serialQueue = DispatchQueue(label: "serial-queue")
    private lazy var throttleHandler = serialQueue.additional.throttle(delay: .milliseconds(50))

    init(recorder: ScreenRecorderType = ScreenRecorder()) {
        self.recorder = recorder
    }

    func startCapture(completion: ((Error?) -> ())? = nil) {
        images.removeAll()

        recorder.startCapture(handler: { [weak self] buffer, type, error in

            self?.throttleHandler {
                guard
                    let me = self,
                    type == .video,
                    let imageBuffer = CMSampleBufferGetImageBuffer(buffer)
                else {
                    return
                }

                CVPixelBufferLockBaseAddress(imageBuffer, [])

                let ciImage = CIImage(cvImageBuffer: imageBuffer)
                    .transformed(by: CGAffineTransform(scaleX: 0.25, y: 0.25))
                let context = CIContext(options: nil)

                guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                    return
                }

                let image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)

                CVPixelBufferUnlockBaseAddress(imageBuffer, [])

                me.images.append(image)
            }

        }, completionHandler: completion)
    }

    func stopCapture(failure: ((Error) -> ())? = nil) {
        recorder.stopCapture { error in
            if let error = error {
                failure?(error)
            }
        }
    }

    func createImageHolder() -> ImageHolder? {
        guard images.count > 0 else {
            return nil
        }
        return ImageHolder(images: images,
                           delay: 0.05,
                           filename: "sample.gif")
    }
}

/// UIGraphics based ScreenCaptureManager
final class ScreenshotManager: ScreenCaptureManagerType {

    private(set) var images: [UIImage] = []
    private var timer: Timer?

    private lazy var view: UIView = {
        return UIApplication.shared.delegate?.window??.rootViewController?.view ??
            { fatalError("view is nil") }()
    }()

    init(view: UIView? = nil) {
        if let view = view {
            self.view = view
        }
    }

    func startCapture(completion: ((Error?) -> ())? = nil) {
        images.removeAll()

        timer = Timer.scheduledTimer(timeInterval: 0.05,
                                     target: self,
                                     selector: #selector(self.timerHandler(_:)),
                                     userInfo: nil,
                                     repeats: true)

        completion?(nil)
    }

    func stopCapture(failure: ((Error) -> ())? = nil) {
        timer?.invalidate()
        timer = nil
    }

    @objc private func timerHandler(_ timer: Timer) {
        DispatchQueue.main.async {
            let size = self.view.bounds.size
            guard let image = self.snapshot(size: CGSize(width: size.width / 2, height: size.height / 2), scale: 1.0) else {
                return
            }
            self.images += [image]
        }
    }

    private func snapshot(size: CGSize? = nil, scale: CGFloat = 0.0) -> UIImage? {
        let _size = size ?? view.bounds.size
        let _rect = size.map { CGRect(x: 0, y: 0, width: $0.width, height: $0.height) } ?? view.bounds

        UIGraphicsBeginImageContextWithOptions(_size, false, scale)
        view.drawHierarchy(in: _rect, afterScreenUpdates: false)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        return image
    }

    func createImageHolder() -> ImageHolder? {
        guard images.count > 0 else {
            return nil
        }
        return ImageHolder(images: images,
                           delay: 0.2,
                           filename: "sample.gif")
    }
}
