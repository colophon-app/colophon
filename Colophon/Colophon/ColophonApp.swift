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
        // Byte-exact editing: force smart substitutions off for this app even when the user's
        // system-wide text preferences enable them. These must be written to the app's OWN
        // defaults domain (set), not the registration domain (register) — the registration
        // domain is the LOWEST priority and is overridden by the global/system value, which is
        // why double-space was still inserting a period. Quote/dash/replacement/spelling also
        // have NSTextView properties (set in MarkdownTextView), but period substitution has no
        // view property, so this default is its only control.
        for key in [
            "NSAutomaticQuoteSubstitutionEnabled",
            "NSAutomaticDashSubstitutionEnabled",
            "NSAutomaticPeriodSubstitutionEnabled",
            "NSAutomaticTextReplacementEnabled",
            "NSAutomaticSpellingCorrectionEnabled",
            "NSAutomaticCapitalizationEnabled",
        ] {
            UserDefaults.standard.set(false, forKey: key)
        }
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
