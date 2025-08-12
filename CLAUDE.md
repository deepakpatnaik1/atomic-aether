# Claude's Navigation Hub for Atomic-Aether

## Start Here
When you say "Claude, read the CLAUDE.md file", I will:
1. Read this file first
2. Follow the navigation links to understand the project
3. Report back with a complete understanding

## Essential Reading Order

### 1. Architecture Philosophy
Read these files to understand the core principles:
- [BOSS-RULES.md](BOSS-RULES.md) - The 7 Boss Rules that govern all development
- [ATOM-GUIDE.md](ATOM-GUIDE.md) - Practical guide for creating new atoms
- [ATOM-REFERENCE.md](ATOM-REFERENCE.md) - Quick reference for all atoms and buses

### 2. Project Structure
Explore the main codebase structure:
- `atomic-aether/` - Main source directory
- `atomic-aether/atomic_aetherApp.swift` - App entry point
- `atomic-aether/ContentView.swift` - Main UI structure
- `atomic-aether/aetherVault/` - Configuration and data files

### 3. Core Infrastructure (100 Series)
Foundation buses that everything depends on:
- `ATOM-101-EventBus/` - Pub/sub communication system
- `ATOM-102-ErrorBus/` - Centralized error handling
- `ATOM-103-StateBus/` - Shared state management
- `ATOM-104-ConfigBus/` - JSON configuration loading

### 4. Key Feature Areas
- **200 Series**: LLM/AI functionality
- **300 Series**: Input system (InputBar, SlashCommands, Keyboard, JournalCommand)
- **400 Series**: Personas (PersonaSystem, PersonaPicker, Profiles)
- **500 Series**: Conversations (ConversationFlow, Scrollback, MessageStore)
- **600 Series**: Theme system
- **800 Series**: Memory & persistence (Superjournal)

### 5. Configuration Files
All in `aetherVault/Config/`:
- `DesignTokens.json` - Theme colors and spacing
- `InputBarAppearance.json` - Input bar styling
- `Personas.json` - Persona definitions
- `LLMProviders.json` - AI provider settings

### 6. User Context & Memory
- `aetherVault/Boss/Boss.md` - User identity and context
- `aetherVault/Boss/Boss's expectations.md` - Development expectations
- `aetherVault/Personas/*/` - Individual persona definitions
- `aetherVault/Superjournal/` - Timestamped conversation logs (ATOM-801)

## Quick Commands for Claude

When working on features:
- "Show me the EventBus pattern" → Check ATOM-101-EventBus
- "How do I add configuration?" → Check ATOM-104-ConfigBus
- "Where are the colors defined?" → Check DesignTokens.json
- "How do I create a new atom?" → Follow ATOM-GUIDE.md

## Current State Summary
- **Architecture**: Atomic LEGO with event-driven communication
- **Language**: Swift with SwiftUI for macOS
- **Key Pattern**: Atoms communicate only through buses, never directly
- **Configuration**: Everything externalized to JSON files
- **Philosophy**: Production-grade but not over-engineered

## Navigation Complete
After reading this file and following the links, I'll have a complete understanding of:
- The architectural principles
- The codebase structure
- How to build new features
- The existing atoms and their interactions
- The configuration system
- The user context and expectations

---
*This file serves as Claude's entry point to understand the entire atomic-aether project.*