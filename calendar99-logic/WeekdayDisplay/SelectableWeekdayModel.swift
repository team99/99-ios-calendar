//
//  SelectableWeekdayModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Defaultable dependency for selectable weekday display.
public protocol NNSelectableWeekdayDefaultModelDependency:
  NNMonthAwareDefaultModelFunction,
  NNMultiDaySelectionDefaultFunction {}

/// Non-defaultable dependency for selectable weekday display.
public protocol NNSelectableWeekdayNoDefaultModelDependency:
  NNMonthAwareNoDefaultModelFunction,
  NNMultiDaySelectionNoDefaultFunction {}

/// Dependency for selectable weekday display.
public protocol NNSelectableWeekdayModelDependency:
  NNWeekdayDisplayModelDependency,
  NNSelectableWeekdayDefaultModelDependency,
  NNSelectableWeekdayNoDefaultModelDependency {}

/// Model for selectable weekday display.
public protocol NNSelectableWeekdayModelType:
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
    fileprivate let dependency: NNSelectableWeekdayModelDependency

    required public init(_ weekdayModel: NNWeekdayDisplayModelType,
                         _ dependency: NNSelectableWeekdayModelDependency) {
      self.weekdayModel = weekdayModel
      self.dependency = dependency
    }

    convenience public init(_ dependency: NNSelectableWeekdayModelDependency) {
      let weekdayModel = NNCalendar.WeekdayDisplay.Model(dependency)
      self.init(weekdayModel, dependency)
    }

    convenience public init(_ dependency: NNSelectableWeekdayNoDefaultModelDependency) {
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

// MARK: - NNWeekdayDisplayDefaultFunction
extension NNCalendar.SelectWeekday.Model: NNWeekdayDisplayDefaultFunction {
  public var weekdayCount: Int {
    return weekdayModel.weekdayCount
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
  public var allDateSelectionReceiver: AnyObserver<Set<Date>> {
    return dependency.allDateSelectionReceiver
  }

  public var allDateSelectionStream: Observable<Set<Date>> {
    return dependency.allDateSelectionStream
  }
}

// MARK: - NNSelectableWeekdayModelType
extension NNCalendar.SelectWeekday.Model: NNSelectableWeekdayModelType {}

// MARK: - Default dependency.
public extension NNCalendar.SelectWeekday.Model {
  internal final class DefaultDependency: NNSelectableWeekdayModelDependency {
    internal var firstWeekday: Int { return weekdayDp.firstWeekday }
    internal var weekdayCount: Int { return weekdayDp.weekdayCount }

    internal var currentMonthStream: Observable<NNCalendar.Month> {
      return noDefault.currentMonthStream
    }

    internal var allDateSelectionReceiver: AnyObserver<Set<Date>> {
      return noDefault.allDateSelectionReceiver
    }

    internal var allDateSelectionStream: Observable<Set<Date>> {
      return noDefault.allDateSelectionStream
    }

    private let weekdayDp: NNWeekdayDisplayModelDependency
    private let noDefault: NNSelectableWeekdayNoDefaultModelDependency

    internal init(_ dependency: NNSelectableWeekdayNoDefaultModelDependency) {
      noDefault = dependency
      weekdayDp = NNCalendar.WeekdayDisplay.Model.DefaultDependency()
    }

    internal func weekdayDescription(_ weekday: Int) -> String {
      return weekdayDp.weekdayDescription(weekday)
    }
  }
}
