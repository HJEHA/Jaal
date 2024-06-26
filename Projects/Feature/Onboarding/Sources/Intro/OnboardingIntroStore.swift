//
//  OnboardingIntroStore.swift
//  FeatureOnboarding
//
//  Created by 황제하 on 4/25/24.
//

import Foundation

import ComposableArchitecture

import FeatureOnboardingInterface

extension OnboardingIntroStore {
  public init() {
    
    let reducer: Reduce<State, Action> = Reduce { state, action in
      switch action {
        case .onAppear:
          return .none
          
        case .nextButtonTapped:
          if state.tabViewIndex == 2 {
            return .run { send in
              await send(.goToProfile)
            }
          }
          
          state.tabViewIndex = min(state.tabViewIndex + 1, 2)
          
          return .none
          
        default:
          return .none
      }
    }
    
    self.init(reducer: reducer)
  }
}
