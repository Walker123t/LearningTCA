//
//  AppView.swift
//  TCA
//
//  Created by Trevor Walker on 3/26/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct AppFeature {
  struct State: Equatable {
    var tabState1 = CounterFeature.State()
    var tabState2 = CounterFeature.State()
  }

  enum Action {
    case tabAction1(CounterFeature.Action)
    case tabAction2(CounterFeature.Action)
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.tabState1, action: \.tabAction1) {
      CounterFeature()
    }

    Scope(state: \.tabState2, action: \.tabAction2) {
      CounterFeature()
    }
    
    Reduce { state, action in

      return .none
    }
  }
}

struct AppView: View {

  let store: StoreOf<AppFeature>

    var body: some View {
      TabView {
        CounterView(store: store.scope(state: \.tabState1, action: \.tabAction1))
          .tabItem {
            Text("Counter 1")
          }

        CounterView(store: store.scope(state: \.tabState2, action: \.tabAction2))
          .tabItem {
            Text("Counter 2")
          }
      }
    }
}
