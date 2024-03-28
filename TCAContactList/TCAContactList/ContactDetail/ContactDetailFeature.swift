//
//  ContactDetailFeature.swift
//  TCAContactList
//
//  Created by Trevor Walker on 3/27/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ContactDetailFeature {
  @ObservableState
  struct State {
    @Presents var alert: AlertState<Action.Alert>?
    let contact: Contact
  }

  enum Action {
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)
    case deleteButtonTapped

    enum Alert {
      case confirmDeletion
    }

    enum Delegate {
      case confirmDeletion
    }
  }

  @Dependency(\.dismiss) var dismiss

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .alert(.presented(.confirmDeletion)):
        return .run { send in
          await send(.delegate(.confirmDeletion))
          await self.dismiss()
        }
      case .alert, .delegate:
        return .none

      case .deleteButtonTapped:
        state.alert = .confirmDeletion
        return .none
      }
    }
    .ifLet(\.$alert, action: \.alert)
  }
}

extension AlertState where Action == ContactDetailFeature.Action.Alert {
  static let confirmDeletion = Self {
    TextState("Are you sure?")
  } actions: {
    ButtonState(role: .destructive, action: .confirmDeletion) {
      TextState("Delete")
    }
  }
}
