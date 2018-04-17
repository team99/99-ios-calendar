//
//  SingleDaySelectionModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for day selection model.
public protocol NNSingleDaySelectionModelDependency:
  NNSingleDaySelectionFunction,
  NNMultiDaySelectionModelFunction {}

/// Day selection model.
public protocol NNSingleDaySelectionModelType:
  NNSingleDaySelectionFunction,
  NNMultiDaySelectionModelFunction {}

// MARK: - Model.
public extension NNCalendar.DaySelection {

  /// Model implementation for day selection views.
  public final class Model {
    fileprivate let dependency: NNSingleDaySelectionModelDependency

    public init(_ dependency: NNSingleDaySelectionModelDependency) {
      self.dependency = dependency
    }
  }
}

// MARK: - NNDaySelectionFunction
extension NNCalendar.DaySelection.Model: NNSingleDaySelectionFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return dependency.isDateSelected(date)
  }
}

// MARK: - NNMultiDaySelectionModelFunction
extension NNCalendar.DaySelection.Model: NNMultiDaySelectionModelFunction {
  public var allDateSelectionReceiver: AnyObserver<Set<Date>> {
    return dependency.allDateSelectionReceiver
  }

  public var allDateSelectionStream: Observable<Set<Date>> {
    return dependency.allDateSelectionStream
  }
}

// MARK: - NNDaySelectionModelType
extension NNCalendar.DaySelection.Model: NNSingleDaySelectionModelType {}
