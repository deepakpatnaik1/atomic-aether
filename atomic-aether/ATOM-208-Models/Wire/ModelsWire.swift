//
//  ModelsWire.swift
//  atomic-aether
//
//  Integration documentation for Models atom
//
//  ATOM 208: Models - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove Models atom completely:
 1. Delete ATOM-208-Models folder
 2. Remove modelRegistry initialization from atomic_aetherApp.swift (line ~30)
 3. Remove MessageRole references from LLM services (replace with strings)
 4. Remove model validation from ModelStateService
 5. Remove ModelEvents from EventBus subscriptions
 
 WARNING: This atom provides core model definitions. Removing it will
 require significant refactoring of LLM services and model management.
 
 INTEGRATION POINTS:
 - atomic_aetherApp.swift: Creates ModelRegistryService
 - LLMServices: Use MessageRole for API formatting
 - ModelPicker: Uses registry to list available models
 - ModelState: Uses registry for validation
 - ConversationFlow: Uses MessageRole for messages
 
 ARCHITECTURE:
 Models atom provides:
 1. MessageRole enum for conversation roles
 2. ModelRegistryService for validation
 3. Model lifecycle events
 4. Debug UI for testing
 
 DATA STRUCTURES:
 ```swift
 enum MessageRole: String, Codable {
     case system = "system"
     case user = "user"  
     case assistant = "assistant"
 }
 ```
 
 MODEL REGISTRY:
 ```swift
 // Validate model strings
 if modelRegistry.isValidModel("anthropic/claude-3-opus") {
     // Model exists in configuration
 }
 
 // Get available models
 let anthropicModels = modelRegistry.availableModels(for: .anthropic)
 ```
 
 CONFIGURATION:
 Models are defined in LLMProviders.json:
 ```json
 {
   "providers": {
     "anthropic": {
       "models": {
         "claude-3-opus": { ... },
         "claude-3-sonnet": { ... }
       }
     }
   }
 }
 ```
 
 EVENTS:
 - ModelsLoadedEvent: When registry loads models
 - ModelValidationFailedEvent: When validation fails
 
 DEPENDENCIES:
 - ConfigBus: Loads LLMProviders.json
 - EventBus: Publishes model events
 
 WHY THIS EXISTS:
 - Centralizes model definitions
 - Prevents model string typos
 - Validates model selections
 - Provides consistent role types
 - Enables configuration-driven models
 
 USAGE EXAMPLE:
 ```swift
 // In LLM service
 let message = LLMMessage(
     role: MessageRole.user,  // Type-safe role
     content: "Hello"
 )
 
 // In model validation
 guard modelRegistry.isValidModel(selectedModel) else {
     throw ModelError.invalidModel
 }
 ```
 */