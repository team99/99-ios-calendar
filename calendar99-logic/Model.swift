//
//  Model.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for calendar model.
public protocol Calendar99ModelDependency: Calendar99FunctionalityType {

  /// Stream the current selected month.
  var monthStream: Observable<Int> { get }

  /// Receive the current month.
  var monthReceiver: AnyObserver<Int> { get }

  /// Stream the current selected year.
  var yearStream: Observable<Int> { get }

  /// Receive the current year.
  var yearReceiver: AnyObserver<Int> { get }
}

/// Factory for model dependency.
public protocol Calendar99ModelDependencyFactory {

  /// Create a model dependency.
  ///
  /// - Returns: A Calendar99ModelDependency instance.
  func calendarModelDependency() -> Calendar99ModelDependency
}

/// Model for calendar. This handles API calls.
public protocol Calendar99ModelType: Calendar99ModelDependency {

  /// Calculate a new month and year based on a month offset.
  ///
  /// - Parameters:
  ///   - prevMonth: The previous month.
  ///   - prevYear: The previous year.
  ///   - monthOffset: A month offset value.
  /// - Returns: A tuple of month and year.
  func newMonthAndYear(_ prevMonth: Int,
                       _ prevYear: Int,
                       _ monthOffset: Int) -> (month: Int, year: Int)?
}

public extension Calendar99.Main {

  /// Model implementation.
  public final class Model: Calendar99ModelType {
    fileprivate let dependency: Calendar99ModelDependency

    public var monthStream: Observable<Int> {
      return dependency.monthStream
    }

    public var monthReceiver: AnyObserver<Int> {
      return dependency.monthReceiver
    }

    public var yearStream: Observable<Int> {
      return dependency.yearStream
    }

    public var yearReceiver: AnyObserver<Int> {
      return dependency.yearReceiver
    }

    public init(_ dependency: Calendar99ModelDependency) {
      self.dependency = dependency
    }

    public func newMonthAndYear(_ prevMonth: Int,
                                _ prevYear: Int,
                                _ monthOffset: Int) -> (month: Int, year: Int)? {
      return Calendar99.DateUtil.newMonthAndYear(prevMonth, prevYear, monthOffset)
    }
  }
}
