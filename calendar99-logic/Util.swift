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

    /// Calculate a new MonthComp based on a month offset.
    ///
    /// - Parameters:
    ///   - prevComp: The previous MonthComp.
    ///   - monthOffset: A month offset value.
    /// - Returns: A MonthComp instance.
    static func newMonthComp(_ prevComp: NNCalendar.MonthComp,
                             _ monthOffset: Int) -> NNCalendar.MonthComp? {
      let calendar = Calendar.current
      let components = prevComp.dateComponents()
      var componentOffset = DateComponents()
      componentOffset.setValue(monthOffset, for: .month)

      return calendar.date(from: components)
        .flatMap({calendar.date(byAdding: componentOffset, to: $0)})
        .flatMap({(
          calendar.component(.month, from: $0),
          calendar.component(.year, from: $0
        ))})
        .map({NNCalendar.MonthComp(month: $0, year: $1)})
    }
  }
}
