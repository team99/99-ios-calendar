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
      let monthHeaderModel = NNCalendarLogic.MonthHeader.Model(dependency)
      let monthSectionModel = NNCalendarLogic.MonthSection.Model(dependency)
      let selectableWdModel = NNCalendarLogic.SelectWeekday.Model(dependency)
      self.init(monthHeaderModel, monthSectionModel, selectableWdModel)
    }

    convenience public init(_ dependency: NNRegular99CalendarNoDefaultModelDependency) {
      let monthHeaderModel = NNCalendarLogic.MonthHeader.Model(dependency)
      let monthSectionModel = NNCalendarLogic.MonthSection.Model(dependency)
      let selectableWdModel = NNCalendarLogic.SelectWeekday.Model(dependency)
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
  public var currentMonthStream: Observable<NNCalendarLogic.Month> {
    return monthSectionModel.currentMonthStream
  }
}

// MARK: - NNMonthControlNoDefaultFunction
extension NNCalendarPreset.Regular99.Model: NNMonthControlNoDefaultFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
    return monthSectionModel.currentMonthReceiver
  }
}

// MARK: - NNMonthControlNoDefaultModelFunction
extension NNCalendarPreset.Regular99.Model: NNMonthControlNoDefaultModelFunction {
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

// MARK: - NNSelectHighlightNoDefaultFunction
extension NNCalendarPreset.Regular99.Model: NNSelectHighlightNoDefaultFunction {
  public func highlightPart(_ date: Date) -> NNCalendarLogic.HighlightPart {
    return monthSectionModel.highlightPart(date)
  }
}

// MARK: - NNMonthHeaderNoDefaultModelFunction
extension NNCalendarPreset.Regular99.Model: NNMonthHeaderDefaultModelFunction {
  public func formatMonthDescription(_ month: NNCalendarLogic.Month) -> String {
    return monthHeaderModel.formatMonthDescription(month)
  }
}

// MARK: - NNMultiDaySelectionNoDefaultFunction
extension NNCalendarPreset.Regular99.Model: NNMultiDaySelectionNoDefaultFunction {
  public var allSelectionReceiver: AnyObserver<Set<NNCalendarLogic.Selection>> {
    return monthSectionModel.allSelectionReceiver
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendarLogic.Selection>>> {
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
  public func dayFromFirstDate(_ month: NNCalendarLogic.Month,
                               _ firstDateOffset: Int) -> NNCalendarLogic.Day? {
    return monthSectionModel.dayFromFirstDate(month, firstDateOffset)
  }
}

// MARK: - NNRegular99CalendarModelType
extension NNCalendarPreset.Regular99.Model: NNRegular99CalendarModelType {}
