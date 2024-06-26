//
//  MeasurementRootInterface.swift
//  FeatureMeasurementInterface
//
//  Created by 황제하 on 4/01/24.
//

import Foundation

import ComposableArchitecture

import DomainActivityInterface
import CoreUserDefaults

@Reducer
public struct MeasurementRootStore {

  private let reducer: Reduce<State, Action>
  private let measurement: MeasurementStore
  private let end: MeasurementEndStore
  
  public init(
    reducer: Reduce<State, Action>,
    measurement: MeasurementStore,
    end: MeasurementEndStore
  ) {
    self.reducer = reducer
    self.measurement = measurement
    self.end = end
  }
  
  @ObservableState
  public struct State: Equatable {
    @Presents public var measurement: MeasurementStore.State?
    public var end: MeasurementEndStore.State?
    
    public var title: String = ""
    public var placeholder: String = "이전 제목 (\(KUUserDefaults.lastMeasurementTitle))"
    public var selectedMode: MeasurementMode = .normal
    
    public var selectedTimerPickerItem: Int = KUUserDefaults.timerValue
    public var selectedSleepTimerPickerItem: Int = KUUserDefaults.sleepTimerValue
    public var timerPickerItems: [Int] = [
    5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60
    ]
    public var isSaveTimeLapse: Bool = KUUserDefaults.isSaveTimeLapse
    
    @Presents public var alert: AlertState<Action.Alert>?
    
    public init() { }
  }
  
  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    
    case measurement(PresentationAction<MeasurementStore.Action>)
    case end(MeasurementEndStore.Action)
    
    case onAppear
    case modeButtonTapped(MeasurementMode)
    case startButtonTapped
    
    case alert(PresentationAction<Alert>)
    case showNotSupportedAlert
    public enum Alert: Equatable {
      case doneTapped
    }
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    reducer
      .ifLet(\.$measurement, action: /Action.measurement) {
        measurement
      }
      .ifLet(\.end, action: \.end) {
        end
      }
      .ifLet(\.$alert, action: \.alert)
  }
}
