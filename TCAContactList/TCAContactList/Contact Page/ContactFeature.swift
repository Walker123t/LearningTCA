//
//  ContactFeature.swift
//  TCAContactList
//
//  Created by Trevor Walker on 3/27/24.
//

import Foundation
import ComposableArchitecture

struct Contact: Equatable, Identifiable {
  let id: UUID
  var name: String

  init(id: UUID, name: String = "") {
    self.id = id
    self.name = name
  }
}

@Reducer
struct ContactsFeature {

  @ObservableState
  struct State {
    var contacts: IdentifiedArrayOf<Contact> = []
    /// This will be a nil value when not presented and a non-nil value when presented
//    @Presents var addContact: AddContactFeature.State?
//    @Presents var alertPresentable: AlertState<Action.Alert>?
    @Presents var destination: Destination.State?
    var path = StackState<ContactDetailFeature.State>()

  }

  enum Action {
    case addButtonTapped
    case deleteButtonTapped(id: Contact.ID)
    case destination(PresentationAction<Destination.Action>)
    case path(StackAction<ContactDetailFeature.State, ContactDetailFeature.Action>)

    enum Alert: Equatable {
      case confirmDeletion(id: Contact.ID)
    }
  }

  @Dependency(\.uuid) var uuid

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .addButtonTapped:
        state.destination = .addContact(AddContactFeature.State(contact: Contact(id: self.uuid())))
        return .none

      case let .destination(.presented(.addContact(.delegate(.saveContact(contact))))):
        state.contacts.append(contact)
        return .none

      case let .destination(.presented(.alert(.confirmDeletion(id: id)))):
        state.contacts.remove(id: id)
        return .none

      case let .deleteButtonTapped(id: id):
        state.destination = .alert(AlertState.deleteConfirmation(id: id))
        return .none

      case let .path(.element(id: id, action: .delegate(.confirmDeletion))):
        guard let detailState = state.path[id: id] else { return .none }
        state.contacts.remove(id: detailState.contact.id)
        return .none

      case .path, .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
    .forEach(\.path, action: \.path) {
      ContactDetailFeature()
    }
  }
}

extension ContactsFeature {
  @Reducer(state: .equatable)
  enum Destination/* : Equatable (This is not currently possible due to a bug in swifts compiler. We shall instead accomplish the same thing by passing it through the @Reducer macro */ {
    case addContact(AddContactFeature)
    case alert(AlertState<ContactsFeature.Action.Alert>)
  }
}

extension AlertState where Action == ContactsFeature.Action.Alert {
  static func deleteConfirmation(id: UUID) -> Self {
    Self {
      TextState("Are you sure?")
    } actions: {
      ButtonState(role:.destructive, action: .confirmDeletion(id: UUID(1))) {
        TextState("Delete")
      }
    }
  }
}
