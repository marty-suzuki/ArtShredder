//
//  ScreenRecorder.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/12/03.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import ReplayKit

protocol ScreenRecorderType: AnyObject {
    func startCapture(handler captureHandler: ((CMSampleBuffer, RPSampleBufferType, Error?) -> Void)?,
                      completionHandler: ((Error?) -> Void)?)
    func stopCapture(handler: ((Error?) -> Void)?)
}

extension ScreenRecorderType {
    func startCapture(handler captureHandler: ((CMSampleBuffer, RPSampleBufferType, Error?) -> Void)?) {
        startCapture(handler: captureHandler, completionHandler: nil)
    }

    func stopCapture() {
        stopCapture(handler: nil)
    }
}

final class ScreenRecorder: ScreenRecorderType {

    private let recorder: RPScreenRecorder

    init(isMicrophoneEnabled: Bool = false,
         isCameraEnabled: Bool = false,
         recorder: RPScreenRecorder = .shared()) {
        self.recorder = recorder
        recorder.isMicrophoneEnabled = isMicrophoneEnabled
        recorder.isCameraEnabled = isCameraEnabled
    }

    func startCapture(handler captureHandler: ((CMSampleBuffer, RPSampleBufferType, Error?) -> Void)?,
                      completionHandler: ((Error?) -> Void)? = nil) {
        if recorder.isRecording {
            return
        }
        recorder.startCapture(handler: captureHandler,
                              completionHandler: completionHandler)
    }

    func stopCapture(handler: ((Error?) -> Void)? = nil) {
        if recorder.isRecording {
            recorder.stopCapture(handler: handler)
        }
    }
}
