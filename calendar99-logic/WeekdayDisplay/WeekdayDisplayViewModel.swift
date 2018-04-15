//
//  WeekdayDisplayViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the view model and its dependency.
public protocol NNWeekdayDisplayViewModelFunction {

  /// Get the number of weekdays we would like to display.
  var weekdayCount: Int { get }
}

/// Dependency for weekday display view model.
public protocol NNWeekdayDisplayViewModelDependency:
  NNWeekdayDisplayViewModelFunction,
  NNWeekdayAwareViewModelDependency {}

/// View model for weekday display view.
public protocol NNWeekdayDisplayViewModelType: NNWeekdayDisplayViewModelFunction {

  /// Stream weekdays.
  var weekdayStream: Observable<[NNCalendar.Weekday]> { get }

  /// Receive weekday selection indexes. Beware that this is 0-based so we need
  /// to add 1 to get the actual weekday.
  var weekdaySelectionIndexReceiver: AnyObserver<Int> { get }

  /// Stream weekday selections.
  var weekdaySelectionStream: Observable<Int> { get }

  /// Set up week display bindings.
  func setupWeekDisplayBindings()
}

// MARK: - View model.
public extension NNCalendar.WeekdayDisplay {
  public final class ViewModel {
    fileprivate let dependency: NNWeekdayDisplayViewModelDependency
    fileprivate let model: NNWeekdayDisplayModelType
    fileprivate let selectionSb: PublishSubject<Int>

    required public init(_ dependency: NNWeekdayDisplayViewModelDependency,
                         _ model: NNWeekdayDisplayModelType) {
      self.dependency = dependency
      self.model = model
      selectionSb = PublishSubject()
    }

    convenience public init(_ model: NNWeekdayDisplayModelType) {
      let defaultDp = DefaultDependency()
      self.init(defaultDp, model)
    }
  }
}

// MARK: - NNWeekdayDisplayViewModelFunction
extension NNCalendar.WeekdayDisplay.ViewModel: NNWeekdayDisplayViewModelFunction {
  public var weekdayCount: Int {
    return dependency.weekdayCount
  }
}

// MARK: - NNWeekdayDisplayViewModelType
extension NNCalendar.WeekdayDisplay.ViewModel: NNWeekdayDisplayViewModelType {
  public var weekdayStream: Observable<[NNCalendar.Weekday]> {
    let firstWeekday = dependency.firstWeekday
    let weekdayCount = dependency.weekdayCount

    let weekdays = (firstWeekday..<firstWeekday + weekdayCount)
      .map({(weekday: $0, description: model.weekdayDescription($0))})
      .map({NNCalendar.Weekday(dayIndex: $0.weekday, description: $0.description)})

    return Observable.just(weekdays)
  }

  public var weekdaySelectionIndexReceiver: AnyObserver<Int> {
    return selectionSb.asObserver()
  }

  /// Since we only receive the weekday selection index, add 1 to get the
  /// actual weekday.
  public var weekdaySelectionStream: Observable<Int> {
    return selectionSb.map({$0 + 1})
  }

  public func setupWeekDisplayBindings() {}
}

// MARK: - Default dependency.
public extension NNCalendar.WeekdayDisplay.ViewModel {
  internal final class DefaultDependency: NNWeekdayDisplayViewModelDependency {

    /// Most common choice would be just to have 7 days in a week.
    public var weekdayCount: Int {
      return 7
    }

    public var firstWeekday: Int {
      return weekdayAwareDp.firstWeekday
    }

    private let weekdayAwareDp: NNWeekdayAwareViewModelDependency

    internal init() {
      weekdayAwareDp = NNCalendar.WeekdayAware.ViewModel.DefaultDependency()
    }
  }
}
