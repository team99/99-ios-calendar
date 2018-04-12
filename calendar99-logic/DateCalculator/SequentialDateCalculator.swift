//
//  SequentialDateCalculator.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

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
  public func calculateDateRange(_ comps: NNCalendar.MonthComp,
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
  public func calculateDateWithOffset(_ comps: NNCalendar.MonthComp,
                                      _ firstDayOfWeek: Int,
                                      _ firstDateOffset: Int) -> Date? {
    let calendar = Calendar.current

    return calculateFirstDate(comps, firstDayOfWeek)
      .flatMap({calendar.date(byAdding: .day, value: firstDateOffset, to: $0)})
  }
}

// MARK: - NNGridSelectionCalculatorType
extension NNCalendar.DateCalculator.Sequential: NNGridSelectionCalculatorType {
  public func calculateGridSelection(_ months: [NNCalendar.Month],
                                     _ firstDayOfWeek: Int,
                                     _ selection: Date)
    -> [NNCalendar.GridSelection]
  {
    let monthComp = NNCalendar.MonthComp(selection)

    return months.enumerated()
      .first(where: {$0.1.month == monthComp.month && $0.1.year == monthComp.year})
      .map({(offset: Int, month: NNCalendar.Month) in
        self.calculateGridSelection(months, month, offset, firstDayOfWeek, selection)
      })
      .getOrElse([])
  }

  /// Since each Date may be included in different months (e.g., if there are
  /// more than 31 cells, the calendar view may include dates from previous/
  /// next months). To be safe, we calculate the selection for one month before
  /// and after the specified month.
  fileprivate func calculateGridSelection(_ months: [NNCalendar.Month],
                                          _ month: NNCalendar.Month,
                                          _ monthOffset: Int,
                                          _ firstDayOfWeek: Int,
                                          _ selection: Date)
    -> [NNCalendar.GridSelection]
  {
    let calculate = {(month: NNCalendar.Month, offset: Int) -> NNCalendar.GridSelection? in
      if let firstDate = self.calculateFirstDate(month.monthComp, firstDayOfWeek) {
        let interval = selection.timeIntervalSince(firstDate)
        let diff = Int(interval / 60 / 60 / 24)

        if diff >= 0 && diff < month.dayCount {
          return NNCalendar.GridSelection(monthIndex: offset, dayIndex: diff)
        }
      }

      return Optional.nothing()
    }

    var gridSelections = [NNCalendar.GridSelection]()
    calculate(month, monthOffset).map({gridSelections.append($0)})
    let prevMonthOffset = monthOffset - 1
    let nextMonthOffset = monthOffset + 1

    if prevMonthOffset >= 0 && prevMonthOffset < months.count {
      let prevMonth = months[prevMonthOffset]
      calculate(prevMonth, prevMonthOffset).map({gridSelections.append($0)})
    }

    if nextMonthOffset >= 0 && nextMonthOffset < months.count {
      let nextMonth = months[nextMonthOffset]
      calculate(nextMonth, nextMonthOffset).map({gridSelections.append($0)})
    }

    return gridSelections
  }
}

// MARK: - NNSingleMonthGridSelectionCalculatorType
extension NNCalendar.DateCalculator.Sequential: NNSingleMonthGridSelectionCalculatorType {

  /// We need to include the previous and next months here as well, and call
  /// the pre-specified method that deals with Month Array. We also assume that
  /// the day count remains the same for all Months.
  public func calculateGridSelection(_ month: NNCalendar.Month,
                                     _ firstDayOfWeek: Int,
                                     _ selection: Date)
    -> [NNCalendar.GridSelection]
  {
    var months = [NNCalendar.Month]()
    let calendar = Calendar.current
    let dateComponents = month.monthComp.dateComponents()

    calendar.date(from: dateComponents)
      .flatMap({calendar.date(byAdding: .month, value: -1, to: $0)})
      .map({NNCalendar.MonthComp($0)})
      .map({month.with(monthComp: $0)})
      .map({months.append($0)})

    months.append(month)

    calendar.date(from: dateComponents)
      .flatMap({calendar.date(byAdding: .month, value: 1, to: $0)})
      .map({NNCalendar.MonthComp($0)})
      .map({month.with(monthComp: $0)})
      .map({months.append($0)})

    return calculateGridSelection(months, firstDayOfWeek, selection)
  }
}
