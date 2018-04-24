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
  NNMonthAwareDefaultModelFunction,
  NNMonthControlDefaultFunction {}

/// Shared functionalities between the model and its dependency that cannot
/// have defaults.
public protocol NNMonthControlNoDefaultModelFunction:
  NNMonthAwareNoDefaultModelFunction,
  NNMonthControlNoDefaultFunction
{
  /// Get the minimum month that we cannot go past.
  var minimumMonth: NNCalendar.Month { get }

  /// Get the maximum month that we cannot go past.
  var maximumMonth: NNCalendar.Month { get }

  /// Stream the initial month.
  var initialMonthStream: Single<NNCalendar.Month> { get }
}

/// Dependency for month control model.
public protocol NNMonthControlModelDependency:
  NNMonthControlDefaultModelFunction,
  NNMonthControlNoDefaultModelFunction {}

/// Model for month header view.
public protocol NNMonthControlModelType:
  NNMonthControlDefaultModelFunction,
  NNMonthControlNoDefaultModelFunction {}

public extension NNCalendar.MonthControl {

  /// Model implementation.
  public final class Model {
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

// MARK: - NNMonthControlNoDefaultFunction
extension NNCalendar.MonthControl.Model: NNMonthControlNoDefaultFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    return dependency.currentMonthReceiver
  }
}

/// NNMonthControlNoDefaultModelFunction
extension NNCalendar.MonthControl.Model: NNMonthControlNoDefaultModelFunction {
  public var initialMonthStream: Single<NNCalendar.Month> {
    return dependency.initialMonthStream
  }

  public var minimumMonth: NNCalendar.Month {
    return dependency.minimumMonth
  }

  public var maximumMonth: NNCalendar.Month {
    return dependency.maximumMonth
  }
}

// MARK: - NNMonthControlModelType
extension NNCalendar.MonthControl.Model: NNMonthControlModelType {}
