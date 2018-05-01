//
//  Regular99Model.swift
//  calendar99-presetLogic
//
//  Created by Hai Pham on 23/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP
import calendar99_logic

/// Dependency for Regular99 preset model.
public protocol NNRegular99CalendarModelDependency:
  NNMonthHeaderModelDependency,
  NNMonthSectionModelDependency,
  NNSelectWeekdayModelDependency {}

/// Model for Regular99 preset.
public protocol NNRegular99CalendarModelType:
  NNMonthHeaderModelType,
  NNMonthSectionModelType,
  NNSelectWeekdayModelType {}

// MARK: - Model.
public extension NNCalendarPreset.Regular99 {

  /// Model implementation for Regular99 preset.
  public final class Model {
    fileprivate let monthHeaderModel: NNMonthHeaderModelType
    fileprivate let monthSectionModel: NNMonthSectionModelType
    fileprivate let selectableWdModel: NNSelectWeekdayModelType

    required public init(_ monthHeaderModel: NNMonthHeaderModelType,
                         _ monthSectionModel: NNMonthSectionModelType,
                         _ selectableWdModel: NNSelectWeekdayModelType) {
      self.monthHeaderModel = monthHeaderModel
      self.monthSectionModel = monthSectionModel
      self.selectableWdModel = selectableWdModel
    }

    convenience public init(_ dependency: NNRegular99CalendarModelDependency) {
      let monthHeaderModel = NNCalendarLogic.MonthHeader.Model(dependency)
      let monthSectionModel = NNCalendarLogic.MonthSection.Model(dependency)
      let selectableWdModel = NNCalendarLogic.SelectWeekday.Model(dependency)
      self.init(monthHeaderModel, monthSectionModel, selectableWdModel)
    }
  }
}

// MARK: - NNGridDisplayFunction
extension NNCalendarPreset.Regular99.Model: NNGridDisplayFunction {
  public var weekdayStacks: Int {
    return monthSectionModel.weekdayStacks
  }
}

// MARK: - NNMonthAwareModelFunction
extension NNCalendarPreset.Regular99.Model: NNMonthAwareModelFunction {
  public var currentMonthStream: Observable<NNCalendarLogic.Month> {
    return monthSectionModel.currentMonthStream
  }
}

// MARK: - NNMonthControlFunction
extension NNCalendarPreset.Regular99.Model: NNMonthControlFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
    return monthSectionModel.currentMonthReceiver
  }
}

// MARK: - NNMonthControlModelFunction
extension NNCalendarPreset.Regular99.Model: NNMonthControlModelFunction {
  public var initialMonthStream: PrimitiveSequence<SingleTrait, NNCalendarLogic.Month> {
    return monthSectionModel.initialMonthStream
  }

  public var minimumMonth: NNCalendarLogic.Month {
    return monthSectionModel.minimumMonth
  }

  public var maximumMonth: NNCalendarLogic.Month {
    return monthSectionModel.maximumMonth
  }
}

// MARK: - NNSelectHighlightFunction
extension NNCalendarPreset.Regular99.Model: NNSelectHighlightFunction {
  public func highlightPart(_ date: Date) -> NNCalendarLogic.HighlightPart {
    return monthSectionModel.highlightPart(date)
  }
}

// MARK: - NNMonthHeaderModelFunction
extension NNCalendarPreset.Regular99.Model: NNMonthHeaderModelFunction {
  public func formatMonthDescription(_ month: NNCalendarLogic.Month) -> String {
    return monthHeaderModel.formatMonthDescription(month)
  }
}

// MARK: - NNMultiDaySelectionFunction
extension NNCalendarPreset.Regular99.Model: NNMultiDaySelectionFunction {
  public var allSelectionReceiver: AnyObserver<Set<NNCalendarLogic.Selection>> {
    return monthSectionModel.allSelectionReceiver
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendarLogic.Selection>>> {
    return monthSectionModel.allSelectionStream
  }
}

// MARK: - NNSingleDaySelectionFunction
extension NNCalendarPreset.Regular99.Model: NNSingleDaySelectionFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return monthSectionModel.isDateSelected(date)
  }
}

// MARK: - NNMultiMonthGridSelectionCalculator
extension NNCalendarPreset.Regular99.Model: NNMultiMonthGridSelectionCalculator {
  public func gridSelectionChanges(_ monthComps: [NNCalendarLogic.MonthComp],
                                   _ currentMonth: NNCalendarLogic.Month,
                                   _ prev: Set<NNCalendarLogic.Selection>,
                                   _ current: Set<NNCalendarLogic.Selection>)
    -> Set<NNCalendarLogic.GridPosition>
  {
    return monthSectionModel
      .gridSelectionChanges(monthComps, currentMonth, prev, current)
  }
}

// MARK: - NNWeekdayAwareModelFunction
extension NNCalendarPreset.Regular99.Model: NNWeekdayAwareModelFunction {
  public var firstWeekday: Int {
    return monthSectionModel.firstWeekday
  }
}

// MARK: - NNWeekdayDisplayModelFunction
extension NNCalendarPreset.Regular99.Model: NNWeekdayDisplayModelFunction {
  public func weekdayDescription(_ weekday: Int) -> String {
    return selectableWdModel.weekdayDescription(weekday)
  }
}

// MARK: - NNMonthSectionModelDependency
extension NNCalendarPreset.Regular99.Model: NNMonthSectionModelDependency {
  public func dayFromFirstDate(_ month: NNCalendarLogic.Month,
                               _ firstDateOffset: Int) -> NNCalendarLogic.Day? {
    return monthSectionModel.dayFromFirstDate(month, firstDateOffset)
  }
}

// MARK: - NNRegular99CalendarModelType
extension NNCalendarPreset.Regular99.Model: NNRegular99CalendarModelType {}
