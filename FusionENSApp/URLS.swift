//
//  URLS.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 17/09/2025.
//

import Foundation

/// URL configuration for ENS resolution APIs
/// Provides endpoints for both Fusion API and ENS Ideas API
struct URLS {
    static let FUSION_BASEURL = "https://api.fusionens.com/"
    static let ENSIDEAS_BASEURL = "https://api.ensideas.com/"
    static let fusionResolve = FUSION_BASEURL + "resolve/"
    static let ensIdeasResolve = ENSIDEAS_BASEURL + "ens/resolve/"
    
    static func fusionNameResolver(name: String) -> String {
        return fusionResolve + name
    }
    
    static func ensIdeasResolver(name: String) -> String {
        return ensIdeasResolve + name
    }
    
    static func ensNameResolver(name: String) -> String {
        return fusionResolve + name
    }
    
    static func unsNameResolver(name: String) -> String {
        return fusionResolve + name
    }
}
