//
//  EnvLoaderWire.swift
//  atomic-aether
//
//  Integration documentation for Environment Loader
//
//  ATOM 206: Environment Loader - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove Environment Loader completely:
 1. Delete ATOM-206-EnvLoader folder
 2. Remove envLoader initialization from atomic_aetherApp.swift (line ~104)
 3. Remove envLoader.loadAPIKeys() call from atomic_aetherApp.swift (line ~204)
 4. Update LLM services to get API keys directly (hardcode or other method)
 5. Remove .env file from project root
 
 WARNING: Without EnvLoader, no API keys will be loaded automatically.
 LLM services will fail unless you provide keys another way.
 
 INTEGRATION POINTS:
 - atomic_aetherApp.swift: Creates EnvLoader and calls loadAPIKeys()
 - LLM Services: Access keys via envLoader.apiKey(for:)
 - DevKeys: Checked first if enabled (ATOM 207)
 - Keychain: Checked second via KeychainService (ATOM 205)
 - ConfigBus: Loads EnvLoader.json configuration
 
 ARCHITECTURE:
 EnvLoader provides a three-tier API key loading strategy:
 1. DevKeys (if enabled in DEBUG builds)
 2. Keychain (secure storage)
 3. Process environment variables
 4. .env file (fallback)
 5. Auto-migration to Keychain when found in .env
 
 LOADING PRIORITY:
 ```
 DevKeys.isEnabled && DEBUG?
         ↓ Yes              ↓ No
 Check UserDefaults    Check Keychain
         ↓                     ↓
     Found? Use it        Found? Use it
         ↓                     ↓
        No?                   No?
         ↓                     ↓
 Check process env ←──────────┘
         ↓
     Found? Use it
         ↓
        No?
         ↓
 Check .env file
         ↓
     Found? 
         ↓
 Migrate to Keychain
         ↓
     Use it
 ```
 
 CONFIGURATION (EnvLoader.json):
 ```json
 {
   "apiKeyNames": {
     "anthropic": "ANTHROPIC_API_KEY",
     "openai": "OPENAI_API_KEY", 
     "fireworks": "FIREWORKS_API_KEY"
   },
   "envFilePaths": [
     ".env",
     "../.env",
     "~/.env"
   ],
   "autoMigrateToKeychain": true,
   "logLevel": "info"
 }
 ```
 
 ENV FILE FORMAT:
 ```
 # .env file in project root
 ANTHROPIC_API_KEY=sk-ant-api03-...
 OPENAI_API_KEY=sk-proj-...
 FIREWORKS_API_KEY=fw_3Tv9...
 
 # Comments and empty lines ignored
 # Quotes optional but recommended
 ```
 
 API KEY ACCESS:
 ```swift
 // Get specific key
 let anthropicKey = envLoader.apiKey(for: .anthropic)
 
 // Check if key exists
 if envLoader.hasAPIKey(for: .openai) {
     // Configure OpenAI service
 }
 
 // Get all loaded keys
 let allKeys = envLoader.loadedKeys
 ```
 
 ERROR HANDLING:
 - Missing .env file: Silent fallback (not an error)
 - Malformed .env: Logs warning, continues
 - Keychain errors: Falls back to next source
 - No keys found: Returns nil, services handle
 
 AUTO-MIGRATION:
 When keys found in .env but not Keychain:
 1. Load from .env file
 2. Save to Keychain (batch operation)
 3. Log migration success
 4. Future loads use Keychain
 
 SECURITY NOTES:
 - Never commit .env files to git
 - Add .env to .gitignore
 - Use DevKeys for development
 - Use Keychain for production
 - Validate keys before use
 
 BEST PRACTICES:
 - Load keys early in app lifecycle
 - Handle missing keys gracefully
 - Provide clear error messages
 - Test with missing/invalid keys
 - Monitor key expiration
 */