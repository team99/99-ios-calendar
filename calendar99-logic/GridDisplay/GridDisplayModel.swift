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
public extension NNCalendarLogic.GridDisplay {
  public final class Model {}
}

// MARK: - Default dependency.
public extension NNCalendarLogic.GridDisplay.Model {
  public final class DefaultDependency: NNMGridDisplayModelDependency {
    
    /// Seems like most calendar apps have 6 rows, so in total 42 date cells.
    public var weekdayStacks: Int {
      return 6
    }
  }
}
