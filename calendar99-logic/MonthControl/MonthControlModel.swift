//
//  MonthControlModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and its dependency.
public protocol NNMonthControlModelFunction {

  /// Receive the current components.
  var currentMonthReceiver: AnyObserver<NNCalendar.Month> { get }
}

/// Dependency for month control model.
public protocol NNMonthControlModelDependency:
  NNMonthAwareModelFunction,
  NNMonthControlModelFunction {}

/// Model for month header view.
public protocol NNMonthControlModelType:
  NNMonthAwareModelFunction,
  NNMonthControlModelFunction {}

internal extension NNCalendar.MonthControl {

  /// Model implementation.
  internal final class Model {
    fileprivate let dependency: NNMonthControlModelDependency

    public init(_ dependency: NNMonthControlModelDependency) {
      self.dependency = dependency
    }
  }
}

// MARK: - NNMonthAwareModelFunction
extension NNCalendar.MonthControl.Model: NNMonthAwareModelFunction {
  public var currentMonthStream: Observable<NNCalendar.Month> {
    return dependency.currentMonthStream
  }
}

/// NNMonthControlModelFunction
extension NNCalendar.MonthControl.Model: NNMonthControlModelFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    return dependency.currentMonthReceiver
  }
}

// MARK: - NNMonthControlModelType
extension NNCalendar.MonthControl.Model: NNMonthControlModelType {}
