//
//  DateCalculator.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Calculate dates within a specific month/year. Classes that implement this
/// protocol should be able to customize the date array using column/row count.
/// For example, a normal calendar would have its weekday view on top, but on
/// the off chance that we want said view to be vertical, we can simply provide
/// a different date calculator implementation.
public protocol NNDateCalculatorType {

  /// Calculate the dates in a month/year pair. The total number of dates should
  /// equal rowCount * columnCount, but how exactly they should be partitioned
  /// is left to implementation.
  ///
  /// - Parameters:
  ///   - components: A Components instance.
  ///   - firstDayOfWeek: The first day of a week (e.g. Monday).
  ///   - rowCount: The number of rows in a calendar grid.
  ///   - columnCount: The number of columns in a calendar grid.
  /// - Returns: An Array of Date.
  func calculateRange(_ components: NNCalendar.MonthComponents,
                      _ firstDayOfWeek: Int,
                      _ rowCount: Int,
                      _ columnCount: Int) -> [Date]
}

public extension NNCalendar.DateCalculator {

  /// Sequential date calculator.
  public final class Sequential: NNDateCalculatorType {
    public init() {}

    /// We need to find the first day of the week in which the current month
    /// starts (not necessarily the first day of the month).
    public func calculateRange(_ components: NNCalendar.MonthComponents,
                               _ firstDayOfWeek: Int,
                               _ rowCount: Int,
                               _ columnCount: Int) -> [Date] {
      let calendar = Calendar.current
      var dateComponents = DateComponents()
      dateComponents.setValue(components.month, for: .month)
      dateComponents.setValue(components.year, for: .year)

      return calendar.date(from: dateComponents)
        .flatMap({(date: Date) -> Date? in
          let weekday = calendar.component(.weekday, from: date)
          let offset: Int

          if weekday < firstDayOfWeek {
            offset = 7 - (firstDayOfWeek - weekday)
          } else {
            offset = weekday - firstDayOfWeek
          }

          return calendar.date(byAdding: .day, value: -offset, to: date)
        })
        .map({(date: Date) -> [Date] in
          (0..<rowCount * columnCount).flatMap({
            return calendar.date(byAdding: .day, value: $0, to: date)
          })
        })
        .getOrElse([])
    }
  }
}
