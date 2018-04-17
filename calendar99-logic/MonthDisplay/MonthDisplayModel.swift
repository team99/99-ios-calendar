//
//  MonthDisplayModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and its dependency, so that the
/// model can expose the same properties.
public protocol NNMonthDisplayModelFunction {

  /// Stream the initial month.
  var initialMonthStream: Single<NNCalendar.Month> { get }
}

/// Dependency for month display model that contains components for which there
/// can be defaults. For e.g., we can default to the Sequential date calculator
/// for date range calculations.
public protocol NNMonthDisplayDefaultModelDependency:
  NNDateCalculatorType,
  NNSingleMonthGridSelectionCalculator {}

/// Dependency for month display model with non-default components. These
/// must be provided by the injector.
public protocol NNMonthDisplayNoDefaultModelDependency:
  NNMonthDisplayModelFunction,
  NNMonthAwareModelFunction,
  NNMonthControlModelFunction,
  NNMultiDaySelectionModelFunction,
  NNSingleDaySelectionFunction {}

/// Dependency for month display model, comprising default & non-default
/// components.
public protocol NNMonthDisplayModelDependency:
  NNMonthDisplayDefaultModelDependency,
  NNMonthDisplayNoDefaultModelDependency,
  NNMonthControlModelDependency,
  NNMonthGridModelDependency,
  NNSingleDaySelectionModelDependency {}

/// Factory for month display model dependency.
public protocol NNMonthDisplayModelDependencyFactory {

  /// Create a month display model dependency.
  ///
  /// - Returns: A MonthDisplayModelDependency instance.
  func monthDisplayModelDependency() -> NNMonthDisplayModelDependency
}

/// Model for month display view.
public protocol NNMonthDisplayModelType:
  NNMonthDisplayModelFunction,
  NNMonthControlModelType,
  NNMonthGridModelType,
  NNSingleDaySelectionModelType,
  NNSingleMonthGridSelectionCalculator
{
  /// Calculate the Day range for a Month.
  ///
  /// - Parameters month: A Month instance.
  /// - Returns: An Array of Day.
  func calculateDayRange(_ month: NNCalendar.Month) -> [NNCalendar.Day]
}

public extension NNCalendar.MonthDisplay {

  /// Month display model implementation.
  public final class Model {
    fileprivate let monthControlModel: NNMonthControlModelType
    fileprivate let monthGridModel: NNMonthGridModelType
    fileprivate let daySelectionModel: NNSingleDaySelectionModelType
    fileprivate let dependency: NNMonthDisplayModelDependency

    required public init(_ monthControlModel: NNMonthControlModelType,
                         _ monthGridModel: NNMonthGridModelType,
                         _ daySelectionModel: NNSingleDaySelectionModelType,
                         _ dependency: NNMonthDisplayModelDependency) {
      self.monthControlModel = monthControlModel
      self.monthGridModel = monthGridModel
      self.daySelectionModel = daySelectionModel
      self.dependency = dependency
    }

    convenience public init(_ dependency: NNMonthDisplayModelDependency) {
      let monthControlModel = NNCalendar.MonthControl.Model(dependency)
      let monthGridModel = NNCalendar.MonthGrid.Model(dependency)
      let daySelectionModel = NNCalendar.DaySelection.Model(dependency)
      self.init(monthControlModel, monthGridModel, daySelectionModel, dependency)
    }

    convenience public init(_ dependency: NNMonthDisplayNoDefaultModelDependency) {
      let defaultDP = DefaultDependency(dependency)
      self.init(defaultDP)
    }
  }
}

// MARK: - NNGridDisplayFunction
extension NNCalendar.MonthDisplay.Model: NNGridDisplayFunction {
  public var columnCount: Int {
    return monthGridModel.columnCount
  }

  public var rowCount: Int {
    return monthGridModel.rowCount
  }
}

// MARK: - NNMonthControlModelType
extension NNCalendar.MonthDisplay.Model: NNMonthControlModelType {}

