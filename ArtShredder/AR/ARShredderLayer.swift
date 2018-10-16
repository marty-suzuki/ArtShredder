//
//  ARShredderLayer.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/10/17.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit

final class ARShredderLayer: CALayer {
    private let frameImageLayer: CALayer = {
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 155, width: 414, height: 488)
        layer.contents = UIImage(named: "frame")?.cgImage
        return layer
    }()

    private let baseLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        layer.masksToBounds = true
        layer.frame = CGRect(x: 70, y: 233, width: 273, height: 332)
        return layer
    }()

    let baseImageLayer = AspectFillImageLayer()

    private let shredBaseLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.masksToBounds = true
        layer.frame = CGRect(x: 70, y: 0, width: 273, height: 564)
        return layer
    }()

    let shredImageLayer: AspectFillImageLayer = {
        let layer = AspectFillImageLayer()
        layer.frame.origin.y = 232
        return layer
    }()

    override init() {
        super.init()
        frame = CGRect(x: 0, y: 0, width: 414, height: 643)
        masksToBounds = false

        backgroundColor = UIColor.clear.cgColor

        let maskLayer = CAShapeLayer()
        maskLayer.path = {
            let path = UIBezierPath()

            (0..<20).forEach { num in
                let _path = UIBezierPath(rect: CGRect(x: CGFloat(num) * 13.65, y: 0, width: 11, height: 564))
                path.append(_path)
            }
            path.close()

            return path.cgPath
        }()
        maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.frame = shredImageLayer.bounds

        shredImageLayer.mask = maskLayer

        addSublayer(shredBaseLayer)
        shredBaseLayer.addSublayer(shredImageLayer)
        addSublayer(baseLayer)
        baseLayer.addSublayer(baseImageLayer)
        addSublayer(frameImageLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setImage(_ image: UIImage) {
        let fixedImage = image.fixedOrientation()
        baseImageLayer.setImage(fixedImage)
        shredImageLayer.setImage(fixedImage)
    }
}

final class AspectFillImageLayer: CALayer {

    private let initialSize = CGSize(width: 273, height: 332)

    private let imageLayer = CALayer()

    override init() {
        super.init()
        frame.size = initialSize
        imageLayer.frame.size = initialSize
        masksToBounds = true
        addSublayer(imageLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setImage(_ image: UIImage) {
        let size = image.size
        imageLayer.frame.size = initialSize
        let layerSize = imageLayer.frame.size

        if size.height > size.width {
            let relativeHeight = (layerSize.width / size.width) * size.height
            let delta = abs(relativeHeight - layerSize.height) / 2
            imageLayer.frame.origin.y = -delta
            imageLayer.frame.size.height = relativeHeight
        } else {
            let relativeWidth = (layerSize.height / size.height) * size.width
            let delta = abs(relativeWidth - layerSize.width) / 2
            imageLayer.frame.origin.x = -delta
            imageLayer.frame.size.width = relativeWidth
        }

        imageLayer.contents = image.cgImage
    }
}

extension UIImage {

    func fixedOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        guard let cgImage = self.cgImage else { return self }

        var transform: CGAffineTransform = CGAffineTransform.identity

        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        }

        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        }

        guard
            let space = cgImage.colorSpace,
            let context = CGContext(data: nil,
                                    width: Int(size.width),
                                    height: Int(size.height),
                                    bitsPerComponent: cgImage.bitsPerComponent,
                                    bytesPerRow: 0,
                                    space: space,
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            else { return self }

        context.concatenate(transform)

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }

        return context.makeImage().map(UIImage.init) ?? self
    }
}
