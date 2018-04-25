//
//  Model.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and its dependency that can have
/// defaults.
public protocol NNMonthHeaderDefaultModelFunction: NNMonthControlDefaultModelFunction {
  /// Format month description.
  ///
  /// - Parameter month: A ControlComponents instance.
  /// - Returns: A String value.
  func formatMonthDescription(_ month: NNCalendarLogic.Month) -> String
}

/// Shared functionalities between the model and its dependency that cannot
/// have defaults.
public protocol NNMonthHeaderNoDefaultModelFunction:
  NNMonthControlNoDefaultModelFunction {}

/// Defaultable dependency for month header model.
public protocol NNMonthHeaderDefaultModelDependency:
  NNMonthHeaderDefaultModelFunction {}

/// Non-defaultable dependency for month header model.
public protocol NNMonthHeaderNoDefaultModelDependency:
  NNMonthHeaderNoDefaultModelFunction {}

/// Dependency for month header model.
public protocol NNMonthHeaderModelDependency:
  NNMonthControlModelDependency,
  NNMonthHeaderDefaultModelDependency,
  NNMonthHeaderNoDefaultModelDependency {}

/// Model for month header view.
public protocol NNMonthHeaderModelType:
  NNMonthControlModelType,
  NNMonthHeaderDefaultModelFunction,
  NNMonthHeaderNoDefaultModelFunction {}

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

    convenience public init(_ dependency: NNMonthHeaderNoDefaultModelDependency) {
      let defaultDp = DefaultDependency(dependency)
      self.init(defaultDp)
    }
  }
}

// MARK: - NNMonthAwareNoDefaultModelFunction
extension NNCalendarLogic.MonthHeader.Model: NNMonthAwareNoDefaultModelFunction {
  public var currentMonthStream: Observable<NNCalendarLogic.Month> {
    return monthControlModel.currentMonthStream
  }
}

// MARK: - NNMonthControlNoDefaultFunction
extension NNCalendarLogic.MonthHeader.Model: NNMonthControlNoDefaultFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
    return monthControlModel.currentMonthReceiver
  }
}

// MARK: - NNMonthControlNoDefaultModelFunction
extension NNCalendarLogic.MonthHeader.Model: NNMonthControlNoDefaultModelFunction {
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

// MARK: - NNMonthHeaderModelDependency
extension NNCalendarLogic.MonthHeader.Model: NNMonthHeaderModelDependency {
  public func formatMonthDescription(_ month: NNCalendarLogic.Month) -> String {
    return dependency.formatMonthDescription(month)
  }
}

// MARK: - NNMonthHeaderModelType
extension NNCalendarLogic.MonthHeader.Model: NNMonthHeaderModelType {}

// MARK: - Default dependency.
public extension NNCalendarLogic.MonthHeader.Model {
  public final class DefaultDependency: NNMonthHeaderModelDependency {
    public var minimumMonth: NNCalendarLogic.Month { return noDefault.minimumMonth }
    public var maximumMonth: NNCalendarLogic.Month { return noDefault.maximumMonth }

    public var initialMonthStream: PrimitiveSequence<SingleTrait, NNCalendarLogic.Month> {
      return noDefault.initialMonthStream
    }

    public var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
      return noDefault.currentMonthReceiver
    }

    public var currentMonthStream: Observable<NNCalendarLogic.Month> {
      return noDefault.currentMonthStream
    }

    private let noDefault: NNMonthHeaderNoDefaultModelDependency

    public init(_ dependency: NNMonthHeaderNoDefaultModelDependency) {
      self.noDefault = dependency
    }

    public func formatMonthDescription(_ month: NNCalendarLogic.Month) -> String {
      return NNCalendarLogic.Util.defaultMonthDescription(month)
    }
  }
}
