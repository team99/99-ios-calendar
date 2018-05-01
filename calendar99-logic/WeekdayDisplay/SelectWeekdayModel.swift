//
//  SelecteekdayModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Shared functionalities between the model and its dependency.
public protocol NNSelectWeekdayModelFunction:
  NNMonthAwareModelFunction,
  NNMultiDaySelectionFunction {}

/// Dependency for selectable weekday display.
public protocol NNSelectWeekdayModelDependency:
  NNSelectWeekdayModelFunction,
  NNWeekdayDisplayModelDependency {}

/// Model for selectable weekday display.
public protocol NNSelectWeekdayModelType:
  NNSelectWeekdayModelFunction,
  NNWeekdayDisplayModelType {}

// MARK: - Model.
public extension NNCalendarLogic.SelectWeekday {

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
      let weekdayModel = NNCalendarLogic.WeekdayDisplay.Model(dependency)
      self.init(weekdayModel, dependency)
    }
  }
}

// MARK: - NNWeekdayAwareModelFunction
extension NNCalendarLogic.SelectWeekday.Model: NNWeekdayAwareModelFunction {
  public var firstWeekday: Int {
    return weekdayModel.firstWeekday
  }
}

// MARK: - NNWeekdayDisplayModelFunction
extension NNCalendarLogic.SelectWeekday.Model: NNWeekdayDisplayModelFunction {
  public func weekdayDescription(_ weekday: Int) -> String {
    return weekdayModel.weekdayDescription(weekday)
  }
}

// MARK: - NNMonthAwareModelFunction
extension NNCalendarLogic.SelectWeekday.Model: NNMonthAwareModelFunction {
  public var currentMonthStream: Observable<NNCalendarLogic.Month> {
    return dependency.currentMonthStream
  }
}

// MARK: - NNMultiDaySelectionFunction
extension NNCalendarLogic.SelectWeekday.Model: NNMultiDaySelectionFunction {
  public var allSelectionReceiver: AnyObserver<Set<NNCalendarLogic.Selection>> {
    return dependency.allSelectionReceiver
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendarLogic.Selection>>> {
    return dependency.allSelectionStream
  }
}

// MARK: - NNSelectableWeekdayModelType
extension NNCalendarLogic.SelectWeekday.Model: NNSelectWeekdayModelType {}
