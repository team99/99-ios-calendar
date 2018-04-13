//
//  Model.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for month header whose components can have defaults.
public protocol NNMonthHeaderDefaultableModelDependency {

  /// Format month description.
  ///
  /// - Parameter components: A ControlComponents instance.
  /// - Returns: A String value.
  func formatMonthDescription(_ comps: NNCalendar.MonthComp) -> String
}

/// Dependency for month header whose components cannot have defaults.
public protocol NNMonthHeaderNonDefaultableModelDependency:
  NNMonthControlModelDependency{}

/// Dependency for month header model.
public protocol NNMonthHeaderModelDependency:
  NNMonthHeaderDefaultableModelDependency,
  NNMonthHeaderNonDefaultableModelDependency {}

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

    convenience public init(_ dependency: NNMonthHeaderNonDefaultableModelDependency) {
      let defaultDp = DefaultDependency(dependency)
      self.init(defaultDp)
    }
  }
}

// MARK: - NNMonthHeaderModelDependency
extension NNCalendar.MonthHeader.Model: NNMonthHeaderModelDependency {
  public func formatMonthDescription(_ comps: NNCalendar.MonthComp) -> String {
    return dependency.formatMonthDescription(comps)
  }
}

// MARK: - NNMonthControlModelType
extension NNCalendar.MonthHeader.Model: NNMonthControlModelType {
  public var currentMonthCompStream: Observable<NNCalendar.MonthComp> {
    return monthControlModel.currentMonthCompStream
  }

  public var currentMonthCompReceiver: AnyObserver<NNCalendar.MonthComp> {
    return monthControlModel.currentMonthCompReceiver
  }
}

// MARK: - NNMonthHeaderModelType
extension NNCalendar.MonthHeader.Model: NNMonthHeaderModelType {}

// MARK: - Default dependency.
public extension NNCalendar.MonthHeader.Model {
  internal final class DefaultDependency: NNMonthHeaderModelDependency {
    internal var currentMonthCompReceiver: AnyObserver<NNCalendar.MonthComp> {
      return nonDefaultable.currentMonthCompReceiver
    }

    internal var currentMonthCompStream: Observable<NNCalendar.MonthComp> {
      return nonDefaultable.currentMonthCompStream
    }

    private let nonDefaultable: NNMonthHeaderNonDefaultableModelDependency

    internal init(_ dependency: NNMonthHeaderNonDefaultableModelDependency) {
      self.nonDefaultable = dependency
    }

    internal func formatMonthDescription(_ comps: NNCalendar.MonthComp) -> String {
      let components = comps.dateComponents()
      let date = Calendar.current.date(from: components)!
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMM yyyy"
      return dateFormatter.string(from: date)
    }
  }
}
