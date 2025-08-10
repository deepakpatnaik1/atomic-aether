//
//  KeychainWire.swift
//  atomic-aether
//
//  Integration documentation for API Key Storage
//
//  ATOM 205: API Key Storage - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove API Key Storage completely:
 1. Delete ATOM-205-Keychain folder
 2. Remove keychainService references from EnvLoader.swift (lines ~45, ~78, ~125)
 3. Remove APIKeySetupView from atomic_aetherApp.swift (line ~250)
 4. Remove .sheet(isPresented: $showAPIKeySetup) from ContentView
 5. Update EnvLoader to only check .env files
 
 WARNING: Without Keychain, API keys stored in plaintext .env files only.
 Security will be significantly reduced.
 
 INTEGRATION POINTS:
 - EnvLoader: Primary consumer, checks Keychain before .env files
 - APIKeySetupView: UI for managing API keys
 - atomic_aetherApp: Shows setup sheet when keys missing
 - DevKeys: Alternative storage for development (ATOM 403)
 
 ARCHITECTURE:
 KeychainService provides secure API key storage:
 1. Uses macOS Security framework
 2. Stores keys in user's login keychain
 3. Batch operations to minimize password prompts
 4. Auto-migration from .env files
 
 KEYCHAIN STRUCTURE:
 ```
 Service: com.atomic.aether (or bundle ID)
 Account: ANTHROPIC_API_KEY
 Password: [actual API key]
 
 Account: OPENAI_API_KEY  
 Password: [actual API key]
 
 Account: FIREWORKS_API_KEY
 Password: [actual API key]
 ```
 
 API KEY LOADING PRIORITY:
 ```
 1. DevKeys (if enabled in DEBUG)
    ↓ (not found)
 2. Keychain
    ↓ (not found)
 3. Process environment
    ↓ (not found)
 4. .env file
    ↓ (found)
 5. Auto-migrate to Keychain
 ```
 
 BATCH OPERATIONS:
 ```swift
 // Save multiple keys at once
 KeychainService.saveAPIKeys([
     "ANTHROPIC_API_KEY": anthropicKey,
     "OPENAI_API_KEY": openAIKey,
     "FIREWORKS_API_KEY": fireworksKey
 ])
 // Single password prompt for all
 ```
 
 ERROR HANDLING:
 ```swift
 enum KeychainError: Error {
     case itemNotFound
     case duplicateItem  
     case invalidData
     case authenticationFailed
     case unhandledError(OSStatus)
 }
 ```
 
 SECURITY ATTRIBUTES:
 ```swift
 kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
 // Keys available after first device unlock
 // Balances security with background access
 ```
 
 API KEY SETUP UI:
 - Sheet presentation when keys missing
 - Secure text fields for each provider
 - Test connection buttons
 - Save all keys in single operation
 - Visual feedback for success/failure
 
 PASSWORD PROMPTS:
 - macOS prompts for keychain access
 - Frequency depends on app signing
 - Can add to "Always Allow" in Keychain Access
 - DevKeys atom eliminates prompts in development
 
 BEST PRACTICES:
 - Never log or print API keys
 - Use batch operations when possible
 - Handle keychain locked scenarios
 - Provide clear error messages
 - Test with fresh user accounts
 */