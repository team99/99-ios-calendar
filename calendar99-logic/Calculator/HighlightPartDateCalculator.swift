//
//  HighlightPartDateCalculator.swift
//  calendar99-logic
//
//  Created by Hai Pham on 17/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

// MARK: - HighlightPartDateCalculator
public extension NNCalendar.DateCalc {

  /// This calculator is used specifically to cater to highlight parts. If we
  /// use a normal grid selection changes calculator, when the user selects or
  /// deselects a Date, only the grid selection corresponding to that Date will
  /// be refreshed. This is not ideal if we wish to reflect accurately its
  /// highlights, because for e.g. the date is deselected, leading to a
  /// contiuous string of selection being split in 2, as follows:
  /// 1/4/2018 - 2/4/2018 - 3/4/2018
  /// Then 2/4/2018 is deselected, we now have:
  /// 1/4/2018 - 3/4/2018
  /// Both 1/4/2018 and 3/4/2018 now have .startAndEnd highlight parts (whereby
  /// they had .start and .end respectively before), but since only 2/4/2018
  /// is refreshed, the change is not reflected for these 2 dates. We need to
  /// include in the set of grid selection changes the selections for these
  /// dates as well.
  public final class HighlightPart {
    fileprivate let gridSelectionCalculator: NNMultiMonthGridSelectionCalculator
    fileprivate let rowCount: Int
    fileprivate let columnCount: Int

    public init(_ gridSelectionCalc: NNMultiMonthGridSelectionCalculator,
                _ rowCount: Int,
                _ columnCount: Int) {
      self.gridSelectionCalculator = gridSelectionCalc
      self.rowCount = rowCount
      self.columnCount = columnCount
    }
  }
}

// MARK: - NNGridSelectionCalculator
extension NNCalendar.DateCalc.HighlightPart: NNMultiMonthGridSelectionCalculator {

  /// We include the previous and next selection for each grid selection so
  /// that they are refreshed too (rationale for this can be found above).
  public func calculateGridSelectionChanges(_ monthComps: [NNCalendar.MonthComp],
                                            _ prev: Set<NNCalendar.Selection>,
                                            _ current: Set<NNCalendar.Selection>)
    -> Set<NNCalendar.GridSelection>
  {
    let totalDayCount = rowCount * columnCount

    // We could have checked whether the previous/next grid selections have
    // associated dates which are selected (instead of just incrementing/
    // decrementing the day index) but that seems more trouble that it's worth.
    return Set(gridSelectionCalculator
      .calculateGridSelectionChanges(monthComps, prev, current)
      .map({[$0.decrementingDayIndex(), $0, $0.incrementingDayIndex()]})
      .flatMap({$0.filter({$0.dayIndex >= 0 && $0.dayIndex < totalDayCount})}))
  }
}
