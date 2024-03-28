//
//  TCAContactListApp.swift
//  TCAContactList
//
//  Created by Trevor Walker on 3/27/24.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCAContactListApp: App {
  static let store = Store(initialState: ContactsFeature.State(), reducer: { ContactsFeature()._printChanges() })
    var body: some Scene {
        WindowGroup {
          ContactsView(store: TCAContactListApp.store)
        }
    }
}
