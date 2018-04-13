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
  public struct GridSelection: Equatable, Hashable, CustomStringConvertible {
    public let monthIndex: Int
    public let dayIndex: Int

    public var description: String {
      return "month index: \(monthIndex) - day index: \(dayIndex)"
    }

    /// [Hashcode Algorithm]: https://stackoverflow.com/questions/263400/what-is-the-best-algorithm-for-an-overridden-system-object-gethashcode
    public var hashValue: Int {
      var hash = 17
      hash = hash * 486187739 + monthIndex.hashValue
      hash = hash * 486187739 + dayIndex.hashValue
      return hash
    }

    public init(monthIndex: Int, dayIndex: Int) {
      self.monthIndex = monthIndex
      self.dayIndex = dayIndex
    }

    public static func ==(_ lhs: GridSelection, _ rhs: GridSelection) -> Bool {
      return lhs.monthIndex == rhs.monthIndex && lhs.dayIndex == rhs.dayIndex
    }
  }
}

// MARK: - MonthComp.
public extension NNCalendar {

  /// Represents a month-based component that can be controlled by the user.
  /// This is used throughout the library, esp. by the month header (whereby
  /// there are forward and backward arrows to control the currently selected
  /// month component).
  public struct MonthComp: Equatable, CustomStringConvertible {
    public let month: Int
    public let year: Int

    public var description: String {
      return "month: \(month), year: \(year)"
    }

    public init(month: Int, year: Int) {
      self.month = month
      self.year = year
    }

    public init(_ date: Date) {
      let calendar = Calendar.current
      let month = calendar.component(.month, from: date)
      let year = calendar.component(.year, from: date)
      self.init(month: month, year: year)
    }

    public func dateComponents() -> DateComponents {
      var components = DateComponents()
      components.setValue(month, for: .month)
      components.setValue(year, for: .year)
      return components
    }

    /// Check if the current month component contains a Date.
    ///
    /// - Parameter date: A Date instance.
    /// - Returns: A Bool value.
    public func contains(_ date: Date) -> Bool {
      let calendar = Calendar.current
      let month = calendar.component(.month, from: date)
      let year = calendar.component(.year, from: date)
      return self.month == month && self.year == year
    }

    /// Get the month component that is some month offsets away from the current
    /// component.
    ///
    /// - Parameter monthOffset: An Int value.
    /// - Returns: A MonthComp instance.
    public func with(monthOffset: Int) -> MonthComp? {
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
        .map({NNCalendar.MonthComp(month: $0, year: $1)})
    }

    /// Get the difference between the current month component and a specified
    /// month component in terms of month.
    ///
    /// - Parameter comp: A MonthComp instance.
    /// - Returns: An Int value.
    public func monthOffset(from comp: MonthComp) -> Int {
      return (year - comp.year) * 12 + (month - comp.month)
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

          // Only consider dates that lie within this month component. As soon
          // as the current date gets out of range, skip it.
          while contains(currentDate) {
            results.insert(currentDate)

            guard let newCurrentDate = calendar
              .date(byAdding: .day, value: 7, to: currentDate) else
            {
              break
            }

            currentDate = newCurrentDate
          }

          return results
        })
        .getOrElse([])
    }

    public static func ==(_ lhs: MonthComp, _ rhs: MonthComp) -> Bool {
      return lhs.month == rhs.month && lhs.year == rhs.year
    }
  }
}

// MARK: - Days.
public extension NNCalendar {

  /// Represents a container for dates that can be used to display on the month
  /// view.
  public struct Day: Equatable, CustomStringConvertible {
    public let date: Date
    public let dateDescription: String
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

    public var description: String {
      return date.description
    }

    /// Copy the current Day, but change its selection status.
    ///
    /// - Parameter selected: A Bool value.
    /// - Returns: A Day instance.
    public func with(selected: Bool) -> Day {
      return Day(date: date,
                 dateDescription: dateDescription,
                 isCurrentMonth: isCurrentMonth,
                 isSelected: selected)
    }

    /// Toggle selection status.
    public func toggleSelection() -> Day {
      return with(selected: !isSelected)
    }

    public static func ==(_ lhs: Day, _ rhs: Day) -> Bool {
      return lhs.date == rhs.date && lhs.isSelected == rhs.isSelected
    }
  }
}

/// Weekdays.
public extension NNCalendar {

  /// Represents a weekday.
  public struct Weekday: Equatable, CustomStringConvertible {
    public let dayIndex: Int
    public let description: String

    public static func ==(_ lhs: Weekday, _ rhs: Weekday) -> Bool {
      return lhs.dayIndex == rhs.dayIndex
    }
  }
}

// MARK: - Months.
public extension NNCalendar {

  /// Represents a container for months that can be used to display on the month
  /// section view. Each Month will have a number of Days (generally 42), but
  /// we calculate Days lazily when they are requested, instead of upfront, in
  /// order to minimize storage esp. when we have a large number of Months to
  /// display.
  public struct Month: Equatable, CustomStringConvertible {
    public let dayCount: Int
    public let monthComp: MonthComp

    public var month: Int {
      return monthComp.month
    }

    public var year: Int {
      return monthComp.year
    }

    public var description: String {
      return monthComp.description
    }

    public init(_ monthComponent: MonthComp, _ dayCount: Int) {
      self.monthComp = monthComponent
      self.dayCount = dayCount
    }

    /// Clone the current Month but change the month component.
    public func with(monthComp: MonthComp) -> Month {
      return Month(monthComp, dayCount)
    }

    public static func ==(_ lhs: Month, _ rhs: Month) -> Bool {
      return lhs.monthComp == rhs.monthComp && lhs.dayCount == rhs.dayCount
    }
  }
}
