//
//  SelecteekdayModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Defaultable dependency for selectable weekday display.
public protocol NNSelectWeekdayDefaultModelDependency:
  NNMonthAwareDefaultModelFunction,
  NNMultiDaySelectionDefaultFunction,
  NNWeekdayDisplayDefaultModelDependency {}

/// Non-defaultable dependency for selectable weekday display.
public protocol NNSelectWeekdayNoDefaultModelDependency:
  NNMonthAwareNoDefaultModelFunction,
  NNMultiDaySelectionNoDefaultFunction,
  NNWeekdayDisplayNoDefaultModelDependency {}

/// Dependency for selectable weekday display.
public protocol NNSelectWeekdayModelDependency:
  NNWeekdayDisplayModelDependency,
  NNSelectWeekdayDefaultModelDependency,
  NNSelectWeekdayNoDefaultModelDependency {}

/// Model for selectable weekday display.
public protocol NNSelectWeekdayModelType:
  NNMonthAwareDefaultModelFunction,
  NNMonthAwareNoDefaultModelFunction,
  NNMultiDaySelectionDefaultFunction,
  NNMultiDaySelectionNoDefaultFunction,
  NNWeekdayDisplayModelType {}

// MARK: - Model.
public extension NNCalendar.SelectWeekday {

  /// Model implementation.
  public final class Model {
    fileprivate let weekdayModel: NNWeekdayDisplayModelType
    fileprivate let dependency: NNSelectWeekdayModelDependency

    required public init(_ weekdayModel: NNWeekdayDisplayModelType,
                         _ dependency: NNSelectWeekdayModelDependency) {
      self.weekdayModel = weekdayModel
      self.dependency = dependency
    }

    convenience public init(_ dependency: NNSelectWeekdayModelDependency) {
      let weekdayModel = NNCalendar.WeekdayDisplay.Model(dependency)
      self.init(weekdayModel, dependency)
    }

    convenience public init(_ dependency: NNSelectWeekdayNoDefaultModelDependency) {
      let defaultDp = DefaultDependency(dependency)
      self.init(defaultDp)
    }
  }
}

// MARK: - NNWeekdayAwareDefaultModelFunction
extension NNCalendar.SelectWeekday.Model: NNWeekdayAwareDefaultModelFunction {
  public var firstWeekday: Int {
    return weekdayModel.firstWeekday
  }
}

// MARK: - NNWeekdayDisplayDefaultModelFunction
extension NNCalendar.SelectWeekday.Model: NNWeekdayDisplayDefaultModelFunction {
  public func weekdayDescription(_ weekday: Int) -> String {
    return weekdayModel.weekdayDescription(weekday)
  }
}

// MARK: - NNMonthAwareNoDefaultModelFunction
extension NNCalendar.SelectWeekday.Model: NNMonthAwareNoDefaultModelFunction {
  public var currentMonthStream: Observable<NNCalendar.Month> {
    return dependency.currentMonthStream
  }
}

// MARK: - NNMultiDaySelectionNoDefaultFunction
extension NNCalendar.SelectWeekday.Model: NNMultiDaySelectionNoDefaultFunction {
  public var allSelectionReceiver: AnyObserver<Set<NNCalendar.Selection>> {
    return dependency.allSelectionReceiver
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendar.Selection>>> {
    return dependency.allSelectionStream
  }
}

// MARK: - NNSelectableWeekdayModelType
extension NNCalendar.SelectWeekday.Model: NNSelectWeekdayModelType {}

// MARK: - Default dependency.
public extension NNCalendar.SelectWeekday.Model {
  public final class DefaultDependency: NNSelectWeekdayModelDependency {
    public var firstWeekday: Int { return weekdayDp.firstWeekday }

    public var currentMonthStream: Observable<NNCalendar.Month> {
      return noDefault.currentMonthStream
    }

    public var allSelectionReceiver: AnyObserver<Set<NNCalendar.Selection>> {
      return noDefault.allSelectionReceiver
    }

    public var allSelectionStream: Observable<Try<Set<NNCalendar.Selection>>> {
      return noDefault.allSelectionStream
    }

    private let weekdayDp: NNWeekdayDisplayModelDependency
    private let noDefault: NNSelectWeekdayNoDefaultModelDependency

    public init(_ dependency: NNSelectWeekdayNoDefaultModelDependency) {
      noDefault = dependency
      weekdayDp = NNCalendar.WeekdayDisplay.Model.DefaultDependency(dependency)
    }

    public func weekdayDescription(_ weekday: Int) -> String {
      return weekdayDp.weekdayDescription(weekday)
    }
  }
}
