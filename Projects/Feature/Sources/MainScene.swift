//
//  MainScene.swift
//  Feature
//
//  Created by 황제하 on 3/29/24.
//

import SwiftUI

import SharedDesignSystem

public enum MainScene: Hashable {
  case home
  case measurement
  case record
  
  var title: String {
    switch self {
      case .home:
        return "홈"
      case .measurement:
        return "측정하기"
      case .record:
        return "기록"
    }
  }
  
  var imageName: String {
    switch self {
      case .home:
        return "house.fill"
      case .measurement:
        return "camera.fill"
      case .record:
        return "list.bullet"
    }
  }
}
