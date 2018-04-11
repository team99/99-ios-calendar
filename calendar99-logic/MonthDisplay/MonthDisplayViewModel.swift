//
//  MonthDisplayViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the view model and its dependency, in order
/// to allow the view model to expose the same properties to the outside world.
public protocol NNMonthDisplayViewModelFunctionality {

  /// Represents the number of columns. Should be 7 in most cases.
  var columnCount: Int { get }

  /// Represents the number of rows. Generally should be 6.
  var rowCount: Int { get }
}

/// Dependency for month display view model.
public protocol NNMonthDisplayViewModelDependency: NNMonthDisplayViewModelFunctionality {

    /// Get the first day of a week (e.g. Monday).
    var firstDayOfWeek: Int { get }
}

/// Factory for month display view model dependency.
public protocol NNMonthDisplayViewModelDependencyFactory {

  /// Create a month display view model dependency.
  ///
  /// - Returns: A Calendar99MonthDisplayViewModelDependency instance.
  func monthDisplayViewModelDependency() -> NNMonthDisplayViewModelDependency
}

/// View model for month display view.
public protocol NNMonthDisplayViewModelType: NNMonthDisplayViewModelFunctionality {
  
  /// Stream days.
  var dayStream: Observable<[NNCalendar.Day]> { get }
}

public extension NNCalendar.MonthDisplay {

  /// Month display view model implementation.
  public final class ViewModel: NNMonthDisplayViewModelType {
    public var rowCount: Int {
      return dependency.rowCount
    }

    public var columnCount: Int {
      return dependency.columnCount
    }

    public var dayStream: Observable<[NNCalendar.Day]> {
      let firstDayOfWeek = dependency.firstDayOfWeek
      let rowCount = dependency.rowCount
      let columnCount = dependency.columnCount

      return model.currentComponentStream
        .map({[weak self] components in
          return (self?.model.calculateRange(components,
                                             firstDayOfWeek,
                                             rowCount,
                                             columnCount))
            .map({(components, $0)})
        })
        .filter({$0.isSome}).map({$0!})
        .map({[weak self] (comps, dates) in (self?.model)
          .map({model in dates.map({
            NNCalendar.Day(date: $0,
                           dateDescription: model.dateDescription($0),
                           isCurrentMonth: model.isInMonth(comps, $0))
          })})
        })
        .filter({$0.isSome}).map({$0!})
    }

    fileprivate let dependency: NNMonthDisplayViewModelDependency
    fileprivate let model: NNMonthDisplayModelType

    required public init(_ dependency: NNMonthDisplayViewModelDependency,
                         _ model: NNMonthDisplayModelType) {
      self.dependency = dependency
      self.model = model
    }

    convenience public init(_ model: NNMonthDisplayModelType) {
      let defaultDp = DefaultDependency()
      self.init(defaultDp, model)
    }
  }
}

public extension NNCalendar.MonthDisplay.ViewModel {

  /// Default dependency for month display model. The defaults here represent
  /// most commonly used set-up, for e.g. horizontal calendar with 42 date cells
  /// in total.
  internal final class DefaultDependency: NNMonthDisplayViewModelDependency {

    /// Corresponds to a Sunday.
    public var firstDayOfWeek: Int {
      return 1
    }

    /// Corresponds to 7 days in a week.
    public var columnCount: Int {
      return 7
    }

    /// Seems like most calendar apps have 6 rows, so in total 42 date cells.
    public var rowCount: Int {
      return 6
    }
  }
}
