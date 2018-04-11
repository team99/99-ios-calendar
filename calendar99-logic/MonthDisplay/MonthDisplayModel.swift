//
//  MonthDisplayModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for month display model.
public protocol NNMonthDisplayModelDependency: NNMonthDisplayFunctionality {
  /// Stream components.
  var componentStream: Observable<NNCalendar.Components> { get }

  /// Calculator to calculate date ranges.
  var dateCalculator: NNDateCalculatorType { get }
}

/// Factory for month display model dependency.
public protocol NNMonthDisplayModelDependencyFactory {

  /// Create a month display model dependency.
  ///
  /// - Returns: A MonthDisplayModelDependency instance.
  func monthDisplayModelDependency() -> NNMonthDisplayModelDependency
}

/// Model for month display view.
public protocol NNMonthDisplayModelType: NNMonthDisplayModelDependency {

  /// Calculate a range of Date that is applicable to the current calendar
  /// components. The first element of the range is not necessarily the start
  /// of the month, but the first day of the week within which the month begins.
  ///
  /// - Parameter components: A Components instance.
  /// - Returns: An Array of Date.
  func calculateDateRange(_ components: NNCalendar.Components) -> [Date]

  /// Get the description for a date.
  ///
  /// - Parameter date: A Date instance.
  func dateDescription(_ date: Date) -> String

  /// Check if a date is in a specified month.
  ///
  /// - Parameter components: A Components instance.
  /// - Returns: A Date instance.
  func isInMonth(_ components: NNCalendar.Components, _ date: Date) -> Bool
}

public extension NNCalendar.MonthDisplay {
  public final class Model: NNMonthDisplayModelType {
    public var columnCount: Int {
      return dependency.columnCount
    }

    /// Avoid 0 and values larger than 7.
    public var firstDayOfWeek: Int {
      return Swift.max(dependency.firstDayOfWeek % 7, 1)
    }

    public var rowCount: Int {
      return dependency.rowCount
    }

    public var componentStream: Observable<NNCalendar.Components> {
      return dependency.componentStream
    }

    public var dateCalculator: NNDateCalculatorType {
      return dependency.dateCalculator
    }

    fileprivate let dependency: NNMonthDisplayModelDependency

    public init(_ dependency: NNMonthDisplayModelDependency) {
      self.dependency = dependency
    }

    public func calculateDateRange(_ components: NNCalendar.Components) -> [Date] {
      return dateCalculator.calculateRange(components,
                                           firstDayOfWeek,
                                           rowCount,
                                           columnCount)
    }

    public func dateDescription(_ date: Date) -> String {
      return Calendar.current.component(.day, from: date).description
    }

    public func isInMonth(_ components: NNCalendar.Components, _ date: Date) -> Bool {
      let calendar = Calendar.current
      let month = calendar.component(.month, from: date)
      let year = calendar.component(.year, from: date)
      return components.month == month && components.year == year
    }
  }
}
