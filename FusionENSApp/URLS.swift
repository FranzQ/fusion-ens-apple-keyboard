//
//  URLS.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 17/09/2025.
//

import Foundation

/// URL configuration for ENS resolution APIs
/// Provides endpoints for Fusion API and ENSData API
struct URLS {
    static let FUSION_BASEURL = "https://api.fusionens.com/"
    static let ENSDATA_BASEURL = "https://api.ensdata.net/"
    static let fusionResolve = FUSION_BASEURL + "resolve/"
    static let ensDataResolve = ENSDATA_BASEURL
    
    static func fusionNameResolver(name: String) -> String {
        return fusionResolve + name
    }
    
    
    static func ensDataResolver(name: String) -> String {
        return ensDataResolve + name
    }
    
    static func ensNameResolver(name: String) -> String {
        return fusionResolve + name
    }
    
    static func unsNameResolver(name: String) -> String {
        return fusionResolve + name
    }
}
