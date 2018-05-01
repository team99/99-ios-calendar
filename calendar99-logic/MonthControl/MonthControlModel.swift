//
//  MonthControlModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and its dependency.
public protocol NNMonthControlModelFunction:
  NNMonthAwareModelFunction,
  NNMonthControlFunction
{
  /// Get the minimum month that we cannot go past.
  var minimumMonth: NNCalendarLogic.Month { get }
  
  /// Get the maximum month that we cannot go past.
  var maximumMonth: NNCalendarLogic.Month { get }
  
  /// Stream the initial month.
  var initialMonthStream: Single<NNCalendarLogic.Month> { get }
}

/// Dependency for month control model.
public protocol NNMonthControlModelDependency: NNMonthControlModelFunction {}

/// Model for month header view.
public protocol NNMonthControlModelType: NNMonthControlModelFunction {}

public extension NNCalendarLogic.MonthControl {

  /// Model implementation.
  public final class Model {
    fileprivate let dependency: NNMonthControlModelDependency

    public init(_ dependency: NNMonthControlModelDependency) {
      self.dependency = dependency
    }
  }
}

// MARK: - NNMonthAwareModelFunction
extension NNCalendarLogic.MonthControl.Model: NNMonthAwareModelFunction {
  public var currentMonthStream: Observable<NNCalendarLogic.Month> {
    return dependency.currentMonthStream
  }
}

// MARK: - NNMonthControlFunction
extension NNCalendarLogic.MonthControl.Model: NNMonthControlFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
    return dependency.currentMonthReceiver
  }
}

/// NNMonthControlModelFunction
extension NNCalendarLogic.MonthControl.Model: NNMonthControlModelFunction {
  public var initialMonthStream: Single<NNCalendarLogic.Month> {
    return dependency.initialMonthStream
  }

  public var minimumMonth: NNCalendarLogic.Month {
    return dependency.minimumMonth
  }

  public var maximumMonth: NNCalendarLogic.Month {
    return dependency.maximumMonth
  }
}

// MARK: - NNMonthControlModelType
extension NNCalendarLogic.MonthControl.Model: NNMonthControlModelType {}
