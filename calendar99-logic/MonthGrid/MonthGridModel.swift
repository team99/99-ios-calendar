//
//  MonthGridModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Defaultable dependency for month grid model.
public protocol NNMonthGridDefaultModelDependency:
  NNGridDisplayDefaultFunction {}

/// Non-defaultable dependency for month grid model.
public protocol NNMonthGridNoDefaultModelDependency:
  NNGridDisplayNoDefaultFunction {}

/// Dependency for month grid model.
public protocol NNMonthGridModelDependency:
  NNMonthGridDefaultModelDependency,
  NNMonthGridNoDefaultModelDependency {}

/// Model for month grid views.
public protocol NNMonthGridModelType:
  NNMonthGridDefaultModelDependency,
  NNMonthGridNoDefaultModelDependency {}

// MARK: - Model.
public extension NNCalendar.MonthGrid {

  /// Model implementation.
  public final class Model {
    fileprivate let dependency: NNMonthGridModelDependency

    required public init(_ dependency: NNMonthGridModelDependency) {
      self.dependency = dependency
    }

    convenience public init() {
      let defaultDp = DefaultDependency()
      self.init(defaultDp)
    }
  }
}

// MARK: - NNGridDisplayDefaultFunction
extension NNCalendar.MonthGrid.Model: NNGridDisplayDefaultFunction {
  public var columnCount: Int {
    return dependency.columnCount
  }

  public var rowCount: Int {
    return dependency.rowCount
  }
}

// MARK: - NNMonthGridModelType
extension NNCalendar.MonthGrid.Model: NNMonthGridModelType {}

// MARK: - Default dependency.
public extension NNCalendar.MonthGrid.Model {
  internal final class DefaultDependency: NNMonthGridModelDependency {
    internal var columnCount: Int { return gridDisplayDp.columnCount }
    internal var rowCount: Int { return gridDisplayDp.rowCount }
    private let gridDisplayDp: NNMGridDisplayModelDependency

    internal init() {
      gridDisplayDp = NNCalendar.GridDisplay.Model.DefaultDependency()
    }
  }
}
