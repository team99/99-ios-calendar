//
//  SingleDaySelectionFunction.swift
//  calendar99-logic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and view model that can have
/// defaults.
public protocol NNSingleDaySelectionDefaultFunction {}

/// Shared functionalities between the model and view model that cannot have
/// defaults.
public protocol NNSingleDaySelectionNoDefaultFunction {

  /// Check if a date is selected. The application running the calendar view
  /// should have a cache of selected dates that it can query, for e.g. in a
  /// BehaviorSubject.
  ///
  /// - Parameter date: A Date instance.
  /// - Returns: A Bool value.
  func isDateSelected(_ date: Date) -> Bool
}
