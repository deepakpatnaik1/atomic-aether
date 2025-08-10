//
//  LLMSystemWire.swift
//  atomic-aether
//
//  Integration documentation for LLM System
//
//  ATOM 202: LLM System - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove LLM System completely:
 1. Delete ATOM-202-LLMServices folder
 2. Delete ATOM-202-Models folder
 3. Remove llmRouter initialization from atomic_aetherApp.swift (line ~109)
 4. Remove modelRegistry initialization from atomic_aetherApp.swift (line ~102)
 5. Remove llmRouter environment object from atomic_aetherApp.swift (line ~187)
 6. Remove llmRouter.setupServices() call from atomic_aetherApp.swift (line ~219)
 7. Remove modelRegistry from ConversationOrchestrator dependencies
 8. Replace LLM calls in ConversationOrchestrator with mock responses
 
 WARNING: Without LLM System, the app cannot communicate with AI providers.
 The conversation flow will be broken unless you provide alternative implementations.
 
 INTEGRATION POINTS:
 - atomic_aetherApp.swift: Creates LLMRouter and ModelRegistry
 - ConversationOrchestrator: Uses LLMRouter to send requests
 - EnvLoader: Provides API keys to LLM services
 - ConfigBus: Loads LLMProviders.json configuration
 - EventBus: Publishes model loading events
 - ErrorBus: Reports LLM errors
 
 MODELS FOLDER STRUCTURE:
 ATOM-202-Models/
 ├── Core/           # Empty (models are the core)
 ├── Models/         # Data structures
 │   ├── LLMProvider.swift
 │   ├── LLMConfiguration.swift
 │   ├── LLMRequest.swift
 │   ├── LLMResponse.swift
 │   └── MessageRole.swift
 ├── Services/       # Model registry
 │   └── ModelRegistryService.swift
 ├── Events/         # Model events
 │   └── ModelEvents.swift
 └── UI/            # Debug view
     └── ModelDebugView.swift
 
 LLM SERVICES FOLDER STRUCTURE:
 ATOM-202-LLMServices/
 ├── Protocols/      # Service protocol
 │   └── LLMService.swift
 ├── Services/       # Provider implementations
 │   ├── LLMRouter.swift
 │   ├── AnthropicService.swift
 │   ├── OpenAIService.swift
 │   └── FireworksService.swift
 └── Wire/          # This documentation
     └── LLMSystemWire.swift
 
 PROVIDER CONFIGURATION:
 LLMProviders.json defines all providers and models:
 ```json
 {
   "providers": {
     "anthropic": {
       "baseURL": "https://api.anthropic.com/v1",
       "models": {...}
     },
     "openai": {...},
     "fireworks": {...}
   }
 }
 ```
 
 API KEY LOADING:
 1. DevKeys (if enabled) → UserDefaults
 2. Keychain → Secure storage
 3. Process environment → Runtime variables
 4. .env file → Development fallback
 
 STREAMING RESPONSES:
 All providers return AsyncThrowingStream<LLMResponse, Error>:
 ```swift
 let stream = try await llmRouter.route(request)
 for try await response in stream {
     // Process tokens
 }
 ```
 
 ADDING NEW PROVIDERS:
 1. Add provider to LLMProvider enum
 2. Create new service implementing LLMService protocol
 3. Register in LLMRouter.setupServices()
 4. Add configuration to LLMProviders.json
 
 BEST PRACTICES:
 - Always use streaming for better UX
 - Handle errors gracefully
 - Report errors to ErrorBus
 - Use proper async/await patterns
 - Validate models with ModelRegistry
 - Don't hardcode API endpoints
 */