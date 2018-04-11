//
//  MonthDisplayFunctionality.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Shared functionalities between the month display's model and view models
/// that can have defaults.
public protocol NNMonthDisplayDefaultableFunctionality {

  /// Get the first day of a week (e.g. Monday).
  var firstDayOfWeek: Int { get }

  /// Represents the number of columns. Should be 7 in most cases.
  var columnCount: Int { get }

  /// Represents the number of rows. Generally should be 6.
  var rowCount: Int { get }
}

/// Shared functionalities between the month display's model and view model.
public protocol NNMonthDisplayFunctionality:
  NNMonthDisplayDefaultableFunctionality,
  NNMonthControlFunctionality {}
