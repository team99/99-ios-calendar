//
//  Functionality.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model/view model for month control views.
public protocol NNMonthControlFunctionality {}

/// Shared functionalities between the month header's model and view model.
public protocol NNMonthHeaderFunctionality: NNMonthControlFunctionality {}

/// Shared functionalities between the month display's model and view model.
public protocol NNMonthDisplayFunctionality: NNMonthControlFunctionality {
  
  /// Represents the number of columns. Should be 7 in most cases.
  var columnCount: Int { get }

  /// Represents the number of rows. Generally should be 6.
  var rowCount: Int { get }
}
