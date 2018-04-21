//
//  SingleDaySelectionModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Defaultable dependency for single day selection model.
public protocol NNSingleDaySelectionDefaultModelDependency:
  NNMultiDaySelectionDefaultFunction,
  NNSingleDaySelectionDefaultFunction,
  NNWeekdayAwareDefaultModelFunction {}

/// Non-defaultable dependency for single day selection model.
public protocol NNSingleDaySelectionNoDefaultModelDependency:
  NNMultiDaySelectionNoDefaultFunction,
  NNSingleDaySelectionNoDefaultFunction,
  NNWeekdayAwareNoDefaultModelFunction {}

/// Dependency for single day selection model.
public protocol NNSingleDaySelectionModelDependency:
  NNSingleDaySelectionDefaultModelDependency,
  NNSingleDaySelectionNoDefaultModelDependency,
  NNWeekdayAwareModelDependency {}

/// Day selection model.
public protocol NNSingleDaySelectionModelType:
  NNMultiDaySelectionDefaultFunction,
  NNMultiDaySelectionNoDefaultFunction,
  NNSingleDaySelectionDefaultFunction,
  NNSingleDaySelectionNoDefaultFunction,
  NNWeekdayAwareModelType {}

// MARK: - Model.
public extension NNCalendar.DaySelection {

  /// Model implementation for day selection views.
  public final class Model {
    fileprivate let dependency: NNSingleDaySelectionModelDependency

    required public init(_ dependency: NNSingleDaySelectionModelDependency) {
      self.dependency = dependency
    }

    convenience public init(_ dependency: NNSingleDaySelectionNoDefaultModelDependency) {
      let defaultDp = DefaultDependency(dependency)
      self.init(defaultDp)
    }
  }
}

// MARK: - NNMultiDaySelectionNoDefaultFunction
extension NNCalendar.DaySelection.Model: NNMultiDaySelectionNoDefaultFunction {
  public var allSelectionReceiver: AnyObserver<Set<NNCalendar.Selection>> {
    return dependency.allSelectionReceiver
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendar.Selection>>> {
    return dependency.allSelectionStream
  }
}

// MARK: - NNSingleDaySelectionNoDefaultFunction
extension NNCalendar.DaySelection.Model: NNSingleDaySelectionNoDefaultFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return dependency.isDateSelected(date)
  }
}

// MARK: - NNSingleDaySelectionModelType
extension NNCalendar.DaySelection.Model: NNSingleDaySelectionModelType {}

// MARK: - NNWeekdayAwareDefaultModelFunction
extension NNCalendar.DaySelection.Model: NNWeekdayAwareDefaultModelFunction {
  public var firstWeekday: Int {
    return dependency.firstWeekday
  }
}

// MARK: - Default dependency
extension NNCalendar.DaySelection.Model {

  /// NNSingleDaySelectionModelDependency
  final class DefaultDependency: NNSingleDaySelectionModelDependency {
    var firstWeekday: Int { return weekdayAwareDp.firstWeekday }

    var allSelectionReceiver: AnyObserver<Set<NNCalendar.Selection>> {
      return noDefault.allSelectionReceiver
    }

    var allSelectionStream: Observable<Try<Set<NNCalendar.Selection>>> {
      return noDefault.allSelectionStream
    }

    private let noDefault: NNSingleDaySelectionNoDefaultModelDependency
    private let weekdayAwareDp: NNCalendar.WeekdayAware.Model.DefaultDependency

    init(_ dependency: NNSingleDaySelectionNoDefaultModelDependency) {
      noDefault = dependency
      weekdayAwareDp = NNCalendar.WeekdayAware.Model.DefaultDependency()
    }

    func isDateSelected(_ date: Date) -> Bool {
      return noDefault.isDateSelected(date)
    }
  }
}
