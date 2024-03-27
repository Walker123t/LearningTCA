//
//  ContentView.swift
//  TCA
//
//  Created by Trevor Walker on 3/26/24.
//

import SwiftUI
import ComposableArchitecture

/// @Reducer allots us to describe how to evolve the current state of an application to the next state provided an action, and describes what effects should be executed later by the store
@Reducer
struct CounterFeature {

  /// Holds the information and 'State' of the view
  @ObservableState
  struct State: Equatable {
    var count = 0
    var fact: String?
    var isLoading = false
    var isTimerRunning = false
  }

  /// A list of actions that the view can perform
  enum Action {
    case decrementButtonTapped
    case incrementButtonTapped
    case factButtonTapped
    case factResponse(String)
    case toggleTimerButtonTapped
    case timerTick
  }

  // Easy way to use CancelID's allowing us to cances Events currently happening that have the same ID
  /// Adding Cancellable id to event
  ///  .cancellable(id: CancelID.timer)
  ///
  /// Canceling Event
  ///  .cancel(id: CancelID.timer)
    enum CancelID {
    case timer
  }

  @Dependency(\.continuousClock) var clock
  @Dependency(\.numberFact) var numberFact

  /// How the view will react when an action is performed
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .decrementButtonTapped:
        state.count -= 1
        state.fact = nil
        return .none
      case .incrementButtonTapped:
        state.count += 1
        state.fact = nil
        return .none
      case .factButtonTapped:
        state.fact = nil
        state.isLoading = true

        /// The Composable Architecture separates the simple, pure transformations of state from the complex, messy side effects. It is one of the core tenets of the library and there are a lot of benefits to doing so. Luckily for us, the library gives us a tool that is appropriate for executing side effects. It is called Effect and it is explored in the next section.
        /**
        let (data, _) = try await URLSession.shared
          .data(from: URL(string: "http://numbersapi.com/\(state.count)")!)

         state.fact = String(decoding: data, as: UTF8.self)
         state.isLoading = false
         **/
        // 🛑 'async' call in a function that does not support concurrency
        // 🛑 Errors thrown from here are not handled


        /// .run puts us into an Asynchronous context allowing us to do async work. It also handles sending actions back into the system
        /// [count = state.count] is a capture list capturing the count and allowing us to use it inside our closure
        /// NOTE: We cannot directly access state.count becuase closures cannot capture inout state
        return .run { [count = state.count] send in
          // ✅ Do async work in here, and send actions back into the system.
          try await send(.factResponse(self.numberFact.fetch(count)))
        }
      case .factResponse(let fact):
        state.fact = fact
        state.isLoading = false
        return .none
      case .toggleTimerButtonTapped:
        state.isTimerRunning.toggle()
        if state.isTimerRunning {
          return .run { send in
            for await _ in self.clock.timer(interval: .seconds(1)) {
              await send(.timerTick)
            }
          }
          .cancellable(id: CancelID.timer)
        } else {
          return .cancel(id: CancelID.timer)
        }
      case .timerTick:
        state.count += 1
        state.fact = nil
        return .none
      }
    }
  }
}

struct CounterView: View {
  /// Similar to a view model; Drives the state of your application
  let store: StoreOf<CounterFeature>

  var body: some View {
    VStack {
      Text("\(store.count)")
        .font(.largeTitle)
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(10)
      HStack {
        TCAButton("-") {
          /// Sends an action to our store causing the Store's body to update returning an event
          store.send(.decrementButtonTapped)
        }
        TCAButton("+") {
          store.send(.incrementButtonTapped)
        }
      }
      TCAButton(store.isTimerRunning ? "Stop Timer" : "Start Timer") {
        store.send(.toggleTimerButtonTapped)
      }
      TCAButton("Fact") {
        store.send(.factButtonTapped)
      }

      if store.isLoading {
        ProgressView()
      } else if let fact = store.fact {
        Text(fact)
          .font(.largeTitle)
          .multilineTextAlignment(.center)
          .padding()
      }
    }
  }

  func TCAButton(_ title: String, action: @escaping () -> ()) -> some View {
    Button(title, action: action)
      .font(.largeTitle)
      .padding()
      .background(Color.black.opacity(0.1))
      .cornerRadius(10)
  }
}

#Preview {
  CounterView(store: Store(initialState: CounterFeature.State()) {
    CounterFeature()
  })
}
