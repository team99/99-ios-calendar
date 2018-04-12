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

  /// Represents a month-grid selection.
  public typealias GridSelection = (monthIndex: Int, dayIndex: Int)
}

// MARK: - MonthComp.
public extension NNCalendar {

  /// Represents a month-based component that can be controlled by the user.
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

// MARK: - Months.
public extension NNCalendar {

  /// Represents a container for months that can be used to display on the
  /// month section view.
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

    public static func ==(_ lhs: Month, _ rhs: Month) -> Bool {
      return lhs.monthComp == rhs.monthComp && lhs.dayCount == rhs.dayCount
    }
  }
}
