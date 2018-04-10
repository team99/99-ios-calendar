//
//  Functionality.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the month header's model and view model.
public protocol C99MonthHeaderFunctionality {}

/// Shared functionalities between the month display's model and view model.
public protocol C99MonthDisplayFunctionality {
  
  /// Represents the number of columns. Should be 7 in most cases.
  var columnCount: Int { get }

  /// Represents the number of rows. Generally should be 6.
  var rowCount: Int { get }
}
