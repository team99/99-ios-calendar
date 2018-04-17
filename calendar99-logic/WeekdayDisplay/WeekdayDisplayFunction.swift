//
//  WeekdayDisplayFunction.swift
//  calendar99-logic
//
//  Created by Hai Pham on 17/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Shared functionalities between the model and view model.
public protocol NNWeekdayDisplayFunction {

  /// Get the number of weekdays we would like to display.
  var weekdayCount: Int { get }
}
