//
//  GIFMaker.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/12/04.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import CoreImage
import Foundation
import MobileCoreServices
import UIKit

protocol GIFMakerType: AnyObject {
    var didCreateGIFWithURL: ((URL?) -> ())? { get set }
    func create(with imageHolder: ImageHolder)
}

final class GIFMaker: GIFMakerType {

    var didCreateGIFWithURL: ((URL?) -> ())?

    private let queue: DispatchQueue

    init(queue: DispatchQueue = .global()) {
        self.queue = queue
    }

    func create(with imageHolder: ImageHolder) {
        queue.async { [weak self] in
            let images = imageHolder.images
            let filename = imageHolder.filename

            guard
                let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename),
                let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeGIF, images.count, nil)
            else {
                self?.didCreateGIFWithURL?(nil)
                return
            }

            let delay = imageHolder.delay

            let properties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]
            CGImageDestinationSetProperties(destination, properties as CFDictionary)

            let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: delay]]
            for image in images {
                if let cgImage = image.cgImage {
                    CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
                }
            }

            guard CGImageDestinationFinalize(destination) else {
                self?.didCreateGIFWithURL?(nil)
                return
            }

            self?.didCreateGIFWithURL?(url)
        }
    }
}

struct ImageHolder {
    let images: [UIImage]
    let delay: TimeInterval
    let filename: String
}
