//
//  MonthDisplayModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Shared functionalities between the model and its dependency that can have
/// defaults
public protocol NNMonthDisplayDefaultModelFunction:
  NNMonthControlDefaultModelFunction,
  NNMultiDaySelectionDefaultFunction,
  NNSingleDaySelectionDefaultFunction {}

/// Shared functionalities between the model and its dependency that cannot
/// have defaults.
public protocol NNMonthDisplayNoDefaultModelFunction:
  NNMonthControlNoDefaultModelFunction,
  NNMultiDaySelectionNoDefaultFunction,
  NNSingleDaySelectionNoDefaultFunction {}

/// Defaultable dependency for month display model.
public protocol NNMonthDisplayDefaultModelDependency:
  NNDateCalculatorType,
  NNMonthDisplayDefaultModelFunction,
  NNSingleDaySelectionDefaultModelDependency,
  NNSingleMonthGridSelectionCalculator {}

/// Non-defaultable dependency for month display model.
public protocol NNMonthDisplayNoDefaultModelDependency:
  NNMonthDisplayDefaultModelFunction,
  NNMonthDisplayNoDefaultModelFunction,
  NNSingleDaySelectionNoDefaultModelDependency {}

/// Dependency for month display model, comprising default & non-default
/// components.
public protocol NNMonthDisplayModelDependency:
  NNMonthControlModelDependency,
  NNMonthDisplayDefaultModelDependency,
  NNMonthDisplayNoDefaultModelDependency,
  NNMonthGridModelDependency,
  NNSingleDaySelectionModelDependency {}

/// Model for month display view.
public protocol NNMonthDisplayModelType:
  NNMonthControlModelType,
  NNMonthDisplayDefaultModelFunction,
  NNMonthDisplayNoDefaultModelFunction,
  NNMonthGridModelType,
  NNSingleDaySelectionModelType,
  NNSingleMonthGridSelectionCalculator
{
  /// Calculate the Day range for a Month.
  ///
  /// - Parameters month: A Month instance.
  /// - Returns: An Array of Day.
  func dayRange(_ month: NNCalendar.Month) -> [NNCalendar.Day]
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

// MARK: - NNGridDisplayDefaultFunction
extension NNCalendar.MonthDisplay.Model: NNGridDisplayDefaultFunction {
  public var columnCount: Int {
    return monthGridModel.columnCount
  }

  public var rowCount: Int {
    return monthGridModel.rowCount
  }
}

// MARK: - NNMonthControlModelType
extension NNCalendar.MonthDisplay.Model: NNMonthControlModelType {
  public var initialMonthStream: Single<NNCalendar.Month> {
    return monthControlModel.initialMonthStream
  }
}

// MARK: - NNMonthControlModelDependency
extension NNCalendar.MonthDisplay.Model: NNMonthControlModelDependency {
  public var currentMonthStream: Observable<NNCalendar.Month> {
    return dependency.currentMonthStream
  }

  public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    return dependency.currentMonthReceiver
  }
}

// MARK: - NNSingleDaySelectionNoDefaultFunction
extension NNCalendar.MonthDisplay.Model: NNSingleDaySelectionNoDefaultFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return daySelectionModel.isDateSelected(date)
  }
}

// MARK: - NNSingleDaySelectionModelType
extension NNCalendar.MonthDisplay.Model: NNSingleDaySelectionModelType {
  public var allSelectionReceiver: AnyObserver<Set<NNCalendar.Selection>> {
    return daySelectionModel.allSelectionReceiver
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendar.Selection>>> {
    return daySelectionModel.allSelectionStream
  }
}

// MARK: - NNWeekdayAwareDefaultModelFunction
extension NNCalendar.MonthDisplay.Model: NNWeekdayAwareDefaultModelFunction {
  public var firstWeekday: Int {
    return daySelectionModel.firstWeekday
  }
}

// MARK: - NNMonthDisplayModelType
extension NNCalendar.MonthDisplay.Model: NNMonthDisplayModelType {
  public func dayRange(_ month: NNCalendar.Month) -> [NNCalendar.Day] {
    let calendar = Calendar.current

    return dependency.dateRange(month).map({
      let description = calendar.component(.day, from: $0).description

      return NNCalendar.Day($0)
        .with(dateDescription: description)
        .with(currentMonth: month.contains($0))
    })
  }

  public func gridSelectionChanges(_ monthComp: NNCalendar.MonthComp,
                                   _ prev: Set<NNCalendar.Selection>,
                                   _ current: Set<NNCalendar.Selection>)
    -> Set<NNCalendar.GridPosition>
  {
    return dependency.gridSelectionChanges(monthComp, prev, current)
  }
}

// MARK: - Default dependency.
extension NNCalendar.MonthDisplay.Model {

  /// Default dependency for month display model. This delegates non-default
  /// components to a separate dependency.
  final class DefaultDependency: NNMonthDisplayModelDependency {
    var columnCount: Int { return monthGridDp.columnCount }
    var rowCount: Int { return monthGridDp.rowCount }
    var firstWeekday: Int { return daySelectionDp.firstWeekday }

    var initialMonthStream: Single<NNCalendar.Month> {
      return noDefault.initialMonthStream
    }

    var allSelectionStream: Observable<Try<Set<NNCalendar.Selection>>> {
      return noDefault.allSelectionStream
    }

    var allSelectionReceiver: AnyObserver<Set<NNCalendar.Selection>> {
      return noDefault.allSelectionReceiver
    }

    var currentMonthStream: Observable<NNCalendar.Month> {
      return noDefault.currentMonthStream
    }

    var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
      return noDefault.currentMonthReceiver
    }

    private let noDefault: NNMonthDisplayNoDefaultModelDependency
    private let monthGridDp: NNMonthGridModelDependency
    private let daySelectionDp: NNSingleDaySelectionModelDependency
    private let dateCalc: NNCalendar.DateCalc.Sequential

    init(_ dependency: NNMonthDisplayNoDefaultModelDependency) {
      noDefault = dependency
      monthGridDp = NNCalendar.MonthGrid.Model.DefaultDependency()
      daySelectionDp = NNCalendar.DaySelection.Model.DefaultDependency(dependency)

      dateCalc = NNCalendar.DateCalc.Sequential(
        monthGridDp.rowCount,
        monthGridDp.columnCount,
        daySelectionDp.firstWeekday)
    }

    func isDateSelected(_ date: Date) -> Bool {
      return noDefault.isDateSelected(date)
    }

    /// We use a sequential date calculator here, since it seems to be the most
    /// common.
    func dateRange(_ month: NNCalendar.Month) -> [Date] {
      return dateCalc.dateRange(month)
    }

    func gridSelectionChanges(_ monthComp: NNCalendar.MonthComp,
                              _ prev: Set<NNCalendar.Selection>,
                              _ current: Set<NNCalendar.Selection>)
      -> Set<NNCalendar.GridPosition>
    {
      return dateCalc.gridSelectionChanges(monthComp, prev, current)
    }
  }
}
