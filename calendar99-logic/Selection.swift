//
//  Selection.swift
//  calendar99-logic
//
//  Created by Hai Pham on 19/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

// MARK: - Selection.
extension NNCalendar {

  /// Represents a Selection object that determines whether a Date is selected.
  /// We use this Selection object instead of storing the Date directly because
  /// it provides us with the means to create custom selection logic, such as
  /// periodic (weekly/monthly) repetitions, simple selection etc. This is a
  /// concrete class instead of a protocol because some of the protocols it
  /// conforms to requires Self.
  ///
  /// To use this class, we must override all methods that are marked as "open"
  /// below.
  open class Selection: Equatable, Hashable {
    open var hashValue: Int {
      return 0
    }

    /// Override this to cheat Equatable. This approach is similar to NSObject's
    /// isEqual.
    ///
    /// - Parameter selection: A Selection instance.
    /// - Returns: A Bool value.
    open func isSameAs(_ selection: Selection) -> Bool {
      return true
    }

    /// Each Selection implementation will have a different mechanism for
    /// determining whether a date is selected. For e.g. the DateSelection
    /// subclass checks selection status by comparing the input Date against
    /// the stored Date, while the RepeatWeekdaySelection may do so by verifying
    /// the Date's weekday to see if it matches the stored weekday.
    ///
    /// - Parameter date: A Date instance.
    /// - Returns: A Bool value.
    open func contains(_ date: Date) -> Bool {
      return false
    }

    /// Calculate the associated grid selection in an Array of Month Components.
    /// Consult the documentation for NNGridSelectionCalculator and its subtypes
    /// to understand the purpose of this method.
    ///
    /// - Parameter monthComps: A MonthComp Array.
    /// - Returns: A Set of GridPosition.
    open func calculateGridPosition(_ monthComps: [NNCalendar.MonthComp])
      -> Set<NNCalendar.GridPosition>
    {
      return []
    }

    public static func ==(_ lhs: Selection, _ rhs: Selection) -> Bool {
      return lhs.isSameAs(rhs)
    }
  }
}

// MARK: - Date Selection.
public extension NNCalendar {

  /// Store a Date and compare it against the input Date.
  public final class DateSelection: Selection {
    override public var hashValue: Int {
      return date.hashValue
    }

    public let date: Date
    private let firstWeekday: Int

    public init(_ date: Date, _ firstWeekday: Int) {
      self.date = date
      self.firstWeekday = firstWeekday
    }

    override public func isSameAs(_ selection: NNCalendar.Selection) -> Bool {
      guard let selection = selection as? DateSelection else { return false }
      return selection.date == date
    }

    override public func contains(_ date: Date) -> Bool {
      return self.date == date
    }

    override public func calculateGridPosition(_ monthComps: [NNCalendar.MonthComp])
      -> Set<NNCalendar.GridPosition>
    {
      let month = NNCalendar.Month(date)

      return monthComps.enumerated()
        .first(where: {$0.1.month == month})
        .map({(offset: Int, month: NNCalendar.MonthComp) in
          calculateGridPosition(monthComps, month, offset, date)
        })
        .getOrElse([])
    }

    /// Since each Date may be included in different months (e.g., if there are
    /// more than 31 cells, the calendar view may include dates from previous/
    /// next months). To be safe, we calculate the selection for one month before
    /// and after the specified month.
    fileprivate func calculateGridPosition(_ monthComps: [NNCalendar.MonthComp],
                                           _ monthComp: NNCalendar.MonthComp,
                                           _ monthIndex: Int,
                                           _ selection: Date)
      -> Set<NNCalendar.GridPosition>
    {
      let calendar = Calendar.current

      let calculate = {(month: NNCalendar.MonthComp, offset: Int)
        -> NNCalendar.GridPosition? in
        if let fDate = Util.calculateFirstDate(month.month, self.firstWeekday) {
          let diff = calendar.dateComponents([.day], from: fDate, to: selection)

          if let dayDiff = diff.day, dayDiff >= 0 && dayDiff < month.dayCount {
            return NNCalendar.GridPosition(offset, dayDiff)
          }
        }

        return Optional.none
      }

      var gridPositions = Set<NNCalendar.GridPosition>()
      _ = calculate(monthComp, monthIndex).map({gridPositions.insert($0)})
      let prevMonthIndex = monthIndex - 1
      let nextMonthIndex = monthIndex + 1

      if prevMonthIndex >= 0 && prevMonthIndex < monthComps.count {
        let prevMonth = monthComps[prevMonthIndex]
        _ = calculate(prevMonth, prevMonthIndex).map({gridPositions.insert($0)})
      }

      if nextMonthIndex >= 0 && nextMonthIndex < monthComps.count {
        let nextMonth = monthComps[nextMonthIndex]
        _ = calculate(nextMonth, nextMonthIndex).map({gridPositions.insert($0)})
      }

      return gridPositions
    }
  }
}
