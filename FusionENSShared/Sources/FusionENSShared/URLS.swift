//
//  URLS.swift
//  FusionENSShared
//
//  Created by Franz Quarshie on 17/09/2025.
//

import Foundation

/// URL configuration for ENS resolution APIs
/// Provides endpoints for both Fusion API and ENS Ideas API
public struct URLS {
    public static let FUSION_BASEURL = "https://api.fusionens.com/"
    public static let ENSIDEAS_BASEURL = "https://api.ensideas.com/"
    public static let fusionResolve = FUSION_BASEURL + "resolve/"
    public static let ensIdeasResolve = ENSIDEAS_BASEURL + "ens/resolve/"
    
    public static func fusionNameResolver(name: String) -> String {
        return fusionResolve + name
    }
    
    public static func ensIdeasResolver(name: String) -> String {
        return ensIdeasResolve + name
    }
    
    public static func ensNameResolver(name: String) -> String {
        return fusionResolve + name
    }
    
    public static func unsNameResolver(name: String) -> String {
        return fusionResolve + name
    }
}
