//
//  WeekdayDisplayViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the view model and its dependency.
public protocol NNWeekdayDisplayViewModelFunctionality {

  /// Get the number of weekdays we would like to display.
  var weekdayCount: Int { get }
}

/// Dependency for weekday display view model.
public protocol NNWeekdayDisplayViewModelDependency:
  NNWeekdayDisplayViewModelFunctionality,
  NNWeekdayAwareViewModelDependency {}

/// View model for weekday display view.
public protocol NNWeekdayDisplayViewModelType: NNWeekdayDisplayViewModelFunctionality {

  /// Stream weekdays.
  var weekdayStream: Observable<[NNCalendar.Weekday]> { get }
}

// MARK: - View model.
public extension NNCalendar.WeekdayView {
  public final class ViewModel {
    fileprivate let dependency: NNWeekdayDisplayViewModelDependency
    fileprivate let model: NNWeekdayDisplayModelType

    required public init(_ dependency: NNWeekdayDisplayViewModelDependency,
                         _ model: NNWeekdayDisplayModelType) {
      self.dependency = dependency
      self.model = model
    }

    convenience public init(_ model: NNWeekdayDisplayModelType) {
      let defaultDp = DefaultDependency()
      self.init(defaultDp, model)
    }
  }
}

// MARK: - NNWeekdayDisplayViewModelFunctionality
extension NNCalendar.WeekdayView.ViewModel: NNWeekdayDisplayViewModelFunctionality {
  public var weekdayCount: Int {
    return dependency.weekdayCount
  }
}

// MARK: - NNWeekdayDisplayViewModelType
extension NNCalendar.WeekdayView.ViewModel: NNWeekdayDisplayViewModelType {
  public var weekdayStream: Observable<[NNCalendar.Weekday]> {
    let firstWeekday = dependency.firstDayOfWeek
    let weekdayCount = dependency.weekdayCount

    let weekdays = (firstWeekday..<firstWeekday + weekdayCount)
      .map({(weekday: $0, description: model.weekdayDescription($0))})
      .map({NNCalendar.Weekday(dayIndex: $0.weekday, description: $0.description)})

    return Observable.just(weekdays)
  }
}

// MARK: - Default dependency.
public extension NNCalendar.WeekdayView.ViewModel {
  internal final class DefaultDependency: NNWeekdayDisplayViewModelDependency {

    /// Most common choice would be just to have 7 days in a week.
    public var weekdayCount: Int {
      return 7
    }

    public var firstDayOfWeek: Int {
      return weekdayAwareDp.firstDayOfWeek
    }

    private let weekdayAwareDp: NNWeekdayAwareViewModelDependency

    internal init() {
      weekdayAwareDp = NNCalendar.WeekdayAware.ViewModel.DefaultDependency()
    }
  }
}
