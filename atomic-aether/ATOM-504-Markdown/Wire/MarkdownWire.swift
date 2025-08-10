//
//  MarkdownWire.swift
//  atomic-aether
//
//  Integration documentation for Markdown atom
//
//  ATOM 504: Markdown - Wire documentation
//

/*
 INTEGRATION POINTS:
 
 1. Add Package Dependency in Xcode:
    - File → Add Package Dependencies
    - Enter: https://github.com/gonzalezreal/swift-markdown-ui
    - Version: Up to Next Major Version 2.4.1
    - Add to Target: atomic-aether
 
 2. Replace Text view in MessageRow.swift (~line 40):
    OLD: Text(message.content)
         .font(.system(size: appearance.message.fontSize))
         .foregroundColor(.white.opacity(appearance.message.contentOpacity))
         .textSelection(.enabled)
         .fixedSize(horizontal: false, vertical: true)
         .frame(maxWidth: .infinity, alignment: .leading)
    
    NEW: MarkdownMessageView(
             content: message.content,
             fontSize: appearance.message.fontSize,
             opacity: appearance.message.contentOpacity
         )
 
 REMOVAL INSTRUCTIONS:
 To remove Markdown support completely:
 1. Delete ATOM-504-Markdown folder
 2. Remove package dependency in Xcode
 3. Revert MessageRow to use Text view
 4. Delete MarkdownAppearance.json
 
 Messages will display as plain text without formatting
 */

import Foundation