//
//  MonthControlModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for month control model.
public protocol NNMonthControlModelDependency {

  /// Stream the current selected components.
  var currentComponentStream: Observable<NNCalendar.MonthComponents> { get }

  /// Emit the initial components.
  var initialComponentStream: Single<NNCalendar.MonthComponents> { get }

  /// Receive the current components.
  var currentComponentReceiver: AnyObserver<NNCalendar.MonthComponents> { get }
}

/// Model for month header view.
public protocol NNMonthControlModelType: NNMonthControlModelDependency {

  /// Calculate a new components based on a month offset.
  ///
  /// - Parameters:
  ///   - prevComps: The previous components.
  ///   - monthOffset: A month offset value.
  /// - Returns: A tuple of month and year.
  func newComponents(_ prevComps: NNCalendar.MonthComponents,
                     _ monthOffset: Int) -> NNCalendar.MonthComponents?
}

internal extension NNCalendar.MonthControl {

  /// Model implementation.
  internal final class Model: NNMonthControlModelType {
    fileprivate let dependency: NNMonthHeaderModelDependency

    public var currentComponentStream: Observable<NNCalendar.MonthComponents> {
      return dependency.currentComponentStream
    }

    public var initialComponentStream: Single<NNCalendar.MonthComponents> {
      return dependency.initialComponentStream
    }

    public var currentComponentReceiver: AnyObserver<NNCalendar.MonthComponents> {
      return dependency.currentComponentReceiver
    }

    public init(_ dependency: NNMonthHeaderModelDependency) {
      self.dependency = dependency
    }

    public func newComponents(_ prevComponents: NNCalendar.MonthComponents,
                              _ monthOffset: Int) -> NNCalendar.MonthComponents? {
      let prevMonth = prevComponents.month
      let prevYear = prevComponents.year

      return NNCalendar.DateUtil
        .newMonthAndYear(prevMonth, prevYear, monthOffset)
        .map({NNCalendar.MonthComponents(month: $0.month, year: $0.year)})
    }
  }
}
