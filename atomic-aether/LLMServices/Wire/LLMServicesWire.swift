//
//  LLMServicesWire.swift
//  atomic-aether
//
//  Wire documentation for LLM Services atom
//
//  ATOM 18: LLM Services - Integration wire
//
//  Atomic LEGO: Documents how LLM Services integrate with the app
//

/*
 INTEGRATION POINTS:
 
 1. atomic_aetherApp.swift:
    - Creates LLMRouter with dependencies
    - Calls setupServices() after environment loads
    - Passes to ConversationOrchestrator
 
 2. Dependencies:
    - EnvLoader: Provides API keys
    - ConfigBus: Loads LLMProviders.json
    - EventBus: Publishes LLM events
 
 3. Configuration:
    - LLMProviders.json: Provider configs, models, endpoints
    - Supports OpenAI, Anthropic, Fireworks
 
 4. Core Components:
    - LLMServiceProtocol: Unified interface
    - LLMRouter: Routes by provider prefix
    - Provider services: Implement protocol
 
 5. Events Published:
    - LLMEvent.requestStarted
    - LLMEvent.tokenReceived  
    - LLMEvent.responseCompleted
    - LLMEvent.errorOccurred
 
 REMOVAL:
 To remove this atom:
 1. Delete LLMServices folder
 2. Remove LLMRouter from app initialization
 3. Update ConversationOrchestrator to use mock service
 4. Delete LLMProviders.json configuration
 
 ADDING NEW PROVIDER:
 1. Create new service implementing LLMServiceProtocol
 2. Add provider config to LLMProviders.json
 3. Add case to LLMProvider enum
 4. Wire in LLMRouter.setupServices()
 */