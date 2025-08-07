//
//  PersonaFolderEvents.swift
//  atomic-aether
//
//  Events for dynamic persona folder changes
//
//  ATOM 10: Personas - Folder change events
//
//  Atomic LEGO: Notifies system of persona folder changes
//  Enables hot-reload of personas
//

import Foundation

enum PersonaFolderEvent: AetherEvent {
    case personasLoaded([PersonaFolder])
    case personaAdded(PersonaFolder)
    case personaRemoved(String) // persona id
    case personaUpdated(PersonaFolder)
    case folderWatchError(Error)
    
    var source: String {
        "PersonaFolderWatcher"
    }
}