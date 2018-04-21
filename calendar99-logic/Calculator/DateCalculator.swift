//
//  DateCalc.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

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

  /// Calculate grid position changes for a specified MonthComp Array. We compare
  /// the previous and current selections to derive the changed set, on which
  /// grid selection calculations are performed. The changes should be relevant
  /// only to the currently active Month.
  ///
  /// - Parameters:
  ///   - monthComps: A MonthComp Array.
  ///   - currentMonth: The currently active Month.
  ///   - prev: The previous selections.
  ///   - current: The current selections.
  /// - Returns: A GridPosition Set.
  func gridSelectionChanges(_ monthComps: [NNCalendar.MonthComp],
                            _ currentMonth: NNCalendar.Month,
                            _ prev: Set<NNCalendar.Selection>,
                            _ current: Set<NNCalendar.Selection>)
    -> Set<NNCalendar.GridPosition>
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
  /// - Returns: A Set of GridPosition.
  func gridSelectionChanges(_ monthComp: NNCalendar.MonthComp,
                            _ prev: Set<NNCalendar.Selection>,
                            _ current: Set<NNCalendar.Selection>)
    -> Set<NNCalendar.GridPosition>
}
