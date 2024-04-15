//
//  Activity.swift
//  DomainActivityInterface
//
//  Created by 황제하 on 4/9/24.
//

import Foundation
import SwiftData

import SharedUtil

@Model
public final class Activity: Identifiable {
  public var title: String
  public var measurementMode: MeasurementMode
  public var measurementTitle: String
  public var activityDuration: Int
  public var blinkCount: Int
  public var thumbnail: [Data]
  public var date: Date
  public var dateString: String
  
  public init(
    title: String,
    measurementMode: MeasurementMode,
    activityDuration: Int,
    blinkCount: Int,
    thumbnail: [Data]
  ) {
    self.title = title
    self.date = .now
    self.dateString = DateUtil.shared.toYearMonthDay(from: .now)
    self.measurementMode = measurementMode
    self.measurementTitle = measurementMode.title
    self.activityDuration = activityDuration
    self.blinkCount = blinkCount
    self.thumbnail = thumbnail
  }
}