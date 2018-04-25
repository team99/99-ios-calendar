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
import calendar99_presetLogic

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
  public var currentMonthStream: Observable<NNCalendarLogic.Month> {
    let path = NNCalendarRedux.Calendar.Action.currentMonthPath

    return reduxStore
      .stateValueStream(NNCalendarLogic.Month.self, path)
      .filter({$0.isSuccess}).map({$0.value!})
  }
}

// MARK: - NNMonthControlNoDefaultFunction
extension Singleton: NNMonthControlNoDefaultFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
    let actionFn = NNCalendarRedux.Calendar.Action.updateCurrentMonth
    return reduxStore.actionTrigger().mapObserver(actionFn)
  }
}

// MARK: - NNMonthControlNoDefaultModelFunction
extension Singleton: NNMonthControlNoDefaultModelFunction {
  public var initialMonthStream: Single<NNCalendarLogic.Month> {
    return Single.just(NNCalendarLogic.Month(1, 1970))
  }

  public var minimumMonth: NNCalendarLogic.Month {
    return NNCalendarLogic.Month(4, 2018)
  }

  public var maximumMonth: NNCalendarLogic.Month {
    return NNCalendarLogic.Month(10, 2018)
  }
}

// MARK: - NNWeekdayAwareNoDefaultModelFunction
extension Singleton: NNWeekdayAwareNoDefaultModelFunction {
  public var firstWeekday: Int {
    return 1
  }
}

// MARK: - NNMultiDaySelectionNoDefaultFunction
extension Singleton: NNMultiDaySelectionNoDefaultFunction {
  public var allSelectionReceiver: AnyObserver<Set<NNCalendarLogic.Selection>> {
    let actionFn = NNCalendarRedux.Calendar.Action.updateSelection
    return reduxStore.actionTrigger().mapObserver(actionFn)
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendarLogic.Selection>>> {
    let path = NNCalendarRedux.Calendar.Action.selectionPath
    return reduxStore.stateValueStream(Set<NNCalendarLogic.Selection>.self, path)
  }
}

// MARK: - NNSingleDaySelectionNoDefaultFunction
extension Singleton: NNSingleDaySelectionNoDefaultFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    let path = NNCalendarRedux.Calendar.Action.selectionPath

    return reduxStore
      .lastState.flatMap({$0.stateValue(path)})
      .cast(Set<NNCalendarLogic.Selection>.self)
      .map({$0.contains(where: {$0.contains(date)})})
      .getOrElse(false)
  }
}

// MARK: - NNSelectHighlightNoDefaultFunction
extension Singleton: NNSelectHighlightNoDefaultFunction {
  public func highlightPart(_ date: Date) -> NNCalendarLogic.HighlightPart {
    let path = NNCalendarRedux.Calendar.Action.selectionPath

    return reduxStore
      .lastState.flatMap({$0.stateValue(path)})
      .cast(Set<NNCalendarLogic.Selection>.self)
      .map({NNCalendarLogic.Util.highlightPart($0, date)})
      .getOrElse(.none)
  }
}

// MARK: - NNMonthDisplayNoDefaultModelDependency
extension Singleton: NNMonthDisplayNoDefaultModelDependency {}

// MARK: - NNSelectWeekdayNoDefaultModelDependency
extension Singleton: NNSelectWeekdayNoDefaultModelDependency {}

// MARK: - NNMonthHeaderNoDefaultModelDependency
extension Singleton: NNMonthHeaderNoDefaultModelDependency {}

// MARK: - NNRegular99CalendarModelDependency
extension Singleton: NNRegular99CalendarNoDefaultModelDependency {}
