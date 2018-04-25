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
  NNSelectHighlightDefaultFunction,
  NNSingleDaySelectionDefaultFunction {}

/// Shared functionalities between the model and its dependency that cannot
/// have defaults.
public protocol NNMonthDisplayNoDefaultModelFunction:
  NNMonthControlNoDefaultModelFunction,
  NNMultiDaySelectionNoDefaultFunction,
  NNSelectHighlightNoDefaultFunction,
  NNSingleDaySelectionNoDefaultFunction {}

/// Defaultable dependency for month display model.
public protocol NNMonthDisplayDefaultModelDependency:
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
  func dayRange(_ month: NNCalendarLogic.Month) -> [NNCalendarLogic.Day]
}

public extension NNCalendarLogic.MonthDisplay {

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
      let monthControlModel = NNCalendarLogic.MonthControl.Model(dependency)
      let monthGridModel = NNCalendarLogic.MonthGrid.Model(dependency)
      let daySelectionModel = NNCalendarLogic.DaySelect.Model(dependency)
      self.init(monthControlModel, monthGridModel, daySelectionModel, dependency)
    }

    convenience public init(_ dependency: NNMonthDisplayNoDefaultModelDependency) {
      let defaultDP = DefaultDependency(dependency)
      self.init(defaultDP)
    }
  }
}

// MARK: - NNGridDisplayDefaultFunction
extension NNCalendarLogic.MonthDisplay.Model: NNGridDisplayDefaultFunction {
  public var weekdayStacks: Int { return monthGridModel.weekdayStacks }
}

// MARK: - NNMonthAwareNoDefaultModelFunction
extension NNCalendarLogic.MonthDisplay.Model: NNMonthAwareNoDefaultModelFunction {
  public var currentMonthStream: Observable<NNCalendarLogic.Month> {
    return dependency.currentMonthStream
  }
}

// MARK: - NNMonthControlModelType
extension NNCalendarLogic.MonthDisplay.Model: NNMonthControlModelType {
  public var initialMonthStream: Single<NNCalendarLogic.Month> {
    return monthControlModel.initialMonthStream
  }

  public var minimumMonth: NNCalendarLogic.Month {
    return monthControlModel.minimumMonth
  }

  public var maximumMonth: NNCalendarLogic.Month {
    return monthControlModel.maximumMonth
  }
}

// MARK: - NNMonthControlNoDefaultFunction
extension NNCalendarLogic.MonthDisplay.Model: NNMonthControlNoDefaultFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
    return dependency.currentMonthReceiver
  }
}

// MARK: - NNSelectHighlightNoDefaultFunction
extension NNCalendarLogic.MonthDisplay.Model: NNSelectHighlightNoDefaultFunction {
  public func highlightPart(_ date: Date) -> NNCalendarLogic.HighlightPart {
    return dependency.highlightPart(date)
  }
}

// MARK: - NNSingleDaySelectionNoDefaultFunction
extension NNCalendarLogic.MonthDisplay.Model: NNSingleDaySelectionNoDefaultFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return daySelectionModel.isDateSelected(date)
  }
}

// MARK: - NNSingleDaySelectionModelType
extension NNCalendarLogic.MonthDisplay.Model: NNSingleDaySelectionModelType {
  public var allSelectionReceiver: AnyObserver<Set<NNCalendarLogic.Selection>> {
    return daySelectionModel.allSelectionReceiver
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendarLogic.Selection>>> {
    return daySelectionModel.allSelectionStream
  }
}

// MARK: - NNWeekdayAwareDefaultModelFunction
extension NNCalendarLogic.MonthDisplay.Model: NNWeekdayAwareDefaultModelFunction {
  public var firstWeekday: Int {
    return daySelectionModel.firstWeekday
  }
}

// MARK: - NNMonthDisplayModelType
extension NNCalendarLogic.MonthDisplay.Model: NNMonthDisplayModelType {
  public func dayRange(_ month: NNCalendarLogic.Month) -> [NNCalendarLogic.Day] {
    let calendar = Calendar.current

    return NNCalendarLogic.Util.dateRange(month, firstWeekday, weekdayStacks).map({
      let description = calendar.component(.day, from: $0).description

      return NNCalendarLogic.Day($0)
        .with(dateDescription: description)
        .with(currentMonth: month.contains($0))
    })
  }

  public func gridSelectionChanges(_ monthComp: NNCalendarLogic.MonthComp,
                                   _ prev: Set<NNCalendarLogic.Selection>,
                                   _ current: Set<NNCalendarLogic.Selection>)
    -> Set<NNCalendarLogic.GridPosition>
  {
    return dependency.gridSelectionChanges(monthComp, prev, current)
  }
}

// MARK: - Default dependency.
public extension NNCalendarLogic.MonthDisplay.Model {

  /// Default dependency for month display model. This delegates non-default
  /// components to a separate dependency.
  public final class DefaultDependency: NNMonthDisplayModelDependency {
    public var weekdayStacks: Int { return monthGridDp.weekdayStacks }
    public var firstWeekday: Int { return daySelectionDp.firstWeekday }
    public var minimumMonth: NNCalendarLogic.Month { return noDefault.minimumMonth }
    public var maximumMonth: NNCalendarLogic.Month { return noDefault.maximumMonth }

    public var initialMonthStream: Single<NNCalendarLogic.Month> {
      return noDefault.initialMonthStream
    }

    public var allSelectionStream: Observable<Try<Set<NNCalendarLogic.Selection>>> {
      return noDefault.allSelectionStream
    }

    public var allSelectionReceiver: AnyObserver<Set<NNCalendarLogic.Selection>> {
      return noDefault.allSelectionReceiver
    }

    public var currentMonthStream: Observable<NNCalendarLogic.Month> {
      return noDefault.currentMonthStream
    }

    public var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
      return noDefault.currentMonthReceiver
    }

    private let noDefault: NNMonthDisplayNoDefaultModelDependency
    private let monthGridDp: NNMonthGridModelDependency
    private let daySelectionDp: NNSingleDaySelectionModelDependency
    private let highlightCalc: NNCalendarLogic.DateCalc.HighlightPart

    public init(_ dependency: NNMonthDisplayNoDefaultModelDependency) {
      noDefault = dependency
      monthGridDp = NNCalendarLogic.MonthGrid.Model.DefaultDependency()
      daySelectionDp = NNCalendarLogic.DaySelect.Model.DefaultDependency(dependency)

      let dateCalc = NNCalendarLogic.DateCalc
        .Default(monthGridDp.weekdayStacks, daySelectionDp.firstWeekday)

      highlightCalc = NNCalendarLogic.DateCalc
        .HighlightPart(dateCalc, monthGridDp.weekdayStacks)
    }

    public func isDateSelected(_ date: Date) -> Bool {
      return noDefault.isDateSelected(date)
    }

    public func highlightPart(_ date: Date) -> NNCalendarLogic.HighlightPart {
      return noDefault.highlightPart(date)
    }

    public func gridSelectionChanges(_ monthComp: NNCalendarLogic.MonthComp,
                                     _ prev: Set<NNCalendarLogic.Selection>,
                                     _ current: Set<NNCalendarLogic.Selection>)
      -> Set<NNCalendarLogic.GridPosition>
    {
      return highlightCalc.gridSelectionChanges(monthComp, prev, current)
    }
  }
}
