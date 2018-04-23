//
//  Singleton.swift
//  calendar99-demo
//
//  Created by Hai Pham on 18/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import HMReactiveRedux
import RxSwift
import SwiftFP
import calendar99_logic
import calendar99_redux

public final class Singleton {
  public static let instance = Singleton()

  public let reduxStore: RxTreeStore<Any>

  private init() {
    reduxStore = RxTreeStore<Any>.createInstance({
      switch $1 {
      case let action as NNCalendarRedux.Calendar.Action:
        return NNCalendarRedux.Calendar.Reducer.reduce($0, action)

      default:
        fatalError(String(describing: $1))
      }
    })
  }
}

// MARK: - NNMonthAwareNoDefaultModelFunction
extension Singleton: NNMonthAwareNoDefaultModelFunction {
  public var currentMonthStream: Observable<NNCalendar.Month> {
    let path = NNCalendarRedux.Calendar.Action.currentMonthPath

    return reduxStore
      .stateValueStream(NNCalendar.Month.self, path)
      .filter({$0.isSuccess}).map({$0.value!})
  }
}

// MARK: - NNMonthControlNoDefaultFunction
extension Singleton: NNMonthControlNoDefaultFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    let actionFn = NNCalendarRedux.Calendar.Action.updateCurrentMonth
    return reduxStore.actionTrigger().mapObserver(actionFn)
  }
}

// MARK: - NNMonthControlNoDefaultModelFunction
extension Singleton: NNMonthControlNoDefaultModelFunction {
  public var initialMonthStream: Single<NNCalendar.Month> {
    let date = Date()
    let monthValue = Calendar.current.component(.month, from: date)
    let yearValue = Calendar.current.component(.year, from: date)
    return Single.just(NNCalendar.Month(monthValue, yearValue))
  }
}

// MARK: - NNWeekdayAwareNoDefaultModelFunction
extension Singleton: NNWeekdayAwareNoDefaultModelFunction {
  public var firstWeekday: Int {
    return 5
  }
}

// MARK: - NNMultiDaySelectionNoDefaultFunction
extension Singleton: NNMultiDaySelectionNoDefaultFunction {
  public var allSelectionReceiver: AnyObserver<Set<NNCalendar.Selection>> {
    let actionFn = NNCalendarRedux.Calendar.Action.updateSelection
    return reduxStore.actionTrigger().mapObserver(actionFn)
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendar.Selection>>> {
    let path = NNCalendarRedux.Calendar.Action.selectionPath
    return reduxStore.stateValueStream(Set<NNCalendar.Selection>.self, path)
  }
}

// MARK: - NNSingleDaySelectionNoDefaultFunction
extension Singleton: NNSingleDaySelectionNoDefaultFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    let path = NNCalendarRedux.Calendar.Action.selectionPath

    return reduxStore
      .lastState.flatMap({$0.stateValue(path)})
      .cast(Set<NNCalendar.Selection>.self)
      .map({$0.contains(where: {$0.contains(date)})})
      .getOrElse(false)
  }
}

// MARK: - NNSelectHighlightNoDefaultFunction
extension Singleton: NNSelectHighlightNoDefaultFunction {
  public func highlightPart(_ date: Date) -> NNCalendar.HighlightPart {
    let path = NNCalendarRedux.Calendar.Action.selectionPath

    return reduxStore
      .lastState.flatMap({$0.stateValue(path)})
      .cast(Set<NNCalendar.Selection>.self)
      .map({NNCalendar.Util.highlightPart($0, date)})
      .getOrElse(.none)
  }
}

// MARK: - NNMonthSectionNoDefaultModelDependency
extension Singleton: NNMonthSectionNoDefaultModelDependency {
  public var pastMonthsFromCurrent: Int {
    return 1000
  }

  public var futureMonthsFromCurrent: Int {
    return 1000
  }
}

// MARK: - NNMonthDisplayNoDefaultModelDependency
extension Singleton: NNMonthDisplayNoDefaultModelDependency {}

// MARK: - NNSelectWeekdayNoDefaultModelDependency
extension Singleton: NNSelectWeekdayNoDefaultModelDependency {}

// MARK: - NNMonthHeaderNoDefaultModelDependency
extension Singleton: NNMonthHeaderNoDefaultModelDependency {}
