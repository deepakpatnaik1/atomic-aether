//
//  ConfigBus.swift
//  atomic-aether
//
//  ATOM 4: ConfigBus - Simple configuration with hot-reloading
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
    private var configuration: ConfigBusConfiguration
    private weak var eventBus: EventBus?
    
    // Publishers for each config
    @Published var configs: [String: Any] = [:]
    
    // MARK: - Initialization
    
    init(eventBus: EventBus? = nil) {
        self.eventBus = eventBus
        
        // Bootstrap load our own config from bundle
        if let url = Bundle.main.url(forResource: "ConfigBus", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let config = try? JSONDecoder().decode(ConfigBusConfiguration.self, from: data) {
            self.configuration = config
        } else {
            self.configuration = .default
        }
        
        let queueLabel = Bundle.main.bundleIdentifier ?? configuration.defaultBundleIdentifier
        self.queue = DispatchQueue(label: "\(queueLabel).configbus")
    }
    
    // MARK: - Load Configuration
    
    func load<T: Codable>(_ name: String, as type: T.Type) -> T? {
        // Try cache first
        if let cached = configs[name] as? T {
            return cached
        }
        
        // Load from bundle
        guard let url = Bundle.main.url(forResource: name, withExtension: configuration.fileExtension) else {
            // Config file not found in bundle
            eventBus?.publish(ConfigEvents.loadFailed(name, error: CocoaError(.fileNoSuchFile)))
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(type, from: data)
            configs[name] = config
            
            // Bundle files can't be watched for changes
            // Hot reload only works in development with external files
            
            // Publish success event
            eventBus?.publish(ConfigEvents.changed(name))
            
            return config
        } catch {
            // Failed to decode config
            eventBus?.publish(ConfigEvents.loadFailed(name, error: error))
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
        let configPath = "~/Documents/code/atomic-aether/aetherVault/Config/\(name).\(configuration.fileExtension)"
        let expandedPath = NSString(string: configPath).expandingTildeInPath
        let url = URL(fileURLWithPath: expandedPath)
        
        guard FileManager.default.fileExists(atPath: expandedPath) else { return }
        
        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(type, from: data)
            configs[name] = config
            objectWillChange.send()
            
            // Publish reload event
            eventBus?.publish(ConfigEvents.changed(name))
        } catch {
            // Reload failed
            eventBus?.publish(ConfigEvents.loadFailed(name, error: error))
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