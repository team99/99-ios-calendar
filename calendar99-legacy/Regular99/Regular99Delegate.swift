//
//  Regular99Delegate.swift
//  calendar99-legacy
//
//  Created by Hai Pham on 24/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP
import calendar99_logic
import calendar99_presetLogic
import calendar99_preset

/// Defaultable delegate for Regular99 calendar.
public protocol NNRegular99CalendarDefaultDelegate: class {

  /// Get the first weekday.
  ///
  /// - Parameter calendar: A NNRegular99Calendar instance.
  /// - Returns: An Int value.
  func firstWeekday(for calendar: NNRegular99Calendar) -> Int

  /// Get the description for a weekday.
  ///
  /// - Parameters:
  ///   - calendar: A NNRegular99Calendar instance.
  ///   - weekday: A weekday value.
  /// - Returns: A String value.
  func regular99(_ calendar: NNRegular99Calendar,
                 weekdayDescriptionFor weekday: Int) -> String

  /// Get the weekday stack count.
  ///
  /// - Parameter calendar: A NNRegular99Calendar instance.
  /// - Returns: An Int value.
  func weekdayStacks(for calendar: NNRegular99Calendar) -> Int

  /// Get the description for a month.
  ///
  /// - Parameters:
  ///   - calendar: A NNRegular99Calendar instance.
  ///   - month: A Month instance.
  /// - Returns: A String value.
  func regular99(_ calendar: NNRegular99Calendar,
                 monthDescriptionFor month: NNCalendarLogic.Month) -> String

  /// Calculate grid selection changes when the selection changes.
  ///
  /// - Parameters:
  ///   - calendar: A NNRegular99Calendar instance.
  ///   - months: An Array of MonthComp.
  ///   - month: A Month instance.
  ///   - prev: The previous selections.
  ///   - current: The current selections.
  /// - Returns: A Set of GridPosition.
  func regular99(_ calendar: NNRegular99Calendar,
                 gridSelectionChangesFor months: [NNCalendarLogic.MonthComp],
                 whileCurrentMonthIs month: NNCalendarLogic.Month,
                 withPreviousSelection prev: Set<NNCalendarLogic.Selection>,
                 andCurrentSelection current: Set<NNCalendarLogic.Selection>)
    -> Set<NNCalendarLogic.GridPosition>

  /// Check if a Date is selected.
  ///
  /// - Parameters:
  ///   - calendar: A NNRegular99Calendar instance.
  ///   - date: A Date instance.
  /// - Returns: A Bool value.
  func regular99(_ calendar: NNRegular99Calendar,
                 isDateSelected date: Date) -> Bool

  /// Get the current month.
  ///
  /// - Parameter calendar: A NNRegular99Calendar instance.
  /// - Returns: A Month instance.
  func currentMonth(for calendar: NNRegular99Calendar) -> NNCalendarLogic.Month?

  /// Get the current selection set.
  ///
  /// - Parameter calendar: A NNRegular99Calendar instance.
  /// - Returns: A Set of Selection.
  func currentSelections(for calendar: NNRegular99Calendar) -> Set<NNCalendarLogic.Selection>?

  /// Calculate highlight part for a Date.
  ///
  /// - Parameters:
  ///   - calendar: A NNRegular99Calendar instance.
  ///   - date: A Date instance.
  /// - Returns: A HighlightPart instance.
  func regular99(_ calendar: NNRegular99Calendar,
                 highlightPartFor date: Date) -> NNCalendarLogic.HighlightPart
}

/// Non-defaultable delegate for Regular99 calendar.
public protocol NNRegular99CalendarNoDefaultDelegate: class {

  /// Get the minimum month.
  ///
  /// - Parameter calendar: A NNRegular99Calendar instance.
  /// - Returns: A Month instance.
  func minimumMonth(for calendar: NNRegular99Calendar) -> NNCalendarLogic.Month

  /// Get the maximum month.
  ///
  /// - Parameter calendar: A NNRegular99Calendar instance.
  /// - Returns: A Month instance.
  func maximumMonth(for calendar: NNRegular99Calendar) -> NNCalendarLogic.Month

  /// Get the initial month.
  ///
  /// - Parameter calendar: A NNRegular99Calendar instance.
  /// - Returns: A Month instance.
  func initialMonth(for calendar: NNRegular99Calendar) -> NNCalendarLogic.Month

  /// Trigger callback when the current month changed. Ideally we should store
  /// this month externally.
  ///
  /// - Parameters:
  ///   - calendar: A NNRegular99Calendar instance.
  ///   - month: A Month instance.
  func regular99(_ calendar: NNRegular99Calendar,
                 currentMonthChanged month: NNCalendarLogic.Month)

  /// Trigger callback when the selection changes. Ideally we should store this
  /// so that we can access later.
  ///
  /// - Parameters:
  ///   - calendar: A NNRegular99Calendar instance.
  ///   - selections: A Set of Selection.
  func regular99(_ calendar: NNRegular99Calendar,
                 selectionChanged selections: Set<NNCalendarLogic.Selection>)
}

/// Delegate for Regular99 calendar.
public protocol NNRegular99CalendarDelegate:
  NNRegular99CalendarDefaultDelegate,
  NNRegular99CalendarNoDefaultDelegate {}
