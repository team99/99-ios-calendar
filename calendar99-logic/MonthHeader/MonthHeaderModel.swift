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
  func formatMonthDescription(_ month: NNCalendar.Month) -> String
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

public extension NNCalendar.MonthHeader {

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
      let monthControlModel = NNCalendar.MonthControl.Model(dependency)
      self.init(monthControlModel, dependency)
    }

    convenience public init(_ dependency: NNMonthHeaderNoDefaultModelDependency) {
      let defaultDp = DefaultDependency(dependency)
      self.init(defaultDp)
    }
  }
}

// MARK: - NNMonthAwareNoDefaultModelFunction
extension NNCalendar.MonthHeader.Model: NNMonthAwareNoDefaultModelFunction {
  public var currentMonthStream: Observable<NNCalendar.Month> {
    return monthControlModel.currentMonthStream
  }
}

// MARK: - NNMonthControlNoDefaultFunction
extension NNCalendar.MonthHeader.Model: NNMonthControlNoDefaultFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    return monthControlModel.currentMonthReceiver
  }
}

// MARK: - NNMonthControlNoDefaultModelFunction
extension NNCalendar.MonthHeader.Model: NNMonthControlNoDefaultModelFunction {
  public var initialMonthStream: PrimitiveSequence<SingleTrait, NNCalendar.Month> {
    return monthControlModel.initialMonthStream
  }

  public var minimumMonth: NNCalendar.Month {
    return monthControlModel.minimumMonth
  }

  public var maximumMonth: NNCalendar.Month {
    return monthControlModel.maximumMonth
  }
}

// MARK: - NNMonthHeaderModelDependency
extension NNCalendar.MonthHeader.Model: NNMonthHeaderModelDependency {
  public func formatMonthDescription(_ month: NNCalendar.Month) -> String {
    return dependency.formatMonthDescription(month)
  }
}

// MARK: - NNMonthHeaderModelType
extension NNCalendar.MonthHeader.Model: NNMonthHeaderModelType {}

// MARK: - Default dependency.
extension NNCalendar.MonthHeader.Model {
  final class DefaultDependency: NNMonthHeaderModelDependency {
    var minimumMonth: NNCalendar.Month { return noDefault.minimumMonth }
    var maximumMonth: NNCalendar.Month { return noDefault.maximumMonth }

    var initialMonthStream: PrimitiveSequence<SingleTrait, NNCalendar.Month> {
      return noDefault.initialMonthStream
    }

    var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
      return noDefault.currentMonthReceiver
    }

    var currentMonthStream: Observable<NNCalendar.Month> {
      return noDefault.currentMonthStream
    }

    private let noDefault: NNMonthHeaderNoDefaultModelDependency

    init(_ dependency: NNMonthHeaderNoDefaultModelDependency) {
      self.noDefault = dependency
    }

    func formatMonthDescription(_ month: NNCalendar.Month) -> String {
      let components = month.dateComponents()
      let date = Calendar.current.date(from: components)!
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMM yyyy"
      return dateFormatter.string(from: date)
    }
  }
}
