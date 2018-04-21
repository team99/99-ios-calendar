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
  public var weekdayStacks: Int {
    return dependency.weekdayStacks
  }
}

// MARK: - NNMonthGridModelType
extension NNCalendar.MonthGrid.Model: NNMonthGridModelType {}

// MARK: - Default dependency.
extension NNCalendar.MonthGrid.Model {
  final class DefaultDependency: NNMonthGridModelDependency {
    var weekdayStacks: Int { return gridDisplayDp.weekdayStacks }
    private let gridDisplayDp: NNMGridDisplayModelDependency

    init() {
      gridDisplayDp = NNCalendar.GridDisplay.Model.DefaultDependency()
    }
  }
}
