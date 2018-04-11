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

// MARK: - monthComponent.
public extension NNCalendar {

  /// Represents components that can be controlled by the user.
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

    public var description: String {
      return date.description
    }

    public static func ==(_ lhs: Day, _ rhs: Day) -> Bool {
      return lhs.date == rhs.date
    }
  }
}

// MARK: - Months.
public extension NNCalendar {

  /// Represents a container for months that can be used to display on the
  /// month section view.
  public struct Month: Equatable, CustomStringConvertible {
    public let dayCount: Int
    public let monthComponent: MonthComp

    public var month: Int {
      return monthComponent.month
    }

    public var year: Int {
      return monthComponent.year
    }

    public var description: String {
      return monthComponent.description
    }

    public init(_ monthComponent: MonthComp, _ dayCount: Int) {
      self.monthComponent = monthComponent
      self.dayCount = dayCount
    }

    public static func ==(_ lhs: Month, _ rhs: Month) -> Bool {
      return lhs.monthComponent == rhs.monthComponent
    }
  }
}
