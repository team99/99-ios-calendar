//
//  MonthDisplayModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for month display model, containing components that can have
/// defaults.
public protocol NNMonthDisplayDefaultableModelDependency:
  NNMonthDisplayDefaultableFunctionality
{
  /// Calculator to calculate date ranges.
  var dateCalculator: NNDateCalculatorType { get }
}

/// Dependency for month display model, containing components that cannot have
/// defaults.
public protocol NNMonthDisplayNonDefaultableModelDependency {

  /// Stream components.
  var componentStream: Observable<NNCalendar.MonthComponents> { get }
}

/// Dependency for month display model.
public protocol NNMonthDisplayModelDependency:
  NNMonthDisplayFunctionality,
  NNMonthDisplayDefaultableModelDependency,
  NNMonthDisplayNonDefaultableModelDependency {}

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
  func calculateDateRange(_ components: NNCalendar.MonthComponents) -> [Date]

  /// Get the description for a date.
  ///
  /// - Parameter date: A Date instance.
  func dateDescription(_ date: Date) -> String

  /// Check if a date is in a specified month.
  ///
  /// - Parameter components: A Components instance.
  /// - Returns: A Date instance.
  func isInMonth(_ components: NNCalendar.MonthComponents, _ date: Date) -> Bool
}

public extension NNCalendar.MonthDisplay {

  /// Month display model implementation.
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

    public var componentStream: Observable<NNCalendar.MonthComponents> {
      return dependency.componentStream
    }

    public var dateCalculator: NNDateCalculatorType {
      return dependency.dateCalculator
    }

    fileprivate let dependency: NNMonthDisplayModelDependency

    required public init(_ dependency: NNMonthDisplayModelDependency) {
      self.dependency = dependency
    }

    convenience public init(_ dependency: NNMonthDisplayNonDefaultableModelDependency) {
      let fullDependency = DefaultDependency(dependency)
      self.init(fullDependency)
    }

    public func calculateDateRange(_ components: NNCalendar.MonthComponents) -> [Date] {
      return dateCalculator.calculateRange(components,
                                           firstDayOfWeek,
                                           rowCount,
                                           columnCount)
    }

    public func dateDescription(_ date: Date) -> String {
      return Calendar.current.component(.day, from: date).description
    }

    public func isInMonth(_ components: NNCalendar.MonthComponents, _ date: Date) -> Bool {
      let calendar = Calendar.current
      let month = calendar.component(.month, from: date)
      let year = calendar.component(.year, from: date)
      return components.month == month && components.year == year
    }
  }
}

public extension NNCalendar.MonthDisplay.Model {

  /// Default dependency for month display model. This delegates non-defaultable
  /// components to a separate dependency.
  ///
  /// The defaults here represent most commonly used set-up, for e.g. horizontal
  /// calendar with 42 date cells in total.
  internal struct DefaultDependency: NNMonthDisplayModelDependency {
    private let nonDefaultable: NNMonthDisplayNonDefaultableModelDependency

    public init(_ nonDefaultable: NNMonthDisplayNonDefaultableModelDependency) {
      self.nonDefaultable = nonDefaultable
    }

    /// Corresponds to a Sunday.
    public var firstDayOfWeek: Int {
      return 1
    }

    public var columnCount: Int {
      return 7
    }

    public var rowCount: Int {
      return 6
    }

    public var dateCalculator: NNDateCalculatorType {
      return NNCalendar.DateCalculator.Sequential()
    }

    public var componentStream: Observable<NNCalendar.MonthComponents> {
      return nonDefaultable.componentStream
    }
  }
}
