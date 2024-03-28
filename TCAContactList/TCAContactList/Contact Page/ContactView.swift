//
//  ContactView.swift
//  TCAContactList
//
//  Created by Trevor Walker on 3/27/24.
//

import SwiftUI
import ComposableArchitecture

struct ContactsView: View {
  @Bindable var store: StoreOf<ContactsFeature>

  var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
      List {
        ForEach(store.contacts) { contact in
          contactCell(for: contact)
        }
      }
      .navigationTitle("Contacts")
      .toolbar {
        ToolbarItem {
          Button {
            store.send(.addButtonTapped)
          } label: {
            Image(systemName: "plus")
          }
        }
      }
    } destination: { 
      ContactDetailView(store: $0)
    }
    .sheet(item: $store.scope(state: \.destination?.addContact, action: \.destination.addContact)) { addContactStore in
      NavigationStack {
        AddContactView(store: addContactStore)
      }
    }
    .alert($store.scope(state: \.destination?.alert,
                               action: \.destination.alert))
  }

  private func contactCell(for contact: Contact) -> some View {
    NavigationLink(state: ContactDetailFeature.State(contact: contact)) {
      HStack {
        Text(contact.name)
        Spacer()
        Button {
          store.send(.deleteButtonTapped(id: contact.id))
        } label: {
          Image(systemName: "trash")
            .tint(.red)
        }
      }
    }
    .buttonStyle(.borderless)
  }
}

#Preview {
  ContactsView(
    store: Store(
      initialState: ContactsFeature.State(
        contacts: [
          Contact(id: UUID(), name: "Blob"),
          Contact(id: UUID(), name: "Blob Jr"),
          Contact(id: UUID(), name: "Blob Sr"),
        ]
      )
    ) {
      ContactsFeature()
    }
  )
}
