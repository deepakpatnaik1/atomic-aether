//
//  ConfigBusConfiguration.swift
//  atomic-aether
//
//  Configuration model for ConfigBus behavior
//

import Foundation

struct ConfigBusConfiguration: Codable {
    let defaultBundleIdentifier: String
    let enableHotReload: Bool
    let fileExtension: String
    
    static let `default` = ConfigBusConfiguration(
        defaultBundleIdentifier: "com.aether.configbus",
        enableHotReload: true,
        fileExtension: "json"
    )
}