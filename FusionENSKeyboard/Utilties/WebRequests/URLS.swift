//
//  URLS.swift
//  FusionENSKeyboard
//
//  Created by Franz Quarshie on 05/09/2025.
//

import Foundation

struct URLS{
    static let BASEURL = "https://api.ensideas.com/"
    static let ensResolve = BASEURL + "ens/resolve/"
    
    static func fusionNameResolver(name: String) -> String {
        return ensResolve + name
    }
    
    static func ensNameResolver(name: String) -> String {
        return ensResolve + name
    }
    
    static func unsNameResolver(name: String) -> String {
        return ensResolve + name
    }
}
