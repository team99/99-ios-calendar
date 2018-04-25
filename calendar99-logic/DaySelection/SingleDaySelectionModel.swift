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
  NNWeekdayAwareDefaultModelDependency {}

/// Non-defaultable dependency for single day selection model.
public protocol NNSingleDaySelectionNoDefaultModelDependency:
  NNMultiDaySelectionNoDefaultFunction,
  NNSingleDaySelectionNoDefaultFunction,
  NNWeekdayAwareNoDefaultModelDependency {}

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
public extension NNCalendarLogic.DaySelect {

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
extension NNCalendarLogic.DaySelect.Model: NNMultiDaySelectionNoDefaultFunction {
  public var allSelectionReceiver: AnyObserver<Set<NNCalendarLogic.Selection>> {
    return dependency.allSelectionReceiver
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendarLogic.Selection>>> {
    return dependency.allSelectionStream
  }
}

// MARK: - NNSingleDaySelectionNoDefaultFunction
extension NNCalendarLogic.DaySelect.Model: NNSingleDaySelectionNoDefaultFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return dependency.isDateSelected(date)
  }
}

// MARK: - NNSingleDaySelectionModelType
extension NNCalendarLogic.DaySelect.Model: NNSingleDaySelectionModelType {}

// MARK: - NNWeekdayAwareDefaultModelFunction
extension NNCalendarLogic.DaySelect.Model: NNWeekdayAwareDefaultModelFunction {
  public var firstWeekday: Int {
    return dependency.firstWeekday
  }
}

// MARK: - Default dependency
public extension NNCalendarLogic.DaySelect.Model {

  /// NNSingleDaySelectionModelDependency
  public final class DefaultDependency: NNSingleDaySelectionModelDependency {
    public var firstWeekday: Int { return weekdayAwareDp.firstWeekday }

    public var allSelectionReceiver: AnyObserver<Set<NNCalendarLogic.Selection>> {
      return noDefault.allSelectionReceiver
    }

    public var allSelectionStream: Observable<Try<Set<NNCalendarLogic.Selection>>> {
      return noDefault.allSelectionStream
    }

    private let noDefault: NNSingleDaySelectionNoDefaultModelDependency
    private let weekdayAwareDp: NNCalendarLogic.WeekdayAware.Model.DefaultDependency

    public init(_ dependency: NNSingleDaySelectionNoDefaultModelDependency) {
      noDefault = dependency
      weekdayAwareDp = NNCalendarLogic.WeekdayAware.Model.DefaultDependency(dependency)
    }

    public func isDateSelected(_ date: Date) -> Bool {
      return noDefault.isDateSelected(date)
    }
  }
}
