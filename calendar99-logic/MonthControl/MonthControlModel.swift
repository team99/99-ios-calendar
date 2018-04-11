//
//  MonthControlModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for month control model.
public protocol NNMonthControlModelDependency: NNMonthControlFunctionality {

  /// Stream the current selected components.
  var componentStream: Observable<NNCalendar.Components> { get }

  /// Emit the initial components.
  var initialComponentStream: Single<NNCalendar.Components> { get }

  /// Receive the current components.
  var componentReceiver: AnyObserver<NNCalendar.Components> { get }
}

/// Model for month header view.
public protocol NNMonthControlModelType: NNMonthControlModelDependency {

  /// Calculate a new components based on a month offset.
  ///
  /// - Parameters:
  ///   - prevComps: The previous components.
  ///   - monthOffset: A month offset value.
  /// - Returns: A tuple of month and year.
  func newComponents(_ prevComps: NNCalendar.Components, _ monthOffset: Int)
    -> NNCalendar.Components?
}

internal extension NNCalendar.MonthControl {

  /// Model implementation.
  internal final class Model: NNMonthControlModelType {
    fileprivate let dependency: NNMonthHeaderModelDependency

    public var componentStream: Observable<NNCalendar.Components> {
      return dependency.componentStream
    }

    public var initialComponentStream: Single<NNCalendar.Components> {
      return dependency.initialComponentStream
    }

    public var componentReceiver: AnyObserver<NNCalendar.Components> {
      return dependency.componentReceiver
    }

    public init(_ dependency: NNMonthHeaderModelDependency) {
      self.dependency = dependency
    }

    public func newComponents(_ prevComponents: NNCalendar.Components,
                              _ monthOffset: Int) -> NNCalendar.Components? {
      let prevMonth = prevComponents.month
      let prevYear = prevComponents.year

      return NNCalendar.DateUtil
        .newMonthAndYear(prevMonth, prevYear, monthOffset)
        .map({NNCalendar.Components(month: $0.month, year: $0.year)})
    }
  }
}
