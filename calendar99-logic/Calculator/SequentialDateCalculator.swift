//
//  SequentialDateCalculator.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP

public extension NNCalendar.DateCalc {

  /// Sequential date calculator.
  public final class Sequential {
    public let rowCount: Int
    public let columnCount: Int
    public let firstWeekday: Int
    fileprivate let calendar: Calendar

    public init(_ rowCount: Int, _ columnCount: Int, _ firstWeekday: Int) {
      self.rowCount = rowCount
      self.columnCount = columnCount
      self.firstWeekday = firstWeekday
      calendar = Calendar.current
    }
  }
}

// MARK: - NNDateCalculatorType
extension NNCalendar.DateCalc.Sequential: NNDateCalculatorType {

  /// We need to find the first day of the week in which the current month
  /// starts (not necessarily the first day of the month).
  public func dateRange(_ month: NNCalendar.Month) -> [Date] {
    return NNCalendar.Util.firstDateWithWeekday(month, firstWeekday)
      .map({(date: Date) -> [Date] in (0..<rowCount * columnCount).flatMap({
        return calendar.date(byAdding: .day, value: $0, to: date)
      })})
      .getOrElse([])
  }
}

// MARK: - NNSingleDateCalculatorType
extension NNCalendar.DateCalc.Sequential: NNSingleDateCalculatorType {
  public func dateWithOffset(_ month: NNCalendar.Month,
                             _ firstDateOffset: Int) -> Date? {
    return NNCalendar.Util.firstDateWithWeekday(month, firstWeekday).flatMap({
      return calendar.date(byAdding: .day, value: firstDateOffset, to: $0)
    })
  }
}

// MARK: - NNMultiMonthGridSelectionCalculator
extension NNCalendar.DateCalc.Sequential: NNMultiMonthGridSelectionCalculator {
  public func gridSelectionChanges(_ monthComps: [NNCalendar.MonthComp],
                                   _ currentMonth: NNCalendar.Month,
                                   _ prev: Set<NNCalendar.Selection>,
                                   _ current: Set<NNCalendar.Selection>)
    -> Set<NNCalendar.GridPosition>
  {
    return monthComps.index(where: {$0.month == currentMonth})
      .map({monthIndex in Set(extractChanges(prev, current)
        .flatMap({$0.gridPosition(monthComps, monthIndex)}))})
      .getOrElse([])
  }
}

// MARK: - NNSingleMonthGridSelectionCalculatorType
extension NNCalendar.DateCalc.Sequential: NNSingleMonthGridSelectionCalculator {
  public func gridSelectionChanges(_ monthComp: NNCalendar.MonthComp,
                                   _ prev: Set<NNCalendar.Selection>,
                                   _ current: Set<NNCalendar.Selection>)
    -> Set<NNCalendar.GridPosition>
  {
    return Set(extractChanges(prev, current)
      .flatMap({self.gridPosition(monthComp, $0)}))
  }

  /// We need to include the previous and next month components here as well,
  /// and call the pre-specified method that deals with Month Array. We also
  /// assume that the day count remains the same for all Months.
  fileprivate func gridPosition(_ monthComp: NNCalendar.MonthComp,
                                _ selection: NNCalendar.Selection)
    -> Set<NNCalendar.GridPosition>
  {
    var monthComps = [NNCalendar.MonthComp]()

    monthComp.month.with(monthOffset: -1)
      .map({monthComp.with(month: $0)})
      .map({monthComps.append($0)})

    monthComps.append(monthComp)

    monthComp.month.with(monthOffset: 1)
      .map({monthComp.with(month: $0)})
      .map({monthComps.append($0)})

    return selection.gridPosition(monthComps, 1)
  }
}
