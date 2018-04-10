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

// MARK: - Components.
public extension Calendar99 {

  /// Represents components that can be controlled by the user.
  public struct Components: Equatable, CustomStringConvertible {
    public let month: Int
    public let year: Int

    public var description: String {
      return "month: \(month), year: \(year)"
    }

    public init(month: Int, year: Int) {
      self.month = month
      self.year = year
    }

    public static func ==(_ lhs: Components, _ rhs: Components) -> Bool {
      return lhs.month == rhs.month && lhs.year == rhs.year
    }
  }
}

// MARK: - Days.
public extension Calendar99 {

  /// Represents a container for dates that can be used to display on the month
  /// view.
  public struct Day: Equatable, CustomStringConvertible {
    public let date: Date

    public var description: String {
      return date.description
    }

    public init(date: Date) {
      self.date = date
    }

    public static func ==(_ lhs: Day, _ rhs: Day) -> Bool {
      return lhs.date == rhs.date
    }
  }
}
