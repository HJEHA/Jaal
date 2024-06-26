//
//  MeasurementStore.swift
//  FeatureMeasurement
//
//  Created by 황제하 on 4/2/24.
//

import UIKit

import ComposableArchitecture

import FeatureMeasurementInterface
import DomainActivity
import DomainActivityInterface
import CoreImageProcss
import CoreUserDefaults
import SharedUtil

extension MeasurementStore {
  public init() {
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.activityClient) var activityClient
    @Dependency(\.imageProcess) var imageProcess
    
    let reducer: Reduce<State, Action> = Reduce { state, action in
      switch action {
        case let .faceTracking(action):
          switch action {
            case let .saveImage(image):
              guard let image else {
                return .none
              }
              
              let name = DateUtil.shared.toNow(from: .now)
              ImageCache.shared.saveImageToDiskCache(
                image,
                forKey: name
              )
              
              return .run { [image, name] send in
                let data = await imageProcess.toDataWithDownSample(
                  image, 100
                )
                guard let data else {
                  return ()
                }
                let timeLapse = Timelapse(
                  thumbnail: data,
                  name: name
                )
                await send(.saveTimeLapseResponse(timeLapse))
              }
              
            default:
              return .none
          }
          
        case .onAppear:
          UIApplication.shared.isIdleTimerDisabled = true
          state.measurementStart = .init()
          return .none
          
        case .measurementStart(.initialEnded):
          return .send(.start)
       
        case .start:
          state.measurementStart = nil
          state.initialFaceCenter = state.sharedState.faceCenter
          
          return .run { send in
            for await _ in clock.timer(interval: .seconds(1)) {
              await send(.timerTicked)
              await send(.faceDistance)
            }
          }
          .cancellable(id: CancelID.timer)
          
        case .timerTicked:
          state.time += 1
          
          if state.mode == .focus
              && (KUUserDefaults.timerValue * 60) == state.time
          {
            return .send(.saveActivity)
          }
          
          if state.time % 3 == 0
             && KUUserDefaults.isSaveTimeLapse == true
          {
            return .send(.faceTracking(.snapshot))
          }
          
          return .none
          
        case .faceDistance:
          guard let center = state.sharedState.faceCenter,
                let initialCenter = state.initialFaceCenter
          else {
            return .none
          }
          
          if initialCenter.distance(to: center) > 0.1 {
            state.isWarning = true
            UIDevice.vibrate()
          } else {
            state.correctPoseTime += 1
            state.isWarning = false
          }
          
          return .none
          
        case .eyeBlinked:
          if state.measurementStart != nil {
            return .none
          }
          state.eyeBlinkCount += 1
          state.isSleep = false
          state.sleepTime = KUUserDefaults.sleepTimerValue
          
          return .concatenate([
            .cancel(id: CancelID.sleepTimer),
            .none
          ])
          
        case .sleepTimerStart:
          guard state.mode == .focus else {
            return .none
          }
          
          return .run { send in
            for await _ in clock.timer(interval: .seconds(1)) {
              await send(.sleepTimerTicked)
            }
          }
          .cancellable(id: CancelID.sleepTimer)
          
        case .sleepTimerTicked:
          state.sleepTime -= 1
          
          if state.sleepTime <= 0 {
            state.isSleep = true
            UIDevice.vibrate()
          }
          
          return .none
          
        case let .saveTimeLapseResponse(value):
          state.timeLapseData.append(value)
          
          return .none
          
        case .closeButtonTapped:
          UIApplication.shared.isIdleTimerDisabled = false
          
          if state.measurementStart != nil {
            return .none
          }
          
          return .send(.saveActivity)
          
        case .saveActivity:
          let activity: Activity
          do {
            activity = Activity(
              title: state.title,
              measurementMode: state.mode,
              activityDuration: state.time,
              correctPoseTime: state.correctPoseTime,
              blinkCount: state.eyeBlinkCount,
              timelapse: state.timeLapseData
            )
            try activityClient.add(activity)
          } catch { }
          
          return .concatenate([
            .cancel(id: CancelID.timer),
            .send(.saveActivityCompleted(activity))
          ])
          
        default:
          return .none
      }
    }
    
    self.init(
      reducer: reducer,
      faceTracking: FaceTrackingStore(),
      measurementStart: MeasurementStartStore()
    )
  }
}
