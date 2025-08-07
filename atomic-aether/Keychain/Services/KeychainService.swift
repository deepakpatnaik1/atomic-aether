//
//  KeychainService.swift
//  atomic-aether
//
//  Secure storage for API keys using macOS Keychain
//
//  ATOM 13: API Key Storage - Secure API key management
//
//  Atomic LEGO: Single responsibility - Keychain operations
//  No file access needed, secure by default
//

import Foundation
import Security

@MainActor
class KeychainService {
    
    // MARK: - Constants
    
    private static let serviceName = Bundle.main.bundleIdentifier ?? "com.atomic-aether"
    private static let batchKeyName = "API_KEYS_BATCH"
    private static let accessGroup: String? = nil // Use default access group
    
    // MARK: - Key Names
    
    enum KeychainKey: String, CaseIterable {
        case openAIKey = "OPENAI_API_KEY"
        case anthropicKey = "ANTHROPIC_API_KEY"
        case fireworksKey = "FIREWORKS_API_KEY"
    }
    
    
    // MARK: - Public Methods
    
    /// Save a value to the keychain
    static func save(key: KeychainKey, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        // Delete any existing item first
        delete(key: key)
        
        // Create query
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // Add access group if specified
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        // Add item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Retrieve a value from the keychain
    static func retrieve(key: KeychainKey) -> String? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        // Add access group if specified
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    /// Delete a value from the keychain
    @discardableResult
    static func delete(key: KeychainKey) -> Bool {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue
        ]
        
        // Add access group if specified
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    /// Delete all API keys
    static func deleteAll() {
        for key in KeychainKey.allCases {
            delete(key: key)
        }
    }
    
    /// Check if a key exists
    static func exists(key: KeychainKey) -> Bool {
        return retrieve(key: key) != nil
    }
    
    /// Get all stored keys (for UI display)
    static func getAllKeys() -> [KeychainKey: Bool] {
        var result: [KeychainKey: Bool] = [:]
        for key in KeychainKey.allCases {
            result[key] = exists(key: key)
        }
        return result
    }
    
    // MARK: - Batch Operations
    
    /// Save all API keys at once (single authentication prompt)
    static func saveAll(_ keys: [KeychainKey: String]) -> Bool {
        // Encode all keys into a single JSON object
        let encoder = JSONEncoder()
        var keysDict: [String: String] = [:]
        
        for (key, value) in keys {
            keysDict[key.rawValue] = value
        }
        
        guard let data = try? encoder.encode(keysDict) else { return false }
        
        // Delete existing batch item
        deleteBatch()
        
        // Create query for batch storage
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: batchKeyName,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // Add access group if specified
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        // Add item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        // Also save individual keys for backward compatibility
        if status == errSecSuccess {
            for (key, value) in keys {
                _ = save(key: key, value: value)
            }
        }
        
        return status == errSecSuccess
    }
    
    /// Retrieve all API keys at once (single authentication prompt)
    static func retrieveAll() -> [KeychainKey: String]? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: batchKeyName,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        // Add access group if specified
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let keysDict = try? JSONDecoder().decode([String: String].self, from: data) else {
            return nil
        }
        
        // Convert to typed dictionary
        var typedKeys: [KeychainKey: String] = [:]
        for (rawKey, value) in keysDict {
            if let key = KeychainKey(rawValue: rawKey) {
                typedKeys[key] = value
            }
        }
        
        return typedKeys
    }
    
    /// Delete batch storage
    @discardableResult
    private static func deleteBatch() -> Bool {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: "API_KEYS_BATCH"
        ]
        
        // Add access group if specified
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}