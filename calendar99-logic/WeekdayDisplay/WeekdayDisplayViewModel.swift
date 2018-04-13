//
//  WeekdayDisplayViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for weekday display view model.
public protocol NNWeekdayDisplayViewModelDependency: NNWeekdayAwareViewModelDependency {

  /// Get the number of weekdays we would like to display.
  var weekdayCount: Int { get }
}

/// View model for weekday display view.
public protocol NNWeekdayDisplayViewModelType {

  /// Stream weekdays.
  var weekdayStream: Observable<[NNCalendar.Weekday]> { get }
}

// MARK: - View model.
public extension NNCalendar.WeekdayView {
  public final class ViewModel {
    fileprivate let dependency: NNWeekdayDisplayViewModelDependency
    fileprivate let model: NNWeekdayDisplayModelType

    public init(_ dependency: NNWeekdayDisplayViewModelDependency,
                _ model: NNWeekdayDisplayModelType) {
      self.dependency = dependency
      self.model = model
    }
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
