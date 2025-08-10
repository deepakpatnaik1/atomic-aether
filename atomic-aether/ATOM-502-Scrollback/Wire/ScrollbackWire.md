# Scrollback Wire Documentation

## ATOM 15: Scrollback - Message Display System

### Purpose
Displays conversation messages with speaker labels and colored accents.

### Dependencies
- MessageStore: Provides messages to display
- PersonaStateService: Provides persona colors and names
- BossProfileService: Provides Boss color and name
- ConfigBus: Loads appearance configuration

### Removal Instructions
To remove this atom completely:
1. Delete the Scrollback folder
2. Remove ScrollbackView usage from ContentView
3. Remove scrollback-related imports
4. Delete aetherVault/Config/ScrollbackAppearance.json

The app will continue to function but without message display.

## Recent Changes

### Persona Colors Update
Updated scrollback to use PersonaStateService for persona colors instead of legacy PersonaService.
Added support for Boss color from BossProfileService.

## What Changed
1. **ScrollbackView.swift**:
   - Changed `@EnvironmentObject var personaService: PersonaService` 
   - To: `@EnvironmentObject var personaStateService: PersonaStateService`
   - Updated MessageRow initialization to pass personaStateService
   - Removed personaService setup from setupWithConfigBus()

2. **MessageRow.swift**:
   - Changed parameter from `personaService: PersonaService`
   - To: `personaStateService: PersonaStateService`
   - Added `@EnvironmentObject var bossProfileService: BossProfileService`
   - Added helper methods to get displayName and accentColor from PersonaStateService
   - Now reads colors from dynamically loaded persona markdown files
   - Boss color and name now come from BossProfileService (reads Boss.md frontmatter)

3. **atomic_aetherApp.swift**:
   - Removed legacy PersonaService declaration
   - Removed personaService from environmentObject injection

4. **BossProfileService.swift**:
   - Added `@Published` properties: bossColor and bossDisplayName
   - Added SwiftUI import for Color type
   - Enhanced loadProfile to parse Boss.md frontmatter
   - Extracts name and color from Boss.md frontmatter

5. **Extensions/Color+Hex.swift**:
   - Moved Color hex extension to shared location
   - Removed duplicate from PersonaFolder.swift
   - Now shared by both PersonaSystem and BossProfile

## Why This Change
- PersonaService was reading from empty Personas.json configuration
- PersonaStateService has the actual persona colors from markdown frontmatter
- This enables colored streaks in scrollback based on each persona's defined color

## To Revert This Change
1. In ScrollbackView.swift:
   - Change back to `@EnvironmentObject var personaService: PersonaService`
   - Update MessageRow calls to pass personaService
   - Re-add `personaService.setupWithConfigBus(configBus)` in setupWithConfigBus()

2. In MessageRow.swift:
   - Change parameter back to `personaService: PersonaService`
   - Remove helper methods (displayName and accentColor)
   - Use personaService methods directly

3. In atomic_aetherApp.swift:
   - Re-add `@StateObject private var personaService = PersonaService()`
   - Re-add `.environmentObject(personaService)`

## Impact
- Scrollback now shows colored streaks matching each persona's defined color
- No breaking changes - PersonaService was only used by scrollback
- Follows Rule #5 (No Damage) - enhances without breaking existing features