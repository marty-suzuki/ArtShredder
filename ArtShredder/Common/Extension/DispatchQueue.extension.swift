//
//  DispatchQueue.extension.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/12/03.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

extension DispatchQueue: AdditionalCompatible {}

extension Additional where Base: DispatchQueue {
    func throttle(delay: DispatchTimeInterval) -> (_ action: @escaping () -> ()) -> () {
        var lastFireTime: DispatchTime = .now()

        return { [weak base, delay] action in
            let deadline: DispatchTime = .now() + delay
            base?.asyncAfter(deadline: deadline) { [delay] in
                let now: DispatchTime = .now()
                let when: DispatchTime = lastFireTime + delay
                if now < when { return }
                lastFireTime = .now()
                action()
            }
        }
    }
}
