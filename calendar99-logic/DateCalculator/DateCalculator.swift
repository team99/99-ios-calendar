//
//  DateCalculator.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Calculate dates within a specific month/year. Classes that implement this
/// protocol should be able to customize the date array using column/row count.
/// For example, a normal calendar would have its weekday view on top, but on
/// the off chance that we want said view to be vertical, we can simply provide
/// a different date calculator implementation.
public protocol NNDateCalculatorType {

  /// Calculate the dates in a month/year pair. The total number of dates should
  /// equal rowCount * columnCount, but how exactly they should be partitioned
  /// is left to implementation.
  ///
  /// - Parameters:
  ///   - components: A Components instance.
  ///   - firstDayOfWeek: The first day of a week (e.g. Monday).
  ///   - rowCount: The number of rows in a calendar grid.
  ///   - columnCount: The number of columns in a calendar grid.
  /// - Returns: An Array of Date.
  func calculateDateRange(_ comps: NNCalendar.MonthComp,
                          _ firstDayOfWeek: Int,
                          _ rowCount: Int,
                          _ columnCount: Int) -> [Date]
}

/// This is similar to the date calculator, but it calculates only single dates
/// based on an offset.
public protocol NNSingleDateCalculatorType {

  /// Calculate the date in a month/year pair using an offset from the first
  /// date in the grid. This is similar to the date calculator, but instead of
  /// calculating the whole date range, we calculate only single dates in order
  /// to minimize the memory footprint that comes with storing all the dates.
  ///
  /// - Parameters:
  ///   - components: A Components instance.
  ///   - firstDayOfWeek: The first day of a week (e.g. Monday).
  ///   - firstDateOffset: The offset from the first date in the grid.
  /// - Returns: A Date instance.
  func calculateDateWithOffset(_ comps: NNCalendar.MonthComp,
                               _ firstDayOfWeek: Int,
                               _ firstDateOffset: Int) -> Date?
}

/// Calculate grid selection for date selections based on an Array of Months.
public protocol NNGridSelectionCalculatorType {

  /// Calculate grid selection for a single date, based on a specified Month
  /// Array.
  ///
  /// - Parameters:
  ///   - months: A Month Array.
  ///   - firstDayOfWeek: The first day of the week (e.g. Monday).
  ///   - selection: A Date instance.
  /// - Returns: A GridSelection Array.
  func calculateGridSelection(_ months: [NNCalendar.Month],
                              _ firstDayOfWeek: Int,
                              _ selection: Date)
    -> [NNCalendar.GridSelection]
}

public extension NNGridSelectionCalculatorType {

  /// Calculate grid selections for selected dates, based on a specified Month
  /// Array. These indexes can then be used to reload the relevant calendar
  /// view right where selections changed.
  ///
  /// - Parameters:
  ///   - months: A Month Array.
  ///   - firstDayOfWeek: The first day of the week (e.g. Monday).
  ///   - prevSelections: The previous selected dates.
  ///   - currentSelections: The current selected dates.
  /// - Returns: An Array of GridSelection.
  public func calculateGridSelection(_ months: [NNCalendar.Month],
                                     _ firstDayOfWeek: Int,
                                     _ prevSelections: Set<Date>,
                                     _ currentSelections: Set<Date>)
    -> [NNCalendar.GridSelection]
  {
    /// Since it's either the previous selections set is larger than the
    /// current selections or vice versa, so unioning these subtracted sets
    /// should give us all the changed selections.
    return prevSelections.subtracting(currentSelections)
      .union(currentSelections.subtracting(prevSelections))
      .flatMap({calculateGridSelection(months, firstDayOfWeek, $0)})
  }
}

/// The functionality of this calculator is almost the same as the one above,
/// but now we only have a Month.
public protocol NNSingleMonthGridSelectionCalculatorType {

  /// Instead of having an Array of Months, we now have only one month, so we
  /// need to create an Array of Months from this one Month if necessary. (For
  /// e.g. we may include the previous and next Months in the Array so we can
  /// calculate all possible grid selections).
  ///
  /// - Parameters:
  ///   - month: A Month instance.
  ///   - firstDayOfWeek: The first day of the week (e.g. Monday).
  ///   - prevSelections: The previous selected dates.
  ///   - selection: A Date instance.
  func calculateGridSelection(_ month: NNCalendar.Month,
                              _ firstDayOfWeek: Int,
                              _ selection: Date)
    -> [NNCalendar.GridSelection]
}

public extension NNSingleMonthGridSelectionCalculatorType {

  /// The logic here is similar to the normal grid selection calculator.
  ///
  /// - Parameters:
  ///   - month: A Month instance.
  ///   - firstDayOfWeek: The first day of the week (e.g. Monday).
  ///   - prevSelections: The previous selected dates.
  ///   - currentSelections: The current selected dates.
  func calculateGridSelection(_ month: NNCalendar.Month,
                              _ firstDayOfWeek: Int,
                              _ prevSelections: Set<Date>,
                              _ currentSelections: Set<Date>)
    -> [NNCalendar.GridSelection]
  {
    return prevSelections.subtracting(currentSelections)
      .union(currentSelections.subtracting(prevSelections))
      .flatMap({calculateGridSelection(month, firstDayOfWeek, $0)})
  }
}
