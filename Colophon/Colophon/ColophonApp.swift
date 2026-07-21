// SPDX-License-Identifier: Apache-2.0
//
//  ColophonApp.swift
//  Colophon
//

import SwiftUI

@main
struct ColophonApp: App {
    @StateObject private var model = LibraryModel()

    init() {
        // Byte-exact editing: keep smart substitutions off even when the user's
        // system preferences enable them (system prefs override view-level flags).
        UserDefaults.standard.register(defaults: [
            "NSAutomaticQuoteSubstitutionEnabled": false,
            "NSAutomaticDashSubstitutionEnabled": false,
            "NSAutomaticPeriodSubstitutionEnabled": false,
            "NSAutomaticTextReplacementEnabled": false,
            "NSAutomaticSpellingCorrectionEnabled": false,
        ])
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
        .commands {
            CommandGroup(replacing: .saveItem) {
                Button("Save") { model.save() }
                    .keyboardShortcut("s", modifiers: .command)
                    .disabled(model.selectedFile == nil)
            }
        }
    }
}
