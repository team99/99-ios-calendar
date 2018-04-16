//
//  GridDisplayViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Shared functionalities for the view model and its dependency for grid
/// display views.
public protocol NNGridDisplayViewModelFunction {

  /// Represents the number of columns. Should be 7 in most cases.
  var columnCount: Int { get }

  /// Represents the number of rows. Generally should be 6.
  var rowCount: Int { get }
}

/// Dependency for grid display view model.
public protocol NNMGridDisplayViewModelDependency: NNGridDisplayViewModelFunction {}

/// View model for grid display views.
public protocol NNGridDisplayViewModelType: NNMGridDisplayViewModelDependency {}

// MARK: - ViewModel.
public extension NNCalendar.GridDisplay {
  public final class ViewModel {}
}

// MARK: - Default dependency.
public extension NNCalendar.GridDisplay.ViewModel {
  internal final class DefaultDependency: NNMGridDisplayViewModelDependency {

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
