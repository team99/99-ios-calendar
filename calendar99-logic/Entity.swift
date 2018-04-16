//
//  Entity.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Represents calendar movements for month selection.
///
/// - forward: Go forward by some months.
/// - backward: Go backward by some months.
internal enum MonthDirection {
  case forward(UInt)
  case backward(UInt)

  /// Get the offset from current month. Beware that the offset for backward
  /// is a negative number.
  var monthOffset: Int {
    switch self {
    case .forward(let offset): return Int(offset)
    case .backward(let offset): return -Int(offset)
    }
  }
}

// MARK: - DaySelectionIndex.
public extension NNCalendar {

  /// Represents a month-grid selection. A GridSelection comprises the month
  /// index (with which we can identify the particular Month in question in
  /// a Month Array) and the day index (i.e. the index of the Date in a Month).
  /// This is essentially an IndexPath, but since we cannot include UIKit in
  /// logic code, we have this to replace.
  public struct GridSelection: Equatable, Hashable {
    public let monthIndex: Int
    public let dayIndex: Int

    /// [Hashcode Algorithm]: https://stackoverflow.com/questions/263400/what-is-the-best-algorithm-for-an-overridden-system-object-gethashcode
    public var hashValue: Int {
      var hash = 17
      hash = hash * 29 + monthIndex.hashValue
      hash = hash * 29 + dayIndex.hashValue
      return hash
    }

    public init(_ monthIndex: Int, _ dayIndex: Int) {
      self.monthIndex = monthIndex
      self.dayIndex = dayIndex
    }

    public static func ==(_ lhs: GridSelection, _ rhs: GridSelection) -> Bool {
      return lhs.monthIndex == rhs.monthIndex && lhs.dayIndex == rhs.dayIndex
    }
  }
}

// MARK: - Month.
public extension NNCalendar {

  /// Represents a month that can be controlled by the user. This is used
  /// throughout the library, esp. by the month header (whereby there are
  // forward and backward arrows to control the currently selected month).
  public struct Month: Equatable {
    public let month: Int
    public let year: Int

    /// [Hashcode Algorithm]: https://stackoverflow.com/questions/263400/what-is-the-best-algorithm-for-an-overridden-system-object-gethashcode
    public var hashValue: Int {
      var hash = 17
      hash = hash * 29 + month.hashValue
      hash = hash * 29 + year.hashValue
      return hash
    }

    public init(_ month: Int, _ year: Int) {
      self.month = month
      self.year = year
    }

    public init(_ date: Date) {
      let calendar = Calendar.current
      let monthValue = calendar.component(.month, from: date)
      let yearValue = calendar.component(.year, from: date)
      self.init(monthValue, yearValue)
    }

    public func dateComponents() -> DateComponents {
      var components = DateComponents()
      components.setValue(month, for: .month)
      components.setValue(year, for: .year)
      return components
    }

    /// Check if the current month contains a Date.
    ///
    /// - Parameter date: A Date instance.
    /// - Returns: A Bool value.
    public func contains(_ date: Date) -> Bool {
      let calendar = Calendar.current
      let monthValue = calendar.component(.month, from: date)
      let yearValue = calendar.component(.year, from: date)
      return self.month == monthValue && self.year == yearValue
    }

    /// Get the month that is some month offsets away from the current month.
    ///
    /// - Parameter monthOffset: An Int value.
    /// - Returns: A Month instance.
    public func with(monthOffset: Int) -> Month? {
      let calendar = Calendar.current
      let components = dateComponents()
      var componentOffset = DateComponents()
      componentOffset.setValue(monthOffset, for: .month)

      return calendar.date(from: components)
        .flatMap({calendar.date(byAdding: componentOffset, to: $0)})
        .flatMap({(
          calendar.component(.month, from: $0),
          calendar.component(.year, from: $0
        ))})
        .map({NNCalendar.Month($0, $1)})
    }

    /// Get the difference between the current month and a specified month in
    /// terms of month.
    ///
    /// - Parameter month: A Month instance.
    /// - Returns: An Int value.
    public func monthOffset(from month: Month) -> Int {
      return (year - month.year) * 12 + (self.month - month.month)
    }

