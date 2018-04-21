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

  /// Represents the number of weekday lines in a grid. Generally should be 6.
  var weekdayStacks: Int { get }
}

/// Shared functionalities between the model and view model for grid display
/// views that cannot have defaults.
public protocol NNGridDisplayNoDefaultFunction {}
