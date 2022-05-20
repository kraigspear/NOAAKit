//
//  NoaaTestApp.swift
//  NoaaTest
//
//  Created by Kraig Spear on 7/14/21.
//

import SwiftUI

@main
struct NoaaTestApp: App {
    let contentViewModel = ContentViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(contentViewModel)
        }
    }
}