// MARK: - NNMonthControlModelDependency
extension NNCalendar.MonthDisplay.Model: NNMonthControlModelDependency {
  public var currentMonthStream: Observable<NNCalendar.Month> {
    return dependency.currentMonthStream
  }

  public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    return dependency.currentMonthReceiver
  }
}

// MARK: - NNDaySelectionFunction
extension NNCalendar.MonthDisplay.Model: NNSingleDaySelectionFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return daySelectionModel.isDateSelected(date)
  }
}

// MARK: - NNDaySelectionModelType
extension NNCalendar.MonthDisplay.Model: NNSingleDaySelectionModelType {
  public var allDateSelectionReceiver: AnyObserver<Set<Date>> {
    return daySelectionModel.allDateSelectionReceiver
  }

  public var allDateSelectionStream: Observable<Set<Date>> {
    return daySelectionModel.allDateSelectionStream
  }
}

// MARK: - NNMonthDisplayModelFunction
extension NNCalendar.MonthDisplay.Model: NNMonthDisplayModelFunction {
  public var initialMonthStream: Single<NNCalendar.Month> {
    return dependency.initialMonthStream
  }
}

// MARK: - NNMonthDisplayModelType
extension NNCalendar.MonthDisplay.Model: NNMonthDisplayModelType {
  public func calculateDayRange(_ month: NNCalendar.Month) -> [NNCalendar.Day] {
    let calendar = Calendar.current

    return dependency.calculateDateRange(month).map({
      let description = calendar.component(.day, from: $0).description

      return NNCalendar.Day($0)
        .with(dateDescription: description)
        .with(currentMonth: month.contains($0))
    })
  }

  public func calculateGridSelection(_ monthComp: NNCalendar.MonthComp,
                                     _ selection: Date)
    -> Set<NNCalendar.GridSelection>
  {
    return dependency.calculateGridSelection(monthComp, selection)
  }
}

// MARK: - Default dependency.
public extension NNCalendar.MonthDisplay.Model {

  /// Default dependency for month display model. This delegates non-default
  /// components to a separate dependency.
  internal final class DefaultDependency: NNMonthDisplayModelDependency {
    internal var columnCount: Int {
      return monthGridDp.columnCount
    }

    internal var rowCount: Int {
      return monthGridDp.rowCount
    }

    internal var initialMonthStream: Single<NNCalendar.Month> {
      return noDefault.initialMonthStream
    }

    internal var allDateSelectionStream: Observable<Set<Date>> {
      return noDefault.allDateSelectionStream
    }

    internal var allDateSelectionReceiver: AnyObserver<Set<Date>> {
      return noDefault.allDateSelectionReceiver
    }

    private let noDefault: NNMonthDisplayNoDefaultModelDependency
    private let monthGridDp: NNMonthGridModelDependency
    private let weekdayAwareDp: NNWeekdayAwareModelDependency
    private let dateCalc: NNCalendar.DateCalculator.Sequential

    internal init(_ dependency: NNMonthDisplayNoDefaultModelDependency) {
      noDefault = dependency
      monthGridDp = NNCalendar.MonthGrid.Model.DefaultDependency()
      weekdayAwareDp = NNCalendar.WeekdayAware.Model.DefaultDependency()

      dateCalc = NNCalendar.DateCalculator.Sequential(
        monthGridDp.rowCount,
        monthGridDp.columnCount,
        weekdayAwareDp.firstWeekday)
    }

    internal var currentMonthStream: Observable<NNCalendar.Month> {
      return noDefault.currentMonthStream
    }

    internal var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
      return noDefault.currentMonthReceiver
    }

    internal func isDateSelected(_ date: Date) -> Bool {
      return noDefault.isDateSelected(date)
    }

    /// We use a sequential date calculator here, since it seems to be the most
    /// common.
    internal func calculateDateRange(_ month: NNCalendar.Month) -> [Date] {
      return dateCalc.calculateDateRange(month)
    }

    internal func calculateGridSelection(_ monthComp: NNCalendar.MonthComp,
                                         _ selection: Date)
      -> Set<NNCalendar.GridSelection>
    {
      return dateCalc.calculateGridSelection(monthComp, selection)
    }
  }
}
