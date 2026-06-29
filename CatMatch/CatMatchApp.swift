//
//  CatMatchApp.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 28/06/26.
//

import SwiftUI
import CatUI

@main
struct CatMatchApp: App {

    // MARK: - Initializers

    init() {
        CatFontRegistration.registerAll()
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
