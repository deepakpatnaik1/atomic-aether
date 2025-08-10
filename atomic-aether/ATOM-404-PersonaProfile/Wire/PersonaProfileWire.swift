//
//  PersonaProfileWire.swift
//  atomic-aether
//
//  Integration documentation for Persona Profile Service
//
//  ATOM 404: Persona Profile Service - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove Persona Profile Service completely:
 1. Delete ATOM-404-PersonaProfile folder
 2. Remove personaProfileService initialization from atomic_aetherApp.swift (line ~125)
 3. Remove personaProfileService environment object from atomic_aetherApp.swift (line ~193)
 4. Remove personaProfileService from SystemPromptBuilder dependencies (if present)
 5. Remove persona-specific context from system prompts
 6. Delete aetherVault/Config/PersonaProfile.json
 
 The app will work with base persona prompts only.
 
 INTEGRATION POINTS:
 - atomic_aetherApp.swift: Creates and injects PersonaProfileService
 - SystemPromptBuilder: Includes persona profiles in system prompts (if present)
 - ConfigBus: Loads PersonaProfile.json configuration
 - aetherVault/Personas/: Folder containing persona-specific context
 
 ARCHITECTURE:
 Persona Profile Service reads text files from individual persona folders:
 1. Scans aetherVault/Personas/[persona-name]/ directories
 2. Loads .md, .txt, .markdown, .text files per persona
 3. Lazy loading - only when persona requested
 4. Caches per persona for performance
 5. Provides formatted output for system prompts
 
 PERSONA FOLDER STRUCTURE:
 ```
 aetherVault/Personas/
 ├── Claude/
 │   ├── 7-boss-rules-deep-dive.md
 │   ├── swift-best-practices.md
 │   └── architecture-patterns.txt
 ├── Samara/
 │   ├── creative-techniques.md
 │   ├── empathy-guidelines.md
 │   └── storytelling-framework.txt
 ├── Vlad/
 │   ├── startup-playbook.md
 │   └── market-analysis.txt
 └── [persona-name]/
     └── [any text files]
 ```
 
 CONFIGURATION (PersonaProfile.json):
 ```json
 {
   "baseFolderPath": "~/Documents/code/atomic-aether/aetherVault/Personas",
   "fileExtensions": [".md", ".txt", ".markdown", ".text"],
   "excludePatterns": [".DS_Store", ".gitignore", "*.tmp"],
   "cacheEnabled": true,
   "maxFileSize": 524288,
   "includeFilenames": true,
   "sortAlphabetically": true,
   "lazyLoading": true
 }
 ```
 
 LAZY LOADING:
 ```swift
 // Only loads when requested
 func getProfileForPrompt(personaId: String) -> String {
     if let cached = cache[personaId] {
         return cached
     }
     
     let profile = loadProfile(for: personaId)
     cache[personaId] = profile
     return profile
 }
 ```
 
 PROFILE OUTPUT:
 ```swift
 let claudeProfile = personaProfileService.getProfileForPrompt(
     personaId: "claude"
 )
 // Returns:
 === 7-boss-rules-deep-dive.md ===
 
 [content]
 
 === swift-best-practices.md ===
 
 [content]
 ```
 
 FALLBACK BEHAVIOR:
 - No persona folder: Returns empty string
 - No files in folder: Returns empty string
 - Read errors: Logs and returns partial
 - Graceful degradation
 
 CACHING STRATEGY:
 - Per-persona caching
 - Lazy population
 - Manual refresh available
 - Memory efficient
 
 PHILOSOPHY:
 - Base prompt = personality (in Personas.json)
 - Profile = extended knowledge (in folders)
 - Separation of concerns
 - Personas can evolve over time
 - Version control friendly
 
 USAGE PATTERNS:
 ```swift
 // System prompt assembly
 let basePrompt = persona.systemPrompt
 let profile = personaProfileService.getProfileForPrompt(personaId)
 let fullPrompt = basePrompt + "\n\n" + profile
 
 // Check if persona has profile
 if personaProfileService.hasProfile(for: personaId) {
     // Include extended context
 }
 ```
 
 ERROR HANDLING:
 - Missing base folder: Creates it
 - Missing persona folder: No error, empty profile
 - File read errors: Continue with other files
 - Large files: Skip with warning
 
 BEST PRACTICES:
 - Keep profiles focused on knowledge/skills
 - Let base prompt define personality
 - Use clear, descriptive filenames
 - Monitor total profile sizes
 - Update profiles as personas evolve
 
 FUTURE ENHANCEMENTS:
 - File watching per persona
 - Hot-reload on changes
 - Profile size warnings
 - Selective file loading
 - Profile versioning
 */