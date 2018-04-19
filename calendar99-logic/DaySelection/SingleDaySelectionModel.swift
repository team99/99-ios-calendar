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
  NNSingleDaySelectionDefaultFunction,
  NNMultiDaySelectionDefaultFunction {}

/// Non-defaultable dependency for single day selection model.
public protocol NNSingleDaySelectionNoDefaultModelDependency:
  NNSingleDaySelectionNoDefaultFunction,
  NNMultiDaySelectionNoDefaultFunction {}

/// Dependency for single day selection model.
public protocol NNSingleDaySelectionModelDependency:
  NNSingleDaySelectionDefaultModelDependency,
  NNSingleDaySelectionNoDefaultModelDependency {}

/// Day selection model.
public protocol NNSingleDaySelectionModelType:
  NNSingleDaySelectionDefaultFunction,
  NNSingleDaySelectionNoDefaultFunction,
  NNMultiDaySelectionDefaultFunction,
  NNMultiDaySelectionNoDefaultFunction {}

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

// MARK: - NNMultiDaySelectionNoDefaultFunction
extension NNCalendar.DaySelection.Model: NNMultiDaySelectionNoDefaultFunction {
  public var allDateSelectionReceiver: AnyObserver<Set<NNCalendar.Selection>> {
    return dependency.allDateSelectionReceiver
  }

  public var allDateSelectionStream: Observable<Try<Set<NNCalendar.Selection>>> {
    return dependency.allDateSelectionStream
  }
}

// MARK: - NNSingleDaySelectionNoDefaultFunction
extension NNCalendar.DaySelection.Model: NNSingleDaySelectionNoDefaultFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return dependency.isDateSelected(date)
  }
}

// MARK: - NNDaySelectionModelType
extension NNCalendar.DaySelection.Model: NNSingleDaySelectionModelType {}
