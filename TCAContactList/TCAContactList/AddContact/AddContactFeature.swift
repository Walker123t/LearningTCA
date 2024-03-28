//
//  AddContactFeature.swift
//  TCAContactList
//
//  Created by Trevor Walker on 3/27/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AddContactFeature {
  @ObservableState
  struct State: Equatable {
    var contact: Contact
  }

  enum Action {
    case saveButtonTapped
    case cancelButtonTapped
    case setName(String)
    case delegate(Delegate)

    @CasePathable
    enum Delegate: Equatable {
      case saveContact(Contact)
    }
  }

  @Dependency(\.dismiss) var dismiss

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .saveButtonTapped:
        return .run { [contact = state.contact] send in
          await send(.delegate(.saveContact(contact)))
          await self.dismiss()
        }
      case .cancelButtonTapped:
        return .run { _ in await self.dismiss() }
      case let .setName(name):
        state.contact.name = name
        return .none
      case .delegate:
        return .none
      }
    }
  }
}
