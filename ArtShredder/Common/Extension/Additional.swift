//
//  Additional.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/10/17.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

struct Additional<Base> {
    let base: Base
}

protocol AdditionalCompatible {
    associatedtype Base = Self
    static var additional: Additional<Base>.Type { get }
    var additional: Additional<Base> { get }
}

extension AdditionalCompatible where Base == Self {
    static var additional: Additional<Self>.Type {
        return Additional<Self>.self
    }

    var additional: Additional<Self> {
        return Additional(base: self)
    }
}
