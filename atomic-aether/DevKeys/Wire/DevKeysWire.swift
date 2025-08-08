//
//  DevKeysWire.swift
//  atomic-aether
//
//  Integration documentation for DevKeys atom
//

/*
 ATOM: DevKeys - Development-Only API Key Storage
 
 PURPOSE:
 Provides password-free API key storage during development using UserDefaults.
 Eliminates Keychain password prompts that interrupt the development flow.
 
 INTEGRATION POINTS:
 1. atomic_aetherApp.swift - Service initialization (line ~80)
 2. EnvLoader.swift - DevKeys loading strategy (line 32, 47)
 3. APIKeySetupView.swift - UI toggle integration (line 17, 31, 123)
 
 REMOVAL INSTRUCTIONS:
 To remove this atom completely:
 1. Delete the DevKeys folder
 2. Remove devKeysService initialization from atomic_aetherApp.swift line ~80
 3. Remove devKeysService parameter from envLoader.setup() in atomic_aetherApp.swift line ~120
 4. Remove DevKeys references from APIKeySetupView.swift:
    - Remove @EnvironmentObject var devKeysService line 17
    - Remove DevKeysToggleView() and Divider() lines 31-36
    - Remove DevKeys saving logic lines 122-133
 5. Remove devKeysService from loadFromDevKeys check in EnvLoader.swift line 47
 6. Delete aetherVault/Config/DevKeys.json
 
 The app will continue working with Keychain-only storage.
 
 BEHAVIOR:
 - When enabled, EnvLoader checks DevKeys first before Keychain
 - No password prompts when using DevKeys storage
 - Visual warning displayed when DevKeys is active
 - Auto-enabled in DEBUG builds if configured
 - Keys can be migrated from Keychain with one click
 
 SECURITY:
 - DevKeys stores API keys in UserDefaults (insecure)
 - Only use during development
 - Production builds should disable this feature
 - Clear warning shown when active
 
 CONFIGURATION:
 All settings in aetherVault/Config/DevKeys.json:
 - autoEnableInDebug: Auto-enable in DEBUG builds
 - clearOnDisable: Clear keys when disabling
 - ui.showInRelease: Show toggle in release builds (not recommended)
 */