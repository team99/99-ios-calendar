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
  ///   - prevSelections: A Set of Date.
  ///   - currentSelections: A Set of Date.
  /// - Returns: A Set of Date selections that were actually changed.
  internal func extractChanges(_ prevSelections: Set<Date>,
                               _ currentSelections: Set<Date>) -> Set<Date> {
    /// Since it's either the previous selections set is larger than the
    /// current selections or vice versa, so unioning these subtracted sets
    /// should give us all the changed selections.
    return prevSelections.subtracting(currentSelections)
      .union(currentSelections.subtracting(prevSelections))
  }
}

/// Calculate grid selection for date selections based on an Array of Months.
public protocol NNMultiMonthGridSelectionCalculator: NNGridSelectionCalculator {

  /// Calculate grid selection for a single date, based on a specified Month
  /// Array.
  ///
  /// - Parameters:
  ///   - monthComps: A MonthComp Array.
  ///   - selection: A Date instance.
  /// - Returns: A GridSelection Set.
  func calculateGridSelection(_ monthComps: [NNCalendar.MonthComp],
                              _ selection: Date)
    -> Set<NNCalendar.GridSelection>
}

public extension NNMultiMonthGridSelectionCalculator {

  /// Calculate grid selection changes for a specified MonthComp Array. We
  /// compare the previous and current selections to derive the changed set, on
  /// which grid selection calculations are performed.
  ///
  /// - Parameters:
  ///   - monthComps: A MonthComp Array.
  ///   - prevSelections: The previous selected dates.
  ///   - currentSelections: The current selected dates.
  /// - Returns: A Set of GridSelection.
  public func calculateGridSelectionChanges(_ monthComps: [NNCalendar.MonthComp],
                                            _ prevSelections: Set<Date>,
                                            _ currentSelections: Set<Date>)
    -> Set<NNCalendar.GridSelection>
  {
    return Set(extractChanges(prevSelections, currentSelections)
      .flatMap({calculateGridSelection(monthComps, $0)}))
  }
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
  ///   - prevSelections: The previous selected dates.
  ///   - selection: A Date instance.
  /// - Returns: A Set of GridSelection.
  func calculateGridSelection(_ monthComp: NNCalendar.MonthComp,
                              _ selection: Date)
    -> Set<NNCalendar.GridSelection>
}

public extension NNSingleMonthGridSelectionCalculator {

  /// The logic here is similar to the normal grid selection changes calculator.
  ///
  /// - Parameters:
  ///   - monthComp: A MonthComp instance.
  ///   - prevSelections: The previous selected dates.
  ///   - currentSelections: The current selected dates.
  /// - Returns: A Set of GridSelection.
  func calculateGridSelectionChanges(_ monthComp: NNCalendar.MonthComp,
                                     _ prevSelections: Set<Date>,
                                     _ currentSelections: Set<Date>)
    -> Set<NNCalendar.GridSelection>
  {
    return Set(extractChanges(prevSelections, currentSelections)
      .flatMap({calculateGridSelection(monthComp, $0)}))
  }
}

/// Classes that implement this protocol should be able to calculate highlight
/// parts for date selections.
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
