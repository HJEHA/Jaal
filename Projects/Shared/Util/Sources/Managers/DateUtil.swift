//
//  DateFormatter.swift
//  SharedUtil
//
//  Created by 황제하 on 4/9/24.
//

import Foundation

public class DateUtil: DateFormatter {
  public static let shared = DateUtil()
  
  private override init() {
    super.init()
    self.locale = Locale(identifier: "ko_KR")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func toDayOfWeek(from date: Date) -> String {
    self.setLocalizedDateFormatFromTemplate("E")
    return self.string(from: date)
  }
  
  public func day(
    calendar: Calendar,
    from date: Date
  ) -> String {
    return "\(calendar.component(.day, from: date))"
  }
  
  public func toYearMonth(from date: Date) -> String {
    self.setLocalizedDateFormatFromTemplate("yyyy MM")
    return self.string(from: date)
  }
}