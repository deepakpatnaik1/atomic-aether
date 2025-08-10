//
//  BossProfileWire.swift
//  atomic-aether
//
//  Integration documentation for Boss Profile Service
//
//  ATOM 403: Boss Profile Service - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove Boss Profile Service completely:
 1. Delete ATOM-403-BossProfile folder
 2. Remove bossProfileService initialization from atomic_aetherApp.swift (line ~124)
 3. Remove bossProfileService environment object from atomic_aetherApp.swift (line ~192)
 4. Remove bossProfileService from SystemPromptBuilder dependencies (if present)
 5. Remove Boss context from system prompts
 6. Delete aetherVault/Config/BossProfile.json
 
 The app will work without user context in system prompts.
 
 INTEGRATION POINTS:
 - atomic_aetherApp.swift: Creates and injects BossProfileService
 - SystemPromptBuilder: Includes boss profile in system prompts (if present)
 - MessageRow: Uses bossDisplayName and bossColor for "Boss" speaker
 - ConfigBus: Loads BossProfile.json configuration
 - aetherVault/Boss/: Folder containing user context files
 
 ARCHITECTURE:
 Boss Profile Service reads all text files from the Boss folder:
 1. Scans aetherVault/Boss/ directory
 2. Loads .md, .txt, .markdown, .text files
 3. Concatenates with file headers
 4. Caches content for performance
 5. Provides formatted output for system prompts
 
 BOSS FOLDER STRUCTURE:
 ```
 aetherVault/Boss/
 ├── Boss.md                    # Main profile
 ├── Boss's expectations.md     # Expectations
 ├── current-projects.md        # Active work
 └── preferences.txt            # Preferences
 ```
 
 CONFIGURATION (BossProfile.json):
 ```json
 {
   "folderPath": "~/Documents/code/atomic-aether/aetherVault/Boss",
   "fileExtensions": [".md", ".txt", ".markdown", ".text"],
   "excludePatterns": [".DS_Store", ".gitignore"],
   "displayName": "Boss",
   "displayColor": "#FFD700",
   "cacheEnabled": true,
   "maxFileSize": 1048576
 }
 ```
 
 FILE LOADING:
 ```swift
 // Reads all matching files
 let files = try FileManager.default.contentsOfDirectory(
     at: bossFolder,
     includingPropertiesForKeys: nil
 )
 .filter { url in
     fileExtensions.contains(url.pathExtension)
 }
 
 // Formats with headers
 === Boss.md ===
 
 [content of Boss.md]
 
 === current-projects.md ===
 
 [content of current-projects.md]
 ```
 
 PROFILE OUTPUT:
 ```swift
 let profile = bossProfileService.getProfileForPrompt()
 // Returns concatenated files with headers
 // Or empty string if no files/folder
 ```
 
 DISPLAY CUSTOMIZATION:
 - Boss messages use custom displayName (default: "Boss")
 - Boss messages use custom color (default: gold #FFD700)
 - Configurable via BossProfile.json
 - Used by MessageRow for speaker label
 
 CACHING:
 - Profile cached after first load
 - Cache cleared on file changes (future)
 - Reduces file I/O for repeated access
 - Manual refresh available
 
 PHILOSOPHY:
 - The folder IS the profile
 - No structured data required
 - Drop any text file in Boss folder
 - Automatic inclusion in context
 - Maximum flexibility
 
 ERROR HANDLING:
 - Missing folder: Creates it
 - No files: Returns empty profile
 - Read errors: Logs and continues
 - Large files: Respects maxFileSize
 
 BEST PRACTICES:
 - Keep files focused and concise
 - Use clear filenames
 - Markdown for rich formatting
 - Update files as context changes
 - Monitor total profile size
 */