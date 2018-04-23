//
//  MonthSectionModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Shared dependencies between the model and its dependency that can have
/// defaults.
public protocol NNMonthSectionDefaultModelFunction:
  NNMonthControlDefaultModelFunction,
  NNMultiMonthGridSelectionCalculator,
  NNSelectHighlightDefaultFunction {}

/// Shared functionalities between the model and its dependency that cannot
/// have dependencies.
public protocol NNMonthSectionNoDefaultModelFunction:
  NNMonthControlNoDefaultModelFunction,
  NNSelectHighlightNoDefaultFunction
{
  /// Get the number of past months to include in the month data stream.
  var pastMonthsFromCurrent: Int { get }

  /// Get the number of future months to include in the month data stream.
  var futureMonthsFromCurrent: Int { get }
}

/// Dependency for month section model, which contains components that can have
/// defaults.
public protocol NNMonthSectionDefaultModelDependency:
  NNMonthSectionDefaultModelFunction,
  NNSingleDaySelectionDefaultModelDependency {}

/// Dependency for month section model, which contains components that cannot
/// have defaults.
public protocol NNMonthSectionNoDefaultModelDependency:
  NNMonthSectionNoDefaultModelFunction,
  NNSingleDaySelectionNoDefaultModelDependency {}

/// Dependency for month section model.
public protocol NNMonthSectionModelDependency:
  NNMonthControlModelDependency,
  NNMonthSectionDefaultModelDependency,
  NNMonthSectionNoDefaultModelDependency,
  NNMonthGridModelDependency {}

/// Model for month section view.
public protocol NNMonthSectionModelType:
  NNMonthControlModelType,
  NNMonthGridModelType,
  NNMonthSectionDefaultModelFunction,
  NNMonthSectionNoDefaultModelFunction,
  NNSingleDaySelectionModelType
{
  /// Calculate the day for a month and a first date offset (i.e. how distant
  /// the day is from the first date in the grid).
  ///
  /// - Parameters:
  ///   - month: A Month instance.
  ///   - firstDateOffset: Offset from the initial date in the grid.
  /// - Returns: A Day instance.
  func dayFromFirstDate(_ month: NNCalendar.Month,
                        _ firstDateOffset: Int) -> NNCalendar.Day?
}

public extension NNCalendar.MonthSection {

  /// Model implementation for month section view.
  public final class Model {
    fileprivate let monthControlModel: NNMonthControlModelType
    fileprivate let monthGridModel: NNMonthGridModelType
    fileprivate let daySelectionModel: NNSingleDaySelectionModelType
    fileprivate let dependency: NNMonthSectionModelDependency

    required public init(_ monthControlModel: NNMonthControlModelType,
                         _ monthGridModel: NNMonthGridModelType,
                         _ daySelectionModel: NNSingleDaySelectionModelType,
                         _ dependency: NNMonthSectionModelDependency) {
      self.monthControlModel = monthControlModel
      self.monthGridModel = monthGridModel
      self.daySelectionModel = daySelectionModel
      self.dependency = dependency
    }

    convenience public init(_ dependency: NNMonthSectionModelDependency) {
      let monthControlModel = NNCalendar.MonthControl.Model(dependency)
      let monthGridModel = NNCalendar.MonthGrid.Model(dependency)
      let daySelectionModel = NNCalendar.DaySelection.Model(dependency)
      self.init(monthControlModel, monthGridModel, daySelectionModel, dependency)
    }

    convenience public init(_ dependency: NNMonthSectionNoDefaultModelDependency) {
      let defaultDp = DefaultDependency(dependency)
      self.init(defaultDp)
    }
  }
}

// MARK: - NNGridDisplayDefaultFunction
extension NNCalendar.MonthSection.Model: NNGridDisplayDefaultFunction {
  public var weekdayStacks: Int { return monthGridModel.weekdayStacks }
}

// MARK: - NNMonthAwareNoDefaultModelFunction
extension NNCalendar.MonthSection.Model: NNMonthAwareNoDefaultModelFunction {
  public var currentMonthStream: Observable<NNCalendar.Month> {
    return monthControlModel.currentMonthStream
  }
}

// MARK: - NNMonthControlModelType
extension NNCalendar.MonthSection.Model: NNMonthControlModelType {
  public var initialMonthStream: Single<NNCalendar.Month> {
    return monthControlModel.initialMonthStream
  }

  public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    return monthControlModel.currentMonthReceiver
  }
}

// MARK: - NNGridSelectionCalculatorType
extension NNCalendar.MonthSection.Model: NNMultiMonthGridSelectionCalculator {
  public func gridSelectionChanges(_ monthComps: [NNCalendar.MonthComp],
                                   _ currentMonth: NNCalendar.Month,
                                   _ prev: Set<NNCalendar.Selection>,
                                   _ current: Set<NNCalendar.Selection>)
    -> Set<NNCalendar.GridPosition>
  {
    return dependency.gridSelectionChanges(monthComps, currentMonth, prev, current)
  }
}

