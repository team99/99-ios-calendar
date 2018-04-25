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
  NNSelectHighlightNoDefaultFunction {}

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
  func dayFromFirstDate(_ month: NNCalendarLogic.Month,
                        _ firstDateOffset: Int) -> NNCalendarLogic.Day?
}

public extension NNCalendarLogic.MonthSection {

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
      let monthControlModel = NNCalendarLogic.MonthControl.Model(dependency)
      let monthGridModel = NNCalendarLogic.MonthGrid.Model(dependency)
      let daySelectionModel = NNCalendarLogic.DaySelect.Model(dependency)
      self.init(monthControlModel, monthGridModel, daySelectionModel, dependency)
    }

    convenience public init(_ dependency: NNMonthSectionNoDefaultModelDependency) {
      let defaultDp = DefaultDependency(dependency)
      self.init(defaultDp)
    }
  }
}

// MARK: - NNGridDisplayDefaultFunction
extension NNCalendarLogic.MonthSection.Model: NNGridDisplayDefaultFunction {
  public var weekdayStacks: Int { return monthGridModel.weekdayStacks }
}

// MARK: - NNMonthAwareNoDefaultModelFunction
extension NNCalendarLogic.MonthSection.Model: NNMonthAwareNoDefaultModelFunction {
  public var currentMonthStream: Observable<NNCalendarLogic.Month> {
    return monthControlModel.currentMonthStream
  }
}

// MARK: - NNMonthControlNoDefaultFunction
extension NNCalendarLogic.MonthSection.Model: NNMonthControlNoDefaultFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
    return monthControlModel.currentMonthReceiver
  }
}

// MARK: - NNMonthControlNoDefaultModelFunction
extension NNCalendarLogic.MonthSection.Model: NNMonthControlNoDefaultModelFunction {
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

// MARK: - NNGridSelectionCalculatorType
extension NNCalendarLogic.MonthSection.Model: NNMultiMonthGridSelectionCalculator {
  public func gridSelectionChanges(_ monthComps: [NNCalendarLogic.MonthComp],
                                   _ currentMonth: NNCalendarLogic.Month,
                                   _ prev: Set<NNCalendarLogic.Selection>,
                                   _ current: Set<NNCalendarLogic.Selection>)
    -> Set<NNCalendarLogic.GridPosition>
  {
    return dependency.gridSelectionChanges(monthComps, currentMonth, prev, current)
  }
}

// MARK: - NNSingleDaySelectionNoDefaultFunction
extension NNCalendarLogic.MonthSection.Model: NNSingleDaySelectionNoDefaultFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return daySelectionModel.isDateSelected(date)
  }
}

// MARK: - NNSelectHighlightNoDefaultFunction
extension NNCalendarLogic.MonthSection.Model: NNSelectHighlightNoDefaultFunction {
  public func highlightPart(_ date: Date) -> NNCalendarLogic.HighlightPart {
    return dependency.highlightPart(date)
  }
}

// MARK: - NNDaySelectionModelType
extension NNCalendarLogic.MonthSection.Model: NNSingleDaySelectionModelType {
  public var allSelectionReceiver: AnyObserver<Set<NNCalendarLogic.Selection>> {
    return daySelectionModel.allSelectionReceiver
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendarLogic.Selection>>> {
    return daySelectionModel.allSelectionStream
  }
}

// MARK: - NNWeekdayAwareDefaultModelFunction
extension NNCalendarLogic.MonthSection.Model: NNWeekdayAwareDefaultModelFunction {
  public var firstWeekday: Int {
    return daySelectionModel.firstWeekday
  }
}

// MARK: - NNMonthSectionModelType
extension NNCalendarLogic.MonthSection.Model: NNMonthSectionModelType {
  public func dayFromFirstDate(_ month: NNCalendarLogic.Month,
                               _ firstDateOffset: Int) -> NNCalendarLogic.Day? {
    return NNCalendarLogic.Util.dateWithOffset(month, firstWeekday, firstDateOffset).map({
      let description = Calendar.current.component(.day, from: $0).description

      return NNCalendarLogic.Day($0)
        .with(dateDescription: description)
        .with(currentMonth: month.contains($0))
    })
  }
}

public extension NNCalendarLogic.MonthSection.Model {

  /// Default dependency for month section model.
  public final class DefaultDependency: NNMonthSectionModelDependency {
    public var weekdayStacks: Int { return monthGridDp.weekdayStacks }
    public var firstWeekday: Int { return daySelectionDp.firstWeekday }
    public var minimumMonth: NNCalendarLogic.Month { return noDefault.minimumMonth }
    public var maximumMonth: NNCalendarLogic.Month { return noDefault.maximumMonth }

    public var initialMonthStream: Single<NNCalendarLogic.Month> {
      return noDefault.initialMonthStream
    }

    public var currentMonthStream: Observable<NNCalendarLogic.Month> {
      return noDefault.currentMonthStream
    }

    public var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
      return noDefault.currentMonthReceiver
    }

    public var allSelectionReceiver: AnyObserver<Set<NNCalendarLogic.Selection>> {
      return noDefault.allSelectionReceiver
    }

    public var allSelectionStream: Observable<Try<Set<NNCalendarLogic.Selection>>> {
      return noDefault.allSelectionStream
    }

    private let noDefault: NNMonthSectionNoDefaultModelDependency
    private let monthGridDp: NNMonthGridModelDependency
    private let daySelectionDp: NNSingleDaySelectionModelDependency
    private let dateCalc: NNCalendarLogic.DateCalc.Default

    /// Use this to calculate grid selection changes while catering to selection
    /// highlighting. Consult the documentation for this class to understand
    /// why we need a separate calculator for this task.
    private let highlightCalc: NNCalendarLogic.DateCalc.HighlightPart

    public init(_ dependency: NNMonthSectionNoDefaultModelDependency) {
      noDefault = dependency
      monthGridDp = NNCalendarLogic.MonthGrid.Model.DefaultDependency()
      daySelectionDp = NNCalendarLogic.DaySelect.Model.DefaultDependency(dependency)

      let weekdayStacks = monthGridDp.weekdayStacks
      dateCalc = NNCalendarLogic.DateCalc.Default(weekdayStacks, daySelectionDp.firstWeekday)
      highlightCalc = NNCalendarLogic.DateCalc.HighlightPart(dateCalc, weekdayStacks)
    }

    public func gridSelectionChanges(_ monthComps: [NNCalendarLogic.MonthComp],
                                     _ currentMonth: NNCalendarLogic.Month,
                                     _ prev: Set<NNCalendarLogic.Selection>,
                                     _ current: Set<NNCalendarLogic.Selection>)
      -> Set<NNCalendarLogic.GridPosition>
    {
      return highlightCalc
        .gridSelectionChanges(monthComps, currentMonth, prev, current)
    }

    public func isDateSelected(_ date: Date) -> Bool {
      return noDefault.isDateSelected(date)
    }

    public func highlightPart(_ date: Date) -> NNCalendarLogic.HighlightPart {
      return noDefault.highlightPart(date)
    }
  }
}
