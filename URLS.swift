//
//  URLS.swift
//  FusionENSShared
//
//  Created by Franz Quarshie on 17/09/2025.
//

import Foundation

/// URL configuration for ENS resolution APIs
/// Provides endpoints for Fusion API and ENSData API
public struct URLS {
    public static let FUSION_BASEURL = "https://api.fusionens.com/"
    public static let ENSDATA_BASEURL = "https://api.ensdata.net/"
    public static let fusionResolve = FUSION_BASEURL + "resolve/"
    public static let ensDataResolve = ENSDATA_BASEURL
    
    public static func fusionNameResolver(name: String) -> String {
        return fusionResolve + name
    }
    
    public static func ensDataResolver(name: String) -> String {
        return ensDataResolve + name
    }
    
    public static func ensNameResolver(name: String) -> String {
        return fusionResolve + name
    }
    
    public static func unsNameResolver(name: String) -> String {
        return fusionResolve + name
    }
}
