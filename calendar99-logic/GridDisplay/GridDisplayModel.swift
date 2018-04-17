//
//  GridDisplayModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Dependency for grid display model.
public protocol NNMGridDisplayModelDependency: NNGridDisplayFunction {}

/// View model for grid display views.
public protocol NNGridDisplayModelType: NNGridDisplayFunction {}

// MARK: - Model.
public extension NNCalendar.GridDisplay {
  public final class Model {}
}

// MARK: - Default dependency.
public extension NNCalendar.GridDisplay.Model {
  internal final class DefaultDependency: NNMGridDisplayModelDependency {

    /// Corresponds to 7 days in a week.
    internal var columnCount: Int {
      return 7
    }

    /// Seems like most calendar apps have 6 rows, so in total 42 date cells.
    internal var rowCount: Int {
      return 6
    }
  }
}
