//
//  MonthControlModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and its dependency that can have
/// defaults.
public protocol NNMonthControlDefaultModelFunction:
  NNMonthAwareDefaultModelFunction {}

/// Shared functionalities between the model and its dependency that cannot
/// have defaults.
public protocol NNMonthControlNoDefaultModelFunction:
  NNMonthAwareNoDefaultModelFunction
{
  /// Receive the current month and push it somewhere for external streaming.
  var currentMonthReceiver: AnyObserver<NNCalendar.Month> { get }
}

/// Dependency for month control model.
public protocol NNMonthControlModelDependency:
  NNMonthControlDefaultModelFunction,
  NNMonthControlNoDefaultModelFunction {}

/// Model for month header view.
public protocol NNMonthControlModelType:
  NNMonthControlDefaultModelFunction,
  NNMonthControlNoDefaultModelFunction {}

internal extension NNCalendar.MonthControl {

  /// Model implementation.
  internal final class Model {
    fileprivate let dependency: NNMonthControlModelDependency

    public init(_ dependency: NNMonthControlModelDependency) {
      self.dependency = dependency
    }
  }
}

// MARK: - NNMonthAwareNoDefaultModelFunction
extension NNCalendar.MonthControl.Model: NNMonthAwareNoDefaultModelFunction {
  public var currentMonthStream: Observable<NNCalendar.Month> {
    return dependency.currentMonthStream
  }
}

/// NNMonthControlNoDefaultModelFunction
extension NNCalendar.MonthControl.Model: NNMonthControlNoDefaultModelFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    return dependency.currentMonthReceiver
  }
}

// MARK: - NNMonthControlModelType
extension NNCalendar.MonthControl.Model: NNMonthControlModelType {}
