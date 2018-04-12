//
//  DaySelectionFunctionality.swift
//  calendar99-logic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the day selection model & view model.
public protocol NNDaySelectionFunctionality {

  /// Stream date selections.
  var allDateSelectionStream: Observable<Set<Date>> { get }

  /// Check if a date is selected. The application running the calendar view
  /// should have a cache of selected dates that it can query, for e.g. in a
  /// BehaviorSubject.
  ///
  /// - Parameter date: A Date instance.
  /// - Returns: A Bool value.
  func isDateSelected(_ date: Date) -> Bool
}
