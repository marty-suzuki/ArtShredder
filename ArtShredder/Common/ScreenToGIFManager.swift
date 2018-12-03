//
//  ScreenToGIFManager.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/12/04.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

final class ScreenToGIFManager {

    var didCreateGIFWithURL: ((URL?) -> ())?

    private let gifMaker: GIFMakerType
    private let screenCaptureManager: ScreenCaptureManagerType

    init(gifMaker: GIFMakerType = GIFMaker(),
         screenCaptureManager: ScreenCaptureManagerType = ScreenRecorderManager()) {
        self.gifMaker = gifMaker
        self.screenCaptureManager = screenCaptureManager

        gifMaker.didCreateGIFWithURL = { [weak self] in
            self?.didCreateGIFWithURL?($0)
        }
    }

    func startCapture(completion: ((Error?) -> ())? = nil) {
        screenCaptureManager.startCapture(completion: completion)
    }

    func stopCapture(failure: ((Error) -> ())? = nil) {
        screenCaptureManager.stopCapture(failure: failure)
    }

    func createGIF() {
        guard let imageHolder = screenCaptureManager.createImageHolder() else {
            didCreateGIFWithURL?(nil)
            return
        }
        gifMaker.create(with: imageHolder)
    }
}
