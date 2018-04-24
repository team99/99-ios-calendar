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

/// Defaultable dependency for Regular99 preset model.
public protocol NNRegular99CalendarDefaultModelDependency:
  NNMonthHeaderDefaultModelDependency,
  NNMonthSectionDefaultModelDependency,
  NNSelectWeekdayDefaultModelDependency {}

/// Non-defaultable dependency for Regular99 preset model.
public protocol NNRegular99CalendarNoDefaultModelDependency:
  NNMonthHeaderNoDefaultModelDependency,
  NNMonthSectionNoDefaultModelDependency,
  NNSelectWeekdayNoDefaultModelDependency {}

/// Dependency for Regular99 preset model.
public protocol NNRegular99CalendarModelDependency:
  NNMonthHeaderModelDependency,
  NNMonthSectionModelDependency,
  NNSelectWeekdayModelDependency,
  NNRegular99CalendarDefaultModelDependency,
  NNRegular99CalendarNoDefaultModelDependency {}

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
      let monthHeaderModel = NNCalendar.MonthHeader.Model(dependency)
      let monthSectionModel = NNCalendar.MonthSection.Model(dependency)
      let selectableWdModel = NNCalendar.SelectWeekday.Model(dependency)
      self.init(monthHeaderModel, monthSectionModel, selectableWdModel)
    }

    convenience public init(_ dependency: NNRegular99CalendarNoDefaultModelDependency) {
      let monthHeaderModel = NNCalendar.MonthHeader.Model(dependency)
      let monthSectionModel = NNCalendar.MonthSection.Model(dependency)
      let selectableWdModel = NNCalendar.SelectWeekday.Model(dependency)
      self.init(monthHeaderModel, monthSectionModel, selectableWdModel)
    }
  }
}

// MARK: - NNGridDisplayDefaultFunction
extension NNCalendarPreset.Regular99.Model: NNGridDisplayDefaultFunction {
  public var weekdayStacks: Int {
    return monthSectionModel.weekdayStacks
  }
}

// MARK: - NNMonthAwareNoDefaultModelFunction
extension NNCalendarPreset.Regular99.Model: NNMonthAwareNoDefaultModelFunction {
  public var currentMonthStream: Observable<NNCalendar.Month> {
    return monthSectionModel.currentMonthStream
  }
}

// MARK: - NNMonthControlNoDefaultFunction
extension NNCalendarPreset.Regular99.Model: NNMonthControlNoDefaultFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    return monthSectionModel.currentMonthReceiver
  }
}

// MARK: - NNMonthControlNoDefaultModelFunction
extension NNCalendarPreset.Regular99.Model: NNMonthControlNoDefaultModelFunction {
  public var initialMonthStream: PrimitiveSequence<SingleTrait, NNCalendar.Month> {
    return monthSectionModel.initialMonthStream
  }

  public var minimumMonth: NNCalendar.Month {
    return monthSectionModel.minimumMonth
  }

  public var maximumMonth: NNCalendar.Month {
    return monthSectionModel.maximumMonth
  }
}

// MARK: - NNSelectHighlightNoDefaultFunction
extension NNCalendarPreset.Regular99.Model: NNSelectHighlightNoDefaultFunction {
  public func highlightPart(_ date: Date) -> NNCalendar.HighlightPart {
    return monthSectionModel.highlightPart(date)
  }
}

// MARK: - NNMonthHeaderNoDefaultModelFunction
extension NNCalendarPreset.Regular99.Model: NNMonthHeaderDefaultModelFunction {
  public func formatMonthDescription(_ month: NNCalendar.Month) -> String {
    return monthHeaderModel.formatMonthDescription(month)
  }
}

// MARK: - NNMultiDaySelectionNoDefaultFunction
extension NNCalendarPreset.Regular99.Model: NNMultiDaySelectionNoDefaultFunction {
  public var allSelectionReceiver: AnyObserver<Set<NNCalendar.Selection>> {
    return monthSectionModel.allSelectionReceiver
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendar.Selection>>> {
    return monthSectionModel.allSelectionStream
  }
}

// MARK: - NNSingleDaySelectionNoDefaultFunction
extension NNCalendarPreset.Regular99.Model: NNSingleDaySelectionNoDefaultFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return monthSectionModel.isDateSelected(date)
  }
}

// MARK: - NNMultiMonthGridSelectionCalculator
extension NNCalendarPreset.Regular99.Model: NNMultiMonthGridSelectionCalculator {
  public func gridSelectionChanges(_ monthComps: [NNCalendar.MonthComp],
                                   _ currentMonth: NNCalendar.Month,
                                   _ prev: Set<NNCalendar.Selection>,
                                   _ current: Set<NNCalendar.Selection>)
    -> Set<NNCalendar.GridPosition>
  {
    return monthSectionModel
      .gridSelectionChanges(monthComps, currentMonth, prev, current)
  }
}

// MARK: - NNWeekdayAwareNoDefaultModelFunction
extension NNCalendarPreset.Regular99.Model: NNWeekdayAwareNoDefaultModelFunction {
  public var firstWeekday: Int {
    return monthSectionModel.firstWeekday
  }
}

// MARK: - NNWeekdayDisplayDefaultModelFunction
extension NNCalendarPreset.Regular99.Model: NNWeekdayDisplayDefaultModelFunction {
  public func weekdayDescription(_ weekday: Int) -> String {
    return selectableWdModel.weekdayDescription(weekday)
  }
}

// MARK: - NNMonthSectionNoDefaultModelDependency
extension NNCalendarPreset.Regular99.Model: NNMonthSectionNoDefaultModelDependency {
  public func dayFromFirstDate(_ month: NNCalendar.Month,
                               _ firstDateOffset: Int) -> NNCalendar.Day? {
    return monthSectionModel.dayFromFirstDate(month, firstDateOffset)
  }
}

// MARK: - NNRegular99CalendarModelType
extension NNCalendarPreset.Regular99.Model: NNRegular99CalendarModelType {}
