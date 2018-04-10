//
//  MonthDisplayViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for month display view model.
public protocol NNMonthDisplayViewModelDependency {}

/// Factory for month display view model dependency.
public protocol NNMonthDisplayViewModelDependencyFactory {

  /// Create a month display view model dependency.
  ///
  /// - Returns: A Calendar99MonthDisplayViewModelDependency instance.
  func monthDisplayViewModelDependency() -> NNMonthDisplayViewModelDependency
}

/// View model for month display view.
public protocol NNMonthDisplayViewModelType: NNMonthDisplayFunctionality {

  /// Stream days.
  var dayStream: Observable<[NNCalendar.Day]> { get }
}

public extension NNCalendar.MonthDisplay {

  /// Month display view model implementation.
  public final class ViewModel: NNMonthDisplayViewModelType {
    public var firstDayOfWeek: Int {
      return 1
    }

    public var columnCount: Int {
      return model.columnCount
    }

    public var rowCount: Int {
      return model.rowCount
    }

    public var dayStream: Observable<[NNCalendar.Day]> {
      return model.componentStream
        .map({[weak self] components in
          (self?.model.calculateDateRange(components)).map({(components, $0)})
        })
        .filter({$0.isSome}).map({$0!})
        .map({[weak self] (comps, dates) in (self?.model).map({model in dates.map({
            NNCalendar.Day(date: $0,
                           dateDescription: model.dateDescription($0),
                           isCurrentMonth: model.isInMonth(comps, $0))
        })})})
        .filter({$0.isSome}).map({$0!})
    }

    fileprivate let dependency: NNMonthDisplayViewModelDependency
    fileprivate let model: NNMonthDisplayModelType

    public init(_ dependency: NNMonthDisplayViewModelDependency,
                _ model: NNMonthDisplayModelType) {
      self.dependency = dependency
      self.model = model
    }
  }
}
