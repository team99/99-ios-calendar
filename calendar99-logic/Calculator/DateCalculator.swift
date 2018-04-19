//
//  DateCalc.swift
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
  /// - Parameters month: A Month instance.
  /// - Returns: An Array of Date.
  func calculateDateRange(_ month: NNCalendar.Month) -> [Date]
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
  ///   - month: A Month instance.
  ///   - firstDateOffset: The offset from the first date in the grid.
  /// - Returns: A Date instance.
  func calculateDateWithOffset(_ month: NNCalendar.Month,
                               _ firstDateOffset: Int) -> Date?
}

/// Represents a grid selection calculator.
public protocol NNGridSelectionCalculator {}

public extension NNGridSelectionCalculator {

  /// Extract actual changes between the previous selections and the current
  /// selections.
  ///
  /// - Parameters:
  ///   - prevSelections: A Set of selections.
  ///   - currentSelections: A Set of selections.
  /// - Returns: A Set of selections that were actually changed.
  func extractChanges(_ prevSelections: Set<NNCalendar.Selection>,
                      _ currentSelections: Set<NNCalendar.Selection>)
    -> Set<NNCalendar.Selection>
  {
    /// Since it's either the previous selections set is larger than the
    /// current selections or vice versa, so unioning these subtracted sets
    /// should give us all the changed selections.
    return prevSelections.subtracting(currentSelections)
      .union(currentSelections.subtracting(prevSelections))
  }
}

/// Calculate grid selection for date selections based on an Array of Months.
public protocol NNMultiMonthGridSelectionCalculator: NNGridSelectionCalculator {

  /// Calculate grid selection changes for a specified MonthComp Array. We
  /// compare the previous and current selections to derive the changed set, on
  /// which grid selection calculations are performed.
  ///
  /// - Parameters:
  ///   - monthComps: A MonthComp Array.
  ///   - prev: The previous selections.
  ///   - current: The current selections.
  /// - Returns: A GridSelection Set.
  func calculateGridSelectionChanges(_ monthComps: [NNCalendar.MonthComp],
                                     _ prev: Set<NNCalendar.Selection>,
                                     _ current: Set<NNCalendar.Selection>)
    -> Set<NNCalendar.GridSelection>
}

/// The functionality of this calculator is almost the same as the one above,
/// but now we only have a Month.
public protocol NNSingleMonthGridSelectionCalculator: NNGridSelectionCalculator {

  /// Instead of having an Array of Months, we now have only one month, so we
  /// need to create an Array of Months from this one Month if necessary. (For
  /// e.g. we may include the previous and next Months in the Array so we can
  /// calculate all possible grid selections).
  ///
  /// - Parameters:
  ///   - monthComp: A MonthComp instance.
  ///   - prev: The previous selections.
  ///   - current: The current selections.
  /// - Returns: A Set of GridSelection.
  func calculateGridSelectionChanges(_ monthComp: NNCalendar.MonthComp,
                                     _ prev: Set<NNCalendar.Selection>,
                                     _ current: Set<NNCalendar.Selection>)
    -> Set<NNCalendar.GridSelection>
}

/// Classes that implement this protocol should be able to calculate highlight
/// parts for date selections. A HighlightPart contains information regarding
/// the position of the selected Date in a set of Date selection, and is mainly
/// used to custom-draw highlights for the cell containing said Date.
public protocol NNHighlightPartCalculator {

  /// Calculate highlight part for a selected Date.
  ///
  /// - Parameters:
  ///   - selections: A Set of selected Date.
  ///   - currentDate: The current selected Date.
  /// - Returns: A HighlightPart instance.
  func calculateHighlightPart(_ selections: Set<Date>, _ currentDate: Date)
    -> NNCalendar.HighlightPart
}
