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
  func calculateRange(_ comps: NNCalendar.MonthComp,
                      _ firstDayOfWeek: Int,
                      _ rowCount: Int,
                      _ columnCount: Int) -> [Date]
}

/// This is similar to the date calculator, but it calculates only single dates
/// based on an offset.
public protocol NNSingleDateCalculatorType {

  /// Calculate the date in a month/year pair using an offset from the first
  /// date in the grid. This is similar to the date calculator, but instead of
  /// calculating the whole date range, we calculate only single dates in order
  /// to minimize the memory footprint that comes with storing all the dates.
  ///
  /// - Parameters:
  ///   - components: A Components instance.
  ///   - firstDayOfWeek: The first day of a week (e.g. Monday).
  ///   - firstDateOffset: The offset from the first date in the grid.
  /// - Returns: A Date instance.
  func calculateDate(_ comps: NNCalendar.MonthComp,
                     _ firstDayOfWeek: Int,
                     _ firstDateOffset: Int) -> Date?
}

public extension NNCalendar.DateCalculator {

  /// Sequential date calculator.
  public final class Sequential {
    public init() {}

    /// Calculate the first date in the grid.
    fileprivate func calculateFirstDate(_ comps: NNCalendar.MonthComp,
                                        _ firstDayOfWeek: Int) -> Date? {
      let calendar = Calendar.current
      let dateComponents = comps.dateComponents()

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
    }
  }
}

// MARK: - NNDateCalculatorType
extension NNCalendar.DateCalculator.Sequential: NNDateCalculatorType {

  /// We need to find the first day of the week in which the current month
  /// starts (not necessarily the first day of the month).
  public func calculateRange(_ comps: NNCalendar.MonthComp,
                             _ firstDayOfWeek: Int,
                             _ rowCount: Int,
                             _ columnCount: Int) -> [Date] {
    let calendar = Calendar.current

    return calculateFirstDate(comps, firstDayOfWeek)
      .map({(date: Date) -> [Date] in
        (0..<rowCount * columnCount).flatMap({
          return calendar.date(byAdding: .day, value: $0, to: date)
        })
      })
      .getOrElse([])
  }
}

// MARK: - NNSingleDateCalculatorType
extension NNCalendar.DateCalculator.Sequential: NNSingleDateCalculatorType {
  public func calculateDate(_ comps: NNCalendar.MonthComp,
                            _ firstDayOfWeek: Int,
                            _ firstDateOffset: Int) -> Date? {
    let calendar = Calendar.current

    return calculateFirstDate(comps, firstDayOfWeek)
      .flatMap({calendar.date(byAdding: .day, value: firstDateOffset, to: $0)})
  }
}
