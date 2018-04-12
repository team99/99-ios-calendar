//
//  Util.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP

public extension NNCalendar {

  /// Date utilities.
  final class DateUtil {

    /// Calculate a new month and year based on a month offset.
    ///
    /// - Parameters:
    ///   - prevMonth: The previous month.
    ///   - prevYear: The previous year.
    ///   - monthOffset: A month offset value.
    /// - Returns: A tuple of month and year.
    static func newMonthAndYear(_ prevMonth: Int,
                                _ prevYear: Int,
                                _ monthOffset: Int) -> (month: Int, year: Int)? {
      let calendar = Calendar.current
      var components = DateComponents()
      components.setValue(prevMonth, for: .month)
      components.setValue(prevYear, for: .year)
      var componentOffset = DateComponents()
      componentOffset.setValue(monthOffset, for: .month)

      return calendar.date(from: components)
        .flatMap({calendar.date(byAdding: componentOffset, to: $0)})
        .flatMap({(
          calendar.component(.month, from: $0),
          calendar.component(.year, from: $0
        ))})
    }
  }
}
