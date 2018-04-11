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
  var currentComponentStream: Observable<NNCalendar.MonthComp> { get }

  /// Receive the current components.
  var currentComponentReceiver: AnyObserver<NNCalendar.MonthComp> { get }
}

/// Model for month header view.
public protocol NNMonthControlModelType: NNMonthControlModelDependency {

  /// Calculate a new components based on a month offset.
  ///
  /// - Parameters:
  ///   - prevComps: The previous components.
  ///   - monthOffset: A month offset value.
  /// - Returns: A tuple of month and year.
  func newComponents(_ prevComps: NNCalendar.MonthComp,
                     _ monthOffset: Int) -> NNCalendar.MonthComp?
}

internal extension NNCalendar.MonthControl {

  /// Model implementation.
  internal final class Model {
    fileprivate let dependency: NNMonthControlModelDependency

    public init(_ dependency: NNMonthControlModelDependency) {
      self.dependency = dependency
    }
  }
}

// MARK: - NNMonthControlModelDependency
extension NNCalendar.MonthControl.Model: NNMonthControlModelDependency {
  public var currentComponentStream: Observable<NNCalendar.MonthComp> {
    return dependency.currentComponentStream
  }

  public var currentComponentReceiver: AnyObserver<NNCalendar.MonthComp> {
    return dependency.currentComponentReceiver
  }
}

// MARK: - NNMonthControlModelType
extension NNCalendar.MonthControl.Model: NNMonthControlModelType {
  public func newComponents(_ prevComponents: NNCalendar.MonthComp,
                            _ monthOffset: Int) -> NNCalendar.MonthComp? {
    let prevMonth = prevComponents.month
    let prevYear = prevComponents.year

    return NNCalendar.DateUtil
      .newMonthAndYear(prevMonth, prevYear, monthOffset)
      .map({NNCalendar.MonthComp(month: $0.month, year: $0.year)})
  }
}
