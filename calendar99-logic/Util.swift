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
    let compareComponents: Set<Calendar.Component> = [.day, .month, .year]

    let compareDay: (Date) -> Bool = {
      calendar.dateComponents(compareComponents, from: $0)
        != calendar.dateComponents(compareComponents, from: max)
    }

    while date.map(compareDay).getOrElse(false) {
      _ = date.map({newSelections.insert($0)})
      date = date.flatMap({calendar.date(byAdding: .day, value: 1, to: $0)})
    }

    return newSelections
  }
}
