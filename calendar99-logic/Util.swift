//
//  Util.swift
//  calendar99-logic
//
//  Created by Hai Pham on 18/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

// MARK: - Utilities
public extension NNCalendar {

  /// Utilities for calendar views.
  public final class Util {}
}

// MARK: - Connect selection
public extension NNCalendar.Util {

  /// Calculate the first date in a Month that falls on a certain weekday.
  ///
  /// - Parameters:
  ///   - month: A Month instance.
  ///   - weekday: An Int value representing a weekday.
  /// - Returns: A Date instance.
  public static func firstDateWithWeekday(_ month: NNCalendar.Month,
                                          _ weekday: Int) -> Date? {
    let calendar = Calendar.current
    let dateComponents = month.dateComponents()

    return calendar.date(from: dateComponents)
      .flatMap({(date: Date) -> Date? in
        let weekdayComp = calendar.component(.weekday, from: date)
        let offset: Int

        if weekdayComp < weekday {
          offset = 7 - (weekday - weekdayComp)
        } else {
          offset = weekdayComp - weekday
        }

        return calendar.date(byAdding: .day, value: -offset, to: date)
      })
  }

  /// Produce a weekday range from a first weekday and a weekday count.
  ///
  /// - Parameters:
  ///   - firstWeekday: The first weekday in a week.
  ///   - weekdayCount: The number of weekdays.
  /// - Returns: An Array of weekdays.
  public static func weekdayRange(_ firstWeekday: Int, _ weekdayCount: Int) -> [Int] {
    return (firstWeekday..<(firstWeekday + weekdayCount))
      .map({$0 % 7}).map({$0 == 0 ? 7 : $0})
  }

  /// Get the weekday that corresponds to an index in a weekday range.
  ///
  /// - Parameter
  ///   - index: The weekday index.
  ///   - firstWeekday: The first weekday in a week.
  /// - Returns: The weekday value.
  public static func weekdayWithIndex(_ index: Int, _ firstWeekday: Int) -> Int {
    let weekday = (index + firstWeekday) % 7
    return weekday == 0 ? 7 : weekday
  }

  /// Provided that this date is selected, check the previous and next dates:
  /// - If the next date is not selected, add a .end part.
  /// - If the previous date is not selected, add a .start part.
  /// - If both the next and previous dates are selected, add a .mid part.
  /// - Otherwise, default to .none.
  ///
  /// - Parameters:
  ///   - selections: The current selections.
  ///   - date: A Date instance.
  /// - Returns: A HighlightPart instance.
  public static func highlightPart(_ selections: Set<NNCalendar.Selection>,
                                   _ date: Date)
    -> NNCalendar.HighlightPart
  {
    guard selections.contains(where: {$0.contains(date)}) else {
      return .none
    }
    
    let calendar = Calendar.current
    var flags: NNCalendar.HighlightPart?

    if
      let nextDate = calendar.date(byAdding: .day, value: 1, to: date),
      !selections.contains(where: {$0.contains(nextDate)})
    {
      flags = flags.map({$0.union(.end)}).getOrElse(.end)
    }

    if
      let prevDate = calendar.date(byAdding: .day, value: -1, to: date),
      !selections.contains(where: {$0.contains(prevDate)})
    {
      flags = flags.map({$0.union(.start)}).getOrElse(.start)
    }

    if
      let prevDate = calendar.date(byAdding: .day, value: -1, to: date),
      let nextDate = calendar.date(byAdding: .day, value: 1, to: date),
      selections.contains(where: {$0.contains(nextDate)}),
      selections.contains(where: {$0.contains(prevDate)})
    {
      flags = .mid
    }

    return flags.getOrElse(.none)
  }

  /// Connect discrete date selections into one continuous string of Dates, by
  /// including dates in between as well. For e.g. we have selections as follows:
  ///
  /// 1/4/2018 - 4/4/2018
  ///
  /// This function will add 2/4/2018 and 3/4/2018 to the selection set. Beware
  /// that the earliest date in the selection will be the anchor, so further
  /// selections, unless even earlier than the previously earliest Date, will
  /// only extend the string.
  ///
  /// - Parameter selection: A Sequence of Date selection.
  /// - Returns: A Set of Date selection.
  public static func connectSelection<S>(_ selection: S) -> Set<Date> where
    S: Sequence, S.Iterator.Element == Date
  {
    guard let min = selection.min(), let max = selection.max() else { return [] }
    let calendar = Calendar.current
    var newSelections = Set<Date>()
    var date: Date? = min
    let compareDay: (Date) -> Bool = {$0 <= max}

    repeat {
      _ = date.map({newSelections.insert($0)})
      date = date.flatMap({calendar.date(byAdding: .day, value: 1, to: $0)})
    } while date.map(compareDay).getOrElse(false)

    return newSelections
  }
}
