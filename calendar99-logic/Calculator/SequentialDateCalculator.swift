//
//  SequentialDateCalculator.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP

public extension NNCalendar.DateCalculator {

  /// Sequential date calculator.
  public final class Sequential {
    fileprivate let calendar: Calendar
    fileprivate let rowCount: Int
    fileprivate let columnCount: Int
    fileprivate let firstWeekday: Int

    public init(_ rowCount: Int, _ columnCount: Int, _ firstWeekday: Int) {
      self.rowCount = rowCount
      self.columnCount = columnCount
      self.firstWeekday = firstWeekday
      calendar = Calendar.current
    }
    
    /// Calculate the first date in the grid.
    fileprivate func calculateFirstDate(_ month: NNCalendar.Month,
                                        _ firstWeekday: Int) -> Date? {
      let dateComponents = month.dateComponents()

      return calendar.date(from: dateComponents)
        .flatMap({(date: Date) -> Date? in
          let weekday = calendar.component(.weekday, from: date)
          let offset: Int

          if weekday < firstWeekday {
            offset = 7 - (firstWeekday - weekday)
          } else {
            offset = weekday - firstWeekday
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
  public func calculateDateRange(_ month: NNCalendar.Month) -> [Date] {
    return calculateFirstDate(month, firstWeekday)
      .map({(date: Date) -> [Date] in (0..<rowCount * columnCount).flatMap({
        return calendar.date(byAdding: .day, value: $0, to: date)
      })})
      .getOrElse([])
  }
}

// MARK: - NNSingleDateCalculatorType
extension NNCalendar.DateCalculator.Sequential: NNSingleDateCalculatorType {
  public func calculateDateWithOffset(_ month: NNCalendar.Month,
                                      _ firstDateOffset: Int) -> Date? {
    return calculateFirstDate(month, firstWeekday).flatMap({
      return calendar.date(byAdding: .day, value: firstDateOffset, to: $0)
    })
  }
}

// MARK: - NNMultiMonthGridSelectionCalculator
extension NNCalendar.DateCalculator.Sequential: NNMultiMonthGridSelectionCalculator {
  fileprivate func calculateGridSelection(_ monthComps: [NNCalendar.MonthComp],
                                          _ selection: Date)
    -> Set<NNCalendar.GridSelection>
  {
    let month = NNCalendar.Month(selection)

    return monthComps.enumerated()
      .first(where: {$0.1.month == month})
      .map({(offset: Int, month: NNCalendar.MonthComp) in
        calculateGridSelection(monthComps, month, offset, selection)
      })
      .getOrElse([])
  }

  /// Since each Date may be included in different months (e.g., if there are
  /// more than 31 cells, the calendar view may include dates from previous/
  /// next months). To be safe, we calculate the selection for one month before
  /// and after the specified month.
  fileprivate func calculateGridSelection(_ monthComps: [NNCalendar.MonthComp],
                                          _ monthComp: NNCalendar.MonthComp,
                                          _ monthIndex: Int,
                                          _ selection: Date)
    -> Set<NNCalendar.GridSelection>
  {
    let calculate = {(month: NNCalendar.MonthComp, offset: Int)
      -> NNCalendar.GridSelection? in
      if let firstDate = self.calculateFirstDate(month.month, self.firstWeekday) {
        let diff = self.calendar.dateComponents([.day], from: firstDate, to: selection)

        if let dayDiff = diff.day, dayDiff >= 0 && dayDiff < month.dayCount {
          return NNCalendar.GridSelection(offset, dayDiff)
        }
      }

      return Optional.nothing()
    }

    var gridSelections = Set<NNCalendar.GridSelection>()
    _ = calculate(monthComp, monthIndex).map({gridSelections.insert($0)})
    let prevMonthIndex = monthIndex - 1
    let nextMonthIndex = monthIndex + 1

    if prevMonthIndex >= 0 && prevMonthIndex < monthComps.count {
      let prevMonth = monthComps[prevMonthIndex]
      _ = calculate(prevMonth, prevMonthIndex).map({gridSelections.insert($0)})
    }

    if nextMonthIndex >= 0 && nextMonthIndex < monthComps.count {
      let nextMonth = monthComps[nextMonthIndex]
      _ = calculate(nextMonth, nextMonthIndex).map({gridSelections.insert($0)})
    }

    return gridSelections
  }

  public func calculateGridSelectionChanges(_ monthComps: [NNCalendar.MonthComp],
                                            _ prevSelections: Set<Date>,
                                            _ currentSelections: Set<Date>)
    -> Set<NNCalendar.GridSelection>
  {
    return Set(extractChanges(prevSelections, currentSelections)
      .flatMap({self.calculateGridSelection(monthComps, $0)}))
  }
}

// MARK: - NNSingleMonthGridSelectionCalculatorType
extension NNCalendar.DateCalculator.Sequential: NNSingleMonthGridSelectionCalculator {
  public func calculateGridSelectionChanges(_ monthComp: NNCalendar.MonthComp,
                                            _ prevSelections: Set<Date>,
                                            _ currentSelections: Set<Date>)
    -> Set<NNCalendar.GridSelection>
  {
    return Set(extractChanges(prevSelections, currentSelections)
      .flatMap({self.calculateGridSelection(monthComp, $0)}))
  }

  /// We need to include the previous and next month components here as well,
  /// and call the pre-specified method that deals with Month Array. We also
  /// assume that the day count remains the same for all Months.
  fileprivate func calculateGridSelection(_ monthComp: NNCalendar.MonthComp,
                                          _ selection: Date)
    -> Set<NNCalendar.GridSelection>
  {
    var monthComps = [NNCalendar.MonthComp]()

    monthComp.month.with(monthOffset: -1)
      .map({monthComp.with(month: $0)})
      .map({monthComps.append($0)})

    monthComps.append(monthComp)

    monthComp.month.with(monthOffset: 1)
      .map({monthComp.with(month: $0)})
      .map({monthComps.append($0)})

    return calculateGridSelection(monthComps, selection)
  }


}

// MARK: - NNHighlightPartCalculator
extension NNCalendar.DateCalculator.Sequential: NNHighlightPartCalculator {
  public func calculateHighlightPart(_ selections: Set<Date>, _ date: Date)
    -> NNCalendar.HighlightPart
  {
    guard selections.contains(date) else { return .none }
    var flags: NNCalendar.HighlightPart?

    if
      let nextDate = calendar.date(byAdding: .day, value: 1, to: date),
      !selections.contains(nextDate)
    {
      flags = flags.map({$0.union(.end)}).getOrElse(.end)
    }

    if
      let prevDate = calendar.date(byAdding: .day, value: -1, to: date),
      !selections.contains(prevDate)
    {
      flags = flags.map({$0.union(.start)}).getOrElse(.start)
    }

    if
      let prevDate = calendar.date(byAdding: .day, value: -1, to: date),
      let nextDate = calendar.date(byAdding: .day, value: 1, to: date),
      selections.contains(prevDate),
      selections.contains(nextDate)
    {
      flags = .mid
    }
    
    return flags.getOrElse(.none)
  }
}
