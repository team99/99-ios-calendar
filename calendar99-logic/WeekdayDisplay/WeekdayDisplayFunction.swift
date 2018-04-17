//
//  WeekdayDisplayFunction.swift
//  calendar99-logic
//
//  Created by Hai Pham on 17/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Shared functionalities between the model and view model that can have
/// defaults.
public protocol NNWeekdayDisplayDefaultFunction {

  /// Get the number of weekdays we would like to display.
  var weekdayCount: Int { get }
}

/// Shared functionalities between the model and view model that cannot have
/// defaults.
public protocol NNWeekdayDisplayNoDefaultFunction {}
