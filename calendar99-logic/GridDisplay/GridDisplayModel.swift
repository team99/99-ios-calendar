//
//  GridDisplayModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Defaultable dependency for grid display model.
public protocol NNGridDisplayDefaultModelDependency:
  NNGridDisplayDefaultFunction {}

/// Non-defaultable dependency for grid display model.
public protocol NNGridDisplayNoDefaultModelDependency:
  NNGridDisplayNoDefaultFunction {}

/// Dependency for grid display model.
public protocol NNMGridDisplayModelDependency:
  NNGridDisplayDefaultModelDependency,
  NNGridDisplayNoDefaultModelDependency {}

/// View model for grid display views.
public protocol NNGridDisplayModelType:
  NNGridDisplayDefaultFunction,
  NNGridDisplayNoDefaultFunction {}

// MARK: - Model.
public extension NNCalendar.GridDisplay {
  public final class Model {}
}

// MARK: - Default dependency.
extension NNCalendar.GridDisplay.Model {
  final class DefaultDependency: NNMGridDisplayModelDependency {

    /// Corresponds to 7 days in a week.
    var columnCount: Int {
      return 7
    }

    /// Seems like most calendar apps have 6 rows, so in total 42 date cells.
    var rowCount: Int {
      return 6
    }
  }
}
