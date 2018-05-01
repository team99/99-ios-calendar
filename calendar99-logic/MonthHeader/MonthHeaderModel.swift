//
//  Model.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and its dependency.
public protocol NNMonthHeaderModelFunction {
  
  /// Format month description.
  ///
  /// - Parameter month: A ControlComponents instance.
  /// - Returns: A String value.
  func formatMonthDescription(_ month: NNCalendarLogic.Month) -> String
}

/// Dependency for month header model.
public protocol NNMonthHeaderModelDependency:
  NNMonthControlModelDependency,
  NNMonthHeaderModelFunction {}

/// Model for month header view.
public protocol NNMonthHeaderModelType:
  NNMonthControlModelType,
  NNMonthHeaderModelFunction {}

public extension NNCalendarLogic.MonthHeader {

  /// Model implementation.
  public final class Model {
    fileprivate let monthControlModel: NNMonthControlModelType
    fileprivate let dependency: NNMonthHeaderModelDependency

    required public init(_ monthControlModel: NNMonthControlModelType,
                         _ dependency: NNMonthHeaderModelDependency) {
      self.dependency = dependency
      self.monthControlModel = monthControlModel
    }

    convenience public init(_ dependency: NNMonthHeaderModelDependency) {
      let monthControlModel = NNCalendarLogic.MonthControl.Model(dependency)
      self.init(monthControlModel, dependency)
    }
  }
}

// MARK: - NNMonthAwareModelFunction
extension NNCalendarLogic.MonthHeader.Model: NNMonthAwareModelFunction {
  public var currentMonthStream: Observable<NNCalendarLogic.Month> {
    return monthControlModel.currentMonthStream
  }
}

// MARK: - NNMonthControlFunction
extension NNCalendarLogic.MonthHeader.Model: NNMonthControlFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
    return monthControlModel.currentMonthReceiver
  }
}

// MARK: - NNMonthControlModelFunction
extension NNCalendarLogic.MonthHeader.Model: NNMonthControlModelFunction {
  public var initialMonthStream: PrimitiveSequence<SingleTrait, NNCalendarLogic.Month> {
    return monthControlModel.initialMonthStream
  }

  public var minimumMonth: NNCalendarLogic.Month {
    return monthControlModel.minimumMonth
  }

  public var maximumMonth: NNCalendarLogic.Month {
    return monthControlModel.maximumMonth
  }
}

// MARK: - NNMonthHeaderModelFunction
extension NNCalendarLogic.MonthHeader.Model: NNMonthHeaderModelFunction {
  public func formatMonthDescription(_ month: NNCalendarLogic.Month) -> String {
    return dependency.formatMonthDescription(month)
  }
}

// MARK: - NNMonthHeaderModelType
extension NNCalendarLogic.MonthHeader.Model: NNMonthHeaderModelType {}
