//
//  TCAContactListUITests.swift
//  TCAContactListTests
//
//  Created by Trevor Walker on 3/27/24.
//

import XCTest
import ComposableArchitecture

@testable import TCAContactList

@MainActor
final class TCAContactListUITests: XCTestCase {
  func testAddFlow() async {
    let store = TestStore(initialState: ContactsFeature.State(),
                          reducer: { ContactsFeature() },
                          withDependencies: { $0.uuid = .incrementing })

    await store.send(.addButtonTapped) {
          $0.destination = .addContact(
            AddContactFeature.State(contact: Contact(id: UUID(0)))
          )
        }
    
        await store.send(\.destination.addContact.setName, "Blob Jr."){
          $0.destination?.addContact?.contact.name = "Blob Jr."
        }
    
        await store.send(\.destination.addContact.saveButtonTapped)
    
        await store.receive(
          \.destination.addContact.delegate.saveContact,
           Contact(id: UUID(0), name: "Blob Jr.")
        ) {
          $0.contacts = [
            Contact(id: UUID(0), name: "Blob Jr.")
          ]
        }
    
        await store.receive(\.destination.dismiss) {
          $0.destination = nil
        }
  }

  func testAddFlow_NonExhaustive() async {
    let store = TestStore(initialState: ContactsFeature.State(),
                          reducer: { ContactsFeature() },
                          withDependencies: { $0.uuid = .incrementing })
    store.exhaustivity = .off

    await store.send(.addButtonTapped)
    await store.send(\.destination.addContact.setName, "Blob Jr.")
    await store.send(\.destination.addContact.saveButtonTapped)
    await store.skipReceivedActions()
    store.assert {
      $0.contacts = [
      Contact(id: UUID(0), name: "Blob Jr.")
      ]
      $0.destination = nil
    }
  }

  func testDeleteFlow() async {
    let store = TestStore(
      initialState: ContactsFeature.State(
        contacts: [
          Contact(id: UUID(0), name: "Blob"),
          Contact(id: UUID(1), name: "Blob Jr.")
        ]),
      reducer: { ContactsFeature() },
      withDependencies: { $0.uuid = .incrementing })

    await store.send(.deleteButtonTapped(id: UUID(1))) {
      $0.destination = .alert(AlertState.deleteConfirmation(id: UUID(1)))
    }

    await store.send(.destination(.presented(.alert(.confirmDeletion(id: UUID(1)))))) {
      $0.contacts.remove(id: UUID(1))
      $0.destination = nil
    }
  }
}