    /// Get all Dates with a particular weekday that lies within this month
    /// component.
    ///
    /// - Parameter weekday: A weekday value.
    /// - Returns: A Set of Date.
    public func datesWithWeekday(_ weekday: Int) -> Set<Date> {
      let calendar = Calendar.current
      let dateComponents = self.dateComponents()

      return calendar.date(from: dateComponents)
        .flatMap({date -> Date? in
          let firstDateWeekday = calendar.component(.weekday, from: date)
          let dateOffset: Int

          if firstDateWeekday > weekday {
            dateOffset = 7 - (firstDateWeekday - weekday)
          } else {
            dateOffset = weekday - firstDateWeekday
          }

          // Need to find the first day in a month that has the specified
          // weekday.
          return calendar.date(byAdding: .day, value: dateOffset, to: date)
        })
        .map({(date: Date) -> Set<Date> in
          var results = Set<Date>()
          var currentDate = date

          // Only consider dates that lie within this month. As soon as the
          // current date gets out of range, skip it.
          while contains(currentDate) {
            results.insert(currentDate)

            guard let newCurrentDate =
              calendar.date(byAdding: .day, value: 7, to: currentDate) else
            {
              break
            }

            currentDate = newCurrentDate
          }

          return results
        })
        .getOrElse([])
    }

    public static func ==(_ lhs: Month, _ rhs: Month) -> Bool {
      return lhs.month == rhs.month && lhs.year == rhs.year
    }
  }
}

// MARK: - Days.
public extension NNCalendar {

  /// Represents a container for dates that can be used to display on the month
  /// view and month section view.
  public struct Day: Equatable {
    public let date: Date
    public let dateDescription: String

    /// The "currentMonth" in this case does not refer to the actual current
    /// month, but the currently selected month. This property can be used to
    /// de-highlight cells with dates that do not lie within the selected month.
    public let isCurrentMonth: Bool
    public let isSelected: Bool

    /// Check if this Day is today.
    public var isToday: Bool {
      let calendar = Calendar.current
      let calendarComponents: Set<Calendar.Component> = [.day, .month, .year]
      let components = calendar.dateComponents(calendarComponents, from: date)
      let todayComps = calendar.dateComponents(calendarComponents, from: Date())
      return components == todayComps
    }

    public init(_ date: Date,
                _ dateDescription: String,
                _ isCurrentMonth: Bool,
                _ isSelected: Bool) {
      self.date = date
      self.dateDescription = dateDescription
      self.isCurrentMonth = isCurrentMonth
      self.isSelected = isSelected
    }

    /// Copy the current Day, but change its selection status.
    ///
    /// - Parameter selected: A Bool value.
    /// - Returns: A Day instance.
    public func with(selected: Bool) -> Day {
      return Day(date, dateDescription, isCurrentMonth, selected)
    }

    /// Toggle selection status.
    public func toggleSelection() -> Day {
      return with(selected: !isSelected)
    }

    public static func ==(_ lhs: Day, _ rhs: Day) -> Bool {
      return lhs.date == rhs.date
        && lhs.isSelected == rhs.isSelected
        && lhs.isCurrentMonth == rhs.isCurrentMonth
        && lhs.dateDescription == rhs.dateDescription
    }
  }
}

/// Weekdays.
public extension NNCalendar {

  /// Represents a weekday.
  public struct Weekday: Equatable, CustomStringConvertible {
    public let weekday: Int
    public let description: String

    public init(_ weekday: Int, _ description: String) {
      self.weekday = weekday
      self.description = description
    }

    public static func ==(_ lhs: Weekday, _ rhs: Weekday) -> Bool {
      return lhs.weekday == rhs.weekday && lhs.description == rhs.description
    }
  }
}

// MARK: - Months.
public extension NNCalendar {

  /// Represents a container for months that can be used to display on the month
  /// section view. Each month component will have a number of Days (generally
  /// 42), but we calculate Days lazily when they are requested, instead of
  /// upfront, in order to minimize storage esp. when we have a large number
  /// of Months to display.
  public struct MonthComp: Equatable {
    public let dayCount: Int
    public let month: Month

    public init(_ month: Month, _ dayCount: Int) {
      self.month = month
      self.dayCount = dayCount
    }

    /// Clone the current Month but change the month component.
    public func with(month: Month) -> MonthComp {
      return MonthComp(month, dayCount)
    }

    public static func ==(_ lhs: MonthComp, _ rhs: MonthComp) -> Bool {
      return lhs.month == rhs.month && lhs.dayCount == rhs.dayCount
    }
  }
}

// MARK: - Highlight position flags.
public extension NNCalendar {

  /// Use this to perform custom selection highlights when selecting dates.
  public struct HighlightPosition: OptionSet {

    /// Mark the start of an Array of Date selection.
    public static let start = HighlightPosition(rawValue: 0)

    /// Mark the middle of an Array of Date selection.
    public static let mid: HighlightPosition = HighlightPosition(rawValue: 1)

    /// Mark the end of an Array of Date selection.
    public static let end = HighlightPosition(rawValue: 2)
    public static let startAndEnd: HighlightPosition = [start, end]
    public static let none = HighlightPosition(rawValue: 0)

    public typealias RawValue = Int

    public let rawValue: RawValue

    public init(rawValue: RawValue) {
      self.rawValue = rawValue
    }
  }
}
