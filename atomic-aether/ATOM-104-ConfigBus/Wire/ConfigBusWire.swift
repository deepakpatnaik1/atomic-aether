//
//  ConfigBusWire.swift
//  atomic-aether
//
//  Integration documentation for ConfigBus
//
//  ATOM 104: ConfigBus - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove ConfigBus completely:
 1. Delete ATOM-104-ConfigBus folder
 2. Remove configBus initialization from atomic_aetherApp.swift (line ~72)
 3. Remove configBus environment object from atomic_aetherApp.swift (line ~190)
 4. Remove eventBus.configBus = configBus assignment (line ~76)
 5. Replace all configBus.load() calls with hardcoded values
 
 WARNING: Without ConfigBus, all settings must be hardcoded.
 No hot-reload, no external configuration, violates Boss Rule #3.
 
 INTEGRATION POINTS:
 - atomic_aetherApp.swift: Creates ConfigBus with EventBus dependency
 - Every atom: Calls configBus.load() to get configuration
 - ContentView.swift: Sets up theme service with ConfigBus
 - EventBus: Special circular dependency for bootstrap
 - File watching: Uses DispatchSource for hot-reload
 
 CONFIGURATION LOADING API:
 ```swift
 // Load typed configuration
 let config = configBus.load("PersonaSystem", as: PersonaConfiguration.self)
 
 // Load with fallback
 let config = configBus.load("Theme", as: ThemeConfig.self) ?? .default
 
 // Check if config exists
 if configBus.hasConfiguration("FeatureFlag") {
     // Enable feature
 }
 ```
 
 CONFIGURATION FILES:
 Located in aetherVault/Config/:
 - EventBus.json - Event system configuration
 - ErrorHandling.json - Error display settings
 - StateBus.json - State storage limits
 - LLMProviders.json - AI provider settings
 - Personas.json - Persona definitions
 - InputBarAppearance.json - UI appearance
 - And many more...
 
 HOT-RELOAD BEHAVIOR:
 - Development: Watches config files for changes
 - Production: Loads once from bundle
 - File changes trigger automatic reload
 - Publishes ConfigurationChanged events
 
 CONFIGURATION FORMAT:
 All configs are JSON with Codable structs:
 ```json
 {
   "setting1": "value",
   "setting2": 123,
   "colors": {
     "primary": "#FFFFFF"
   }
 }
 ```
 
 BEST PRACTICES:
 - Define configuration structs with defaults
 - Keep configs focused - one per atom
 - Document all configuration options
 - Use meaningful property names
 - Validate loaded configurations
 - Don't store sensitive data in configs
 */