//
//  TCAApp.swift
//  TCA
//
//  Created by Trevor Walker on 3/26/24.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCAApp: App {
  /// Source of truth for the state of our application
  static let store = Store(initialState: AppFeature.State()) {
    AppFeature()
      ._printChanges()
  }
    var body: some Scene {
        WindowGroup {
          AppView(store: TCAApp.store)
        }
    }
}
