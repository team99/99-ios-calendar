//
//  WeekdayDisplayViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// View model for weekday display view.
public protocol NNWeekdayDisplayViewModelType: NNWeekdayDisplayFunction {

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
    fileprivate let model: NNWeekdayDisplayModelType
    fileprivate let selectionSb: PublishSubject<Int>

    required public init(_ model: NNWeekdayDisplayModelType) {
      self.model = model
      selectionSb = PublishSubject()
    }
  }
}

// MARK: - NNWeekdayDisplayFunction
extension NNCalendar.WeekdayDisplay.ViewModel: NNWeekdayDisplayFunction {
  public var weekdayCount: Int {
    return model.weekdayCount
  }
}

// MARK: - NNWeekdayDisplayViewModelType
extension NNCalendar.WeekdayDisplay.ViewModel: NNWeekdayDisplayViewModelType {
  public var weekdayStream: Observable<[NNCalendar.Weekday]> {
    let firstWeekday = model.firstWeekday
    let weekdayCount = model.weekdayCount

    let weekdays = (firstWeekday..<firstWeekday + weekdayCount)
      .map({(weekday: $0, description: model.weekdayDescription($0))})
      .map({NNCalendar.Weekday($0.weekday, $0.description)})

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