// MARK: - NNSingleDaySelectionNoDefaultFunction
extension NNCalendar.MonthSection.Model: NNSingleDaySelectionNoDefaultFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return daySelectionModel.isDateSelected(date)
  }
}

// MARK: - NNSelectHighlightNoDefaultFunction
extension NNCalendar.MonthSection.Model: NNSelectHighlightNoDefaultFunction {
  public func highlightPart(_ date: Date) -> NNCalendar.HighlightPart {
    return dependency.highlightPart(date)
  }
}

// MARK: - NNMonthSectionNoDefaultModelFunction
extension NNCalendar.MonthSection.Model: NNMonthSectionNoDefaultModelFunction {
  public var pastMonthsFromCurrent: Int {
    return dependency.pastMonthsFromCurrent
  }

  public var futureMonthsFromCurrent: Int {
    return dependency.futureMonthsFromCurrent
  }
}

// MARK: - NNDaySelectionModelType
extension NNCalendar.MonthSection.Model: NNSingleDaySelectionModelType {
  public var allSelectionReceiver: AnyObserver<Set<NNCalendar.Selection>> {
    return daySelectionModel.allSelectionReceiver
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendar.Selection>>> {
    return daySelectionModel.allSelectionStream
  }
}

// MARK: - NNWeekdayAwareDefaultModelFunction
extension NNCalendar.MonthSection.Model: NNWeekdayAwareDefaultModelFunction {
  public var firstWeekday: Int {
    return daySelectionModel.firstWeekday
  }
}

// MARK: - NNMonthSectionModelType
extension NNCalendar.MonthSection.Model: NNMonthSectionModelType {
  public func dayFromFirstDate(_ month: NNCalendar.Month,
                               _ firstDateOffset: Int) -> NNCalendar.Day? {
    return NNCalendar.Util.dateWithOffset(month, firstWeekday, firstDateOffset).map({
      let description = Calendar.current.component(.day, from: $0).description

      return NNCalendar.Day($0)
        .with(dateDescription: description)
        .with(currentMonth: month.contains($0))
    })
  }
}

extension NNCalendar.MonthSection.Model {

  /// Default dependency for month section model.
  final class DefaultDependency: NNMonthSectionModelDependency {
    var weekdayStacks: Int { return monthGridDp.weekdayStacks }
    var pastMonthsFromCurrent: Int { return noDefault.pastMonthsFromCurrent }
    var futureMonthsFromCurrent: Int { return noDefault.futureMonthsFromCurrent }
    var firstWeekday: Int { return daySelectionDp.firstWeekday }

    var initialMonthStream: Single<NNCalendar.Month> {
      return noDefault.initialMonthStream
    }

    var currentMonthStream: Observable<NNCalendar.Month> {
      return noDefault.currentMonthStream
    }

    var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
      return noDefault.currentMonthReceiver
    }

    var allSelectionReceiver: AnyObserver<Set<NNCalendar.Selection>> {
      return noDefault.allSelectionReceiver
    }

    var allSelectionStream: Observable<Try<Set<NNCalendar.Selection>>> {
      return noDefault.allSelectionStream
    }

    private let noDefault: NNMonthSectionNoDefaultModelDependency
    private let monthGridDp: NNMonthGridModelDependency
    private let daySelectionDp: NNSingleDaySelectionModelDependency
    private let dateCalc: NNCalendar.DateCalc.Default

    /// Use this to calculate grid selection changes while catering to selection
    /// highlighting. Consult the documentation for this class to understand
    /// why we need a separate calculator for this task.
    private let highlightCalc: NNCalendar.DateCalc.HighlightPart

    init(_ dependency: NNMonthSectionNoDefaultModelDependency) {
      noDefault = dependency
      monthGridDp = NNCalendar.MonthGrid.Model.DefaultDependency()
      daySelectionDp = NNCalendar.DaySelection.Model.DefaultDependency(dependency)

      let weekdayStacks = monthGridDp.weekdayStacks
      dateCalc = NNCalendar.DateCalc.Default(weekdayStacks, daySelectionDp.firstWeekday)
      highlightCalc = NNCalendar.DateCalc.HighlightPart(dateCalc, weekdayStacks)
    }

    func gridSelectionChanges(_ monthComps: [NNCalendar.MonthComp],
                              _ currentMonth: NNCalendar.Month,
                              _ prev: Set<NNCalendar.Selection>,
                              _ current: Set<NNCalendar.Selection>)
      -> Set<NNCalendar.GridPosition>
    {
      return highlightCalc
        .gridSelectionChanges(monthComps, currentMonth, prev, current)
    }

    func isDateSelected(_ date: Date) -> Bool {
      return noDefault.isDateSelected(date)
    }

    func highlightPart(_ date: Date) -> NNCalendar.HighlightPart {
      return noDefault.highlightPart(date)
    }
  }
}
