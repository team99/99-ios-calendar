//
//  MonthSectionModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Shared functionalities between the model and its dependency.
public protocol NNMonthSectionModelFunction:
  NNMultiMonthGridSelectionCalculator,
  NNSelectHighlightFunction {}

/// Dependency for month section model.
public protocol NNMonthSectionModelDependency:
  NNMonthControlModelDependency,
  NNMonthGridModelDependency,
  NNMonthSectionModelFunction,
  NNSingleDaySelectionModelDependency {}

/// Model for month section view.
public protocol NNMonthSectionModelType:
  NNMonthControlModelType,
  NNMonthGridModelType,
  NNMonthSectionModelFunction,
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
  }
}

// MARK: - NNGridDisplayFunction
extension NNCalendarLogic.MonthSection.Model: NNGridDisplayFunction {
  public var weekdayStacks: Int { return monthGridModel.weekdayStacks }
}

// MARK: - NNMonthAwareModelFunction
extension NNCalendarLogic.MonthSection.Model: NNMonthAwareModelFunction {
  public var currentMonthStream: Observable<NNCalendarLogic.Month> {
    return monthControlModel.currentMonthStream
  }
}

// MARK: - NNMonthControlFunction
extension NNCalendarLogic.MonthSection.Model: NNMonthControlFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
    return monthControlModel.currentMonthReceiver
  }
}

// MARK: - NNMonthControlModelFunction
extension NNCalendarLogic.MonthSection.Model: NNMonthControlModelFunction {
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

// MARK: - NNSingleDaySelectionFunction
extension NNCalendarLogic.MonthSection.Model: NNSingleDaySelectionFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return daySelectionModel.isDateSelected(date)
  }
}

// MARK: - NNSelectHighlightFunction
extension NNCalendarLogic.MonthSection.Model: NNSelectHighlightFunction {
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

// MARK: - NNWeekdayAwareModelFunction
extension NNCalendarLogic.MonthSection.Model: NNWeekdayAwareModelFunction {
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
