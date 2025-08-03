//
//  ConfigBus.swift
//  atomic-aether
//
//  ATOM 6: ConfigBus - Simple configuration with hot-reloading
//
//  Loads JSON configs from bundle and watches for changes
//  That's it. No abstractions, no protocols, just works.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class ConfigBus: ObservableObject {
    
    // MARK: - Properties
    
    private var fileMonitors: [String: DispatchSourceFileSystemObject] = [:]
    private let queue: DispatchQueue
    
    // Publishers for each config
    @Published var configs: [String: Any] = [:]
    
    // MARK: - Initialization
    
    init() {
        // Try to load ConfigBus config for queue label
        let defaultIdentifier = "com.aether.configbus"
        var queueLabel = Bundle.main.bundleIdentifier ?? defaultIdentifier
        
        // Try to load our own config (bootstrap loading)
        if let url = Bundle.main.url(forResource: "ConfigBus", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let configuredDefault = json["defaultBundleIdentifier"] as? String {
            queueLabel = Bundle.main.bundleIdentifier ?? configuredDefault
        }
        
        self.queue = DispatchQueue(label: "\(queueLabel).configbus")
    }
    
    // MARK: - Load Configuration
    
    func load<T: Codable>(_ name: String, as type: T.Type) -> T? {
        // Try cache first
        if let cached = configs[name] as? T {
            return cached
        }
        
        // Load from bundle
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            // Config file not found
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(type, from: data)
            configs[name] = config
            
            // Start watching
            watchFile(url, configName: name, type: type)
            
            return config
        } catch {
            // Failed to decode config
            return nil
        }
    }
    
    // MARK: - Hot Reloading
    
    private func watchFile<T: Codable>(_ url: URL, configName: String, type: T.Type) {
        // Stop existing monitor
        stopWatching(configName)
        
        // Open file for monitoring
        let fileDescriptor = open(url.path, O_EVTONLY)
        guard fileDescriptor != -1 else { return }
        
        // Create dispatch source
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: queue
        )
        
        source.setEventHandler { [weak self] in
            // Reload on change
            DispatchQueue.main.async {
                self?.reload(configName, as: type)
            }
        }
        
        source.setCancelHandler {
            close(fileDescriptor)
        }
        
        fileMonitors[configName] = source
        source.resume()
    }
    
    private func reload<T: Codable>(_ name: String, as type: T.Type) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else { return }
        
        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(type, from: data)
            configs[name] = config
            objectWillChange.send()
            // Config reloaded successfully
        } catch {
            // Reload failed - silent failure
        }
    }
    
    private func stopWatching(_ configName: String) {
        fileMonitors[configName]?.cancel()
        fileMonitors.removeValue(forKey: configName)
    }
    
    // MARK: - Cleanup
    
    deinit {
        fileMonitors.values.forEach { $0.cancel() }
    }
}