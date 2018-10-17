//
//  UIImage.extension.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/10/17.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit



extension UIImage: AdditionalCompatible {}


extension Additional where Base: UIImage {
    func fixedOrientation() -> UIImage {
        let imageOrientation = base.imageOrientation
        let size = base.size

        if imageOrientation == .up { return base }
        guard let cgImage = base.cgImage else { return base }

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
            else { return base }

        context.concatenate(transform)

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }

        return context.makeImage().map(UIImage.init) ?? base
    }
}
