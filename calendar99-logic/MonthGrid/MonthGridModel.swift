//
//  MonthGridModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and its dependency.
public protocol NNMonthGridModelFunction: NNGridDisplayFunction {}

/// Dependency for month grid model.
public protocol NNMonthGridModelDependency: NNMonthGridModelFunction {}

/// Model for month grid views.
public protocol NNMonthGridModelType: NNMonthGridModelFunction {}

// MARK: - Model.
public extension NNCalendarLogic.MonthGrid {

  /// Model implementation.
  public final class Model {
    fileprivate let dependency: NNMonthGridModelDependency

    required public init(_ dependency: NNMonthGridModelDependency) {
      self.dependency = dependency
    }
  }
}

// MARK: - NNGridDisplayFunction
extension NNCalendarLogic.MonthGrid.Model: NNGridDisplayFunction {
  public var weekdayStacks: Int { return dependency.weekdayStacks }
}

// MARK: - NNMonthGridModelType
extension NNCalendarLogic.MonthGrid.Model: NNMonthGridModelType {}
