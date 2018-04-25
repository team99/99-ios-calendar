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
public extension NNCalendarLogic.MonthGrid {

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
extension NNCalendarLogic.MonthGrid.Model: NNGridDisplayDefaultFunction {
  public var weekdayStacks: Int {
    return dependency.weekdayStacks
  }
}

// MARK: - NNMonthGridModelType
extension NNCalendarLogic.MonthGrid.Model: NNMonthGridModelType {}

// MARK: - Default dependency.
public extension NNCalendarLogic.MonthGrid.Model {
  public final class DefaultDependency: NNMonthGridModelDependency {
    public var weekdayStacks: Int { return gridDisplayDp.weekdayStacks }
    private let gridDisplayDp: NNMGridDisplayModelDependency

    public init() {
      gridDisplayDp = NNCalendarLogic.GridDisplay.Model.DefaultDependency()
    }
  }
}
