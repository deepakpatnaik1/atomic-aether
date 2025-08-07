//
//  PersonaFolderWire.swift
//  atomic-aether
//
//  Wire documentation for PersonaFolder feature
//
//  ATOM 10: Personas - Dynamic folder-based personas
//
//  Atomic LEGO: Documentation for complete removal
//  Lists all integration points and removal steps
//

/*
 PERSONA FOLDER FEATURE - WIRE DOCUMENTATION
 ==========================================
 
 This feature enables dynamic, folder-based personas that hot-reload from the filesystem.
 Each persona is defined by a markdown file with YAML frontmatter in its own folder.
 
 INTEGRATION POINTS:
 -------------------
 1. PersonaSystem.swift - Added folderWatcher property and setup
 2. PersonaStateService.swift - Subscribes to folder events, manages dynamic personas
 3. PersonaFolders.json - Configuration file for folder watching
 4. Personas.json - Emptied of hardcoded personas
 
 REMOVAL INSTRUCTIONS:
 --------------------
 To completely remove this feature and revert to static personas:
 
 1. Delete these files/folders:
    - PersonaSystem/Models/PersonaFolder.swift
    - PersonaSystem/Models/PersonaFolderConfiguration.swift
    - PersonaSystem/Services/PersonaFolderWatcher.swift
    - PersonaSystem/Services/FrontmatterParser.swift
    - PersonaSystem/Events/PersonaFolderEvents.swift
    - PersonaSystem/Wire/PersonaFolderWire.swift (this file)
    - aetherVault/Config/PersonaFolders.json
 
 2. In PersonaSystem/Core/PersonaSystem.swift:
    - Remove line 30: `private let folderWatcher: PersonaFolderWatcher`
    - Remove line 50: `self.folderWatcher = PersonaFolderWatcher()`
    - Remove lines 68-69: folder watcher setup in setup() method
 
 3. In PersonaSystem/Services/PersonaStateService.swift:
    - Remove lines 40-41: cancellables and dynamicPersonas properties
    - Remove line 115: `subscribeToFolderEvents()` call in setup()
    - Remove lines 205-292: All folder event subscription methods
 
 4. Restore aetherVault/Config/Personas.json with hardcoded personas:
    - Copy the original personas back into the "personas" object
    - Or restore from git history
 
 5. Remove frontmatter from persona markdown files in aetherVault/Personas/
    - Optional: The frontmatter won't hurt anything if left in place
 
 FALLBACK BEHAVIOR:
 -----------------
 After removal, the app will:
 - Load personas from the static Personas.json file
 - Ignore the persona folders completely
 - Work exactly as it did before this feature was added
 
 BENEFITS OF THIS FEATURE:
 ------------------------
 - Hot-reload personas by adding/removing folders
 - Edit personas without rebuilding the app
 - Visual persona configuration (colors, avatars) in markdown
 - Git-friendly persona management
 - User-friendly for non-developers
 
 */