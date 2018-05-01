//
//  MonthDisplayModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Shared functionalities between the model and its dependency.
public protocol NNMonthDisplayModelFunction:
  NNSelectHighlightFunction,
  NNSingleMonthGridSelectionCalculator {}

/// Dependency for month display model.
public protocol NNMonthDisplayModelDependency:
  NNMonthControlModelDependency,
  NNMonthDisplayModelFunction,
  NNMonthGridModelDependency,
  NNSingleDaySelectionModelDependency {}

/// Model for month display view.
public protocol NNMonthDisplayModelType:
  NNMonthControlModelType,
  NNMonthDisplayModelFunction,
  NNMonthGridModelType,
  NNSingleDaySelectionModelType
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
  }
}

// MARK: - NNGridDisplayFunction
extension NNCalendarLogic.MonthDisplay.Model: NNGridDisplayFunction {
  public var weekdayStacks: Int { return monthGridModel.weekdayStacks }
}

// MARK: - NNMonthAwareModelFunction
extension NNCalendarLogic.MonthDisplay.Model: NNMonthAwareModelFunction {
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

// MARK: - NNMonthControlFunction
extension NNCalendarLogic.MonthDisplay.Model: NNMonthControlFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
    return dependency.currentMonthReceiver
  }
}

// MARK: - NNSelectHighlightFunction
extension NNCalendarLogic.MonthDisplay.Model: NNSelectHighlightFunction {
  public func highlightPart(_ date: Date) -> NNCalendarLogic.HighlightPart {
    return dependency.highlightPart(date)
  }
}

// MARK: - NNSingleDaySelectionFunction
extension NNCalendarLogic.MonthDisplay.Model: NNSingleDaySelectionFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return daySelectionModel.isDateSelected(date)
  }
}

// MARK: - NNMultiDaySelectionFunction
extension NNCalendarLogic.MonthDisplay.Model: NNMultiDaySelectionFunction {
  public var allSelectionReceiver: AnyObserver<Set<NNCalendarLogic.Selection>> {
    return daySelectionModel.allSelectionReceiver
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendarLogic.Selection>>> {
    return daySelectionModel.allSelectionStream
  }
}

// MARK: - NNSingleMonthGridSelectionCalculator
extension NNCalendarLogic.MonthDisplay.Model: NNSingleMonthGridSelectionCalculator {
  public func gridSelectionChanges(_ monthComp: NNCalendarLogic.MonthComp,
                                   _ prev: Set<NNCalendarLogic.Selection>,
                                   _ current: Set<NNCalendarLogic.Selection>)
    -> Set<NNCalendarLogic.GridPosition>
  {
    return dependency.gridSelectionChanges(monthComp, prev, current)
  }
}

// MARK: - NNWeekdayAwareModelFunction
extension NNCalendarLogic.MonthDisplay.Model: NNWeekdayAwareModelFunction {
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
}
