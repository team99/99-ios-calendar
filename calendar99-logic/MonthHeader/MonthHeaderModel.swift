//
//  Model.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for month header whose components can have defaults.
public protocol NNMonthHeaderDefaultModelDependency {

  /// Format month description.
  ///
  /// - Parameter month: A ControlComponents instance.
  /// - Returns: A String value.
  func formatMonthDescription(_ month: NNCalendar.Month) -> String
}

/// Dependency for month header whose components cannot have defaults.
public protocol NNMonthHeaderNoDefaultModelDependency:
  NNMonthControlModelDependency{}

/// Dependency for month header model.
public protocol NNMonthHeaderModelDependency:
  NNMonthHeaderDefaultModelDependency,
  NNMonthHeaderNoDefaultModelDependency {}

/// Model for month header view.
public protocol NNMonthHeaderModelType:
  NNMonthHeaderModelDependency,
  NNMonthControlModelType {}

public extension NNCalendar.MonthHeader {

  /// Model implementation.
  public final class Model {
    /// Delegate month-related calculations to this model.
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

// MARK: - NNMonthHeaderModelDependency
extension NNCalendar.MonthHeader.Model: NNMonthHeaderModelDependency {
  public func formatMonthDescription(_ month: NNCalendar.Month) -> String {
    return dependency.formatMonthDescription(month)
  }
}

// MARK: - NNMonthControlModelType
extension NNCalendar.MonthHeader.Model: NNMonthControlModelType {
  public var currentMonthStream: Observable<NNCalendar.Month> {
    return monthControlModel.currentMonthStream
  }

  public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    return monthControlModel.currentMonthReceiver
  }
}

// MARK: - NNMonthHeaderModelType
extension NNCalendar.MonthHeader.Model: NNMonthHeaderModelType {}

// MARK: - Default dependency.
public extension NNCalendar.MonthHeader.Model {
  internal final class DefaultDependency: NNMonthHeaderModelDependency {
    internal var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
      return noDefault.currentMonthReceiver
    }

    internal var currentMonthStream: Observable<NNCalendar.Month> {
      return noDefault.currentMonthStream
    }

    private let noDefault: NNMonthHeaderNoDefaultModelDependency

    internal init(_ dependency: NNMonthHeaderNoDefaultModelDependency) {
      self.noDefault = dependency
    }

    internal func formatMonthDescription(_ month: NNCalendar.Month) -> String {
      let components = month.dateComponents()
      let date = Calendar.current.date(from: components)!
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMM yyyy"
      return dateFormatter.string(from: date)
    }
  }
}
