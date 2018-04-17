//
//  GridDisplayFunction.swift
//  calendar99-logic
//
//  Created by Hai Pham on 17/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Shared functionalities between the model and view model for grid display
/// views that can have defaults.
public protocol NNGridDisplayDefaultFunction {

  /// Represents the number of columns. Should be 7 in most cases.
  var columnCount: Int { get }

  /// Represents the number of rows. Generally should be 6.
  var rowCount: Int { get }
}

/// Shared functionalities between the model and view model for grid display
/// views that cannot have defaults.
public protocol NNGridDisplayNoDefaultFunction {}
