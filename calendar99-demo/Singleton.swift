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

// MARK: - NNRegular99CalendarModelDependency
extension Singleton: NNRegular99CalendarModelDependency {
  public var firstWeekday: Int { return 1 }
  
  public var weekdayStacks: Int {
    return NNCalendarLogic.Util.defaultWeekdayStacks
  }
  
  public var initialMonthStream: Single<NNCalendarLogic.Month> {
    return Single.just(NNCalendarLogic.Month(1, 1970))
  }
  
  public var minimumMonth: NNCalendarLogic.Month {
    return NNCalendarLogic.Month(4, 2018)
  }
  
  public var maximumMonth: NNCalendarLogic.Month {
    return NNCalendarLogic.Month(10, 2018)
  }

  public var allSelectionReceiver: AnyObserver<Set<NNCalendarLogic.Selection>> {
    let actionFn = NNCalendarRedux.Calendar.Action.updateSelection
    return reduxStore.actionTrigger().mapObserver(actionFn)
  }
  
  public var allSelectionStream: Observable<Try<Set<NNCalendarLogic.Selection>>> {
    let path = NNCalendarRedux.Calendar.Action.selectionPath
    return reduxStore.stateValueStream(Set<NNCalendarLogic.Selection>.self, path)
  }
  
  public var currentMonthStream: Observable<NNCalendarLogic.Month> {
    let path = NNCalendarRedux.Calendar.Action.currentMonthPath
    
    return reduxStore
      .stateValueStream(NNCalendarLogic.Month.self, path)
      .filter({$0.isSuccess}).map({$0.value!})
  }
  
  public var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
    let actionFn = NNCalendarRedux.Calendar.Action.updateCurrentMonth
    return reduxStore.actionTrigger().mapObserver(actionFn)
  }
  
  public func isDateSelected(_ date: Date) -> Bool {
    let path = NNCalendarRedux.Calendar.Action.selectionPath
    
    return reduxStore
      .lastState.flatMap({$0.stateValue(path)})
      .cast(Set<NNCalendarLogic.Selection>.self)
      .map({$0.contains(where: {$0.contains(date)})})
      .getOrElse(false)
  }
  
  public func highlightPart(_ date: Date) -> NNCalendarLogic.HighlightPart {
    let path = NNCalendarRedux.Calendar.Action.selectionPath
    
    return reduxStore
      .lastState.flatMap({$0.stateValue(path)})
      .cast(Set<NNCalendarLogic.Selection>.self)
      .map({NNCalendarLogic.Util.highlightPart($0, date)})
      .getOrElse(.none)
  }
  
  public func formatMonthDescription(_ month: NNCalendarLogic.Month) -> String {
    return NNCalendarLogic.Util.defaultMonthDescription(month)
  }
  
  public func gridSelectionChanges(_ monthComps: [NNCalendarLogic.MonthComp],
                                   _ currentMonth: NNCalendarLogic.Month,
                                   _ prev: Set<NNCalendarLogic.Selection>,
                                   _ current: Set<NNCalendarLogic.Selection>)
    -> Set<NNCalendarLogic.GridPosition>
  {
    return NNCalendarLogic.Util
      .defaultGridSelectionChanges(monthComps, currentMonth, prev, current)
  }
  
  public func weekdayDescription(_ weekday: Int) -> String {
    return NNCalendarLogic.Util.defaultWeekdayDescription(weekday)
  }
}

// MARK: - NNMonthDisplayModelDependency
extension Singleton: NNMonthDisplayModelDependency {
  public func gridSelectionChanges(_ monthComp: NNCalendarLogic.MonthComp,
                                   _ prev: Set<NNCalendarLogic.Selection>,
                                   _ current: Set<NNCalendarLogic.Selection>)
    -> Set<NNCalendarLogic.GridPosition>
  {
    return NNCalendarLogic.Util
      .defaultGridSelectionChanges(monthComp, prev, current)
  }
}
