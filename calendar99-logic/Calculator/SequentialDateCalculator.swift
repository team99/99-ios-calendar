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
  public func calculateDateRange(_ month: NNCalendar.Month) -> [Date] {
    return NNCalendar.Util.calculateFirstDate(month, firstWeekday)
      .map({(date: Date) -> [Date] in (0..<rowCount * columnCount).flatMap({
        return calendar.date(byAdding: .day, value: $0, to: date)
      })})
      .getOrElse([])
  }
}

// MARK: - NNSingleDateCalculatorType
extension NNCalendar.DateCalc.Sequential: NNSingleDateCalculatorType {
  public func calculateDateWithOffset(_ month: NNCalendar.Month,
                                      _ firstDateOffset: Int) -> Date? {
    return NNCalendar.Util.calculateFirstDate(month, firstWeekday).flatMap({
      return calendar.date(byAdding: .day, value: firstDateOffset, to: $0)
    })
  }
}

// MARK: - NNMultiMonthGridSelectionCalculator
extension NNCalendar.DateCalc.Sequential: NNMultiMonthGridSelectionCalculator {
  public func calculateGridSelectionChanges(_ monthComps: [NNCalendar.MonthComp],
                                            _ prev: Set<NNCalendar.Selection>,
                                            _ current: Set<NNCalendar.Selection>)
    -> Set<NNCalendar.GridSelection>
  {
    return Set(extractChanges(prev, current)
      .flatMap({$0.calculateGridSelection(monthComps)}))
  }
}

// MARK: - NNSingleMonthGridSelectionCalculatorType
extension NNCalendar.DateCalc.Sequential: NNSingleMonthGridSelectionCalculator {
  public func calculateGridSelectionChanges(_ monthComp: NNCalendar.MonthComp,
                                            _ prev: Set<NNCalendar.Selection>,
                                            _ current: Set<NNCalendar.Selection>)
    -> Set<NNCalendar.GridSelection>
  {
    return Set(extractChanges(prev, current)
      .flatMap({self.calculateGridSelection(monthComp, $0)}))
  }

  /// We need to include the previous and next month components here as well,
  /// and call the pre-specified method that deals with Month Array. We also
  /// assume that the day count remains the same for all Months.
  fileprivate func calculateGridSelection(_ monthComp: NNCalendar.MonthComp,
                                          _ selection: NNCalendar.Selection)
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

    return selection.calculateGridSelection(monthComps)
  }
}
