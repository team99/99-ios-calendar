//
//  Entry.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// This is the entry point to all features, and acts as a namespace to the
/// underlying logic.
public final class NNCalendar {

  /// Represents views that are aware of the current month.
  public final class MonthAware {}

  /// Represents views that can control months.
  public final class MonthControl {}

  /// Represents the month header display view.
  public final class MonthHeader {}

  /// A month grid is a view that displays the days of a month in a grid-like
  /// structure. For e.g., a convential grid has 7 columns corresponding to 7
  /// days in a week, and 6 rows to contain all days in a month, for a total of
  /// 42 cells.
  public final class MonthGrid {}

  /// Represents the month display view.
  public final class MonthDisplay {}

  /// Represents the month section view.
  public final class MonthSection {}

  /// Represents date calculators.
  public final class DateCalculator {}

  /// Represents day selection views.
  public final class DaySelection {}

  /// Represents views that are weekday-aware, such as the weekday view and
  /// month-grid based views.
  public final class WeekdayAware {}

  /// Represents a view that displays week days.
  public final class WeekdayView {}
}
