//
//  Regular99DelegateBridge.swift
//  calendar99-legacy
//
//  Created by Hai Pham on 24/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP
import calendar99_logic
import calendar99_presetLogic
import calendar99_preset

// MARK: - Delegate bridge.
public extension NNCalendarLegacy.Regular99 {

  /// Delegate bridge for Regular99 calendar preset.
  public final class DelegateBridge {
    fileprivate weak var delegate: NNRegular99CalendarDelegate?
    fileprivate weak var calendar: NNRegular99Calendar?
    fileprivate let currentMonthSb: PublishSubject<Void>
    fileprivate let selectionSb: PublishSubject<Void>

    public init(_ calendar: NNRegular99Calendar,
                _ delegate: NNRegular99CalendarDelegate) {
      self.calendar = calendar
      self.delegate = delegate
      currentMonthSb = PublishSubject()
      selectionSb = PublishSubject()
    }
  }
}

// MARK: - NNGridDisplayDefaultFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNGridDisplayDefaultFunction {
  public var weekdayStacks: Int {
    return calendar.zipWith(delegate, {$1.weekdayStacks(for: $0)}).getOrElse(0)
  }
}

// MARK: - NNMonthAwareNoDefaultModelFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNMonthAwareNoDefaultModelFunction {
  public var currentMonthStream: Observable<NNCalendar.Month> {
    return currentMonthSb
      .map({[weak self] in (self?.calendar).zipWith(self?.delegate, {
        $1.currentMonth(for: $0)})
      })
      .filter({$0.isSome}).map({$0!})
  }
}

// MARK: - NNMonthControlNoDefaultFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNMonthControlNoDefaultFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    return currentMonthSb.mapObserver({[weak self] month -> Void in
      (self?.calendar).zipWith(self?.delegate, {
        $1.regular99Calendar($0, onCurrentMonthChangedTo: month)
      })
    })
  }
}

// MARK: - NNMonthControlNoDefaultModelFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNMonthControlNoDefaultModelFunction {
  public var minimumMonth: NNCalendar.Month {
    return calendar.zipWith(delegate, {$1.minimumMonth(for: $0)})
      .getOrElse(NNCalendar.Month(Date()))
  }

  public var maximumMonth: NNCalendar.Month {
    return calendar.zipWith(delegate, {$1.maximumMonth(for: $0)})
      .getOrElse(NNCalendar.Month(Date()))
  }

  public var initialMonthStream: Single<NNCalendar.Month> {
    return Single.just(calendar.zipWith(delegate, {$1.initialMonth(for: $0)})
      .getOrElse(NNCalendar.Month(Date())))
  }
}

// MARK: - NNMonthHeaderDefaultModelFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNMonthHeaderDefaultModelFunction {
  public func formatMonthDescription(_ month: NNCalendar.Month) -> String {
    return calendar.zipWith(delegate, {
      $1.regular99Calendar($0, monthDescriptionFor: month)
    }).getOrElse("")
  }
}

// MARK: - NNMultiDaySelectionNoDefaultFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNMultiDaySelectionNoDefaultFunction {
  public var allSelectionReceiver: AnyObserver<Set<NNCalendar.Selection>> {
    return selectionSb.mapObserver({[weak self] selection -> Void in
      (self?.calendar).zipWith(self?.delegate, {
        $1.regular99Calendar($0, onSelectionChangedTo: selection)
      })
    })
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendar.Selection>>> {
    return selectionSb
      .map({[weak self] in (self?.calendar).zipWith(self?.delegate, {
        $1.currentSelections(for: $0)
      })})
      .filter({$0.isSome}).map({$0!.asTry()})
  }
}

// MARK: - NNMultiMonthGridSelectionCalculator
extension NNCalendarLegacy.Regular99.DelegateBridge: NNMultiMonthGridSelectionCalculator {
  public func gridSelectionChanges(_ monthComps: [NNCalendar.MonthComp],
                                   _ currentMonth: NNCalendar.Month,
                                   _ prev: Set<NNCalendar.Selection>,
                                   _ current: Set<NNCalendar.Selection>)
    -> Set<NNCalendar.GridPosition>
  {
    return calendar.zipWith(delegate, {
      $1.regular99Calendar($0, gridSelectionChangesFor: monthComps,
                           whileCurrentMonthIs: currentMonth,
                           withPreviousSelection: prev,
                           andCurrentSelection: current)
    }).getOrElse([])
  }
}

// MARK: - NNSelectHighlightNoDefaultFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNSelectHighlightNoDefaultFunction {
  public func highlightPart(_ date: Date) -> NNCalendar.HighlightPart {
    return calendar.zipWith(delegate, {
      $1.regular99Calendar($0, highlightPartFor: date)
    }).getOrElse(.none)
  }
}

// MARK: - NNSingleDaySelectionNoDefaultFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNSingleDaySelectionNoDefaultFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return calendar.zipWith(delegate, {
      $1.regular99Calendar($0, isDateSelected: date)
    }).getOrElse(false)
  }
}

// MARK: - NNWeekdayAwareNoDefaultModelFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNWeekdayAwareNoDefaultModelFunction {
  public var firstWeekday: Int {
    return calendar.zipWith(delegate, {$1.firstWeekday(for: $0)})
      .getOrElse(1)
  }
}

// MARK: - NNWeekdayDisplayDefaultModelFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNWeekdayDisplayDefaultModelFunction {
  public func weekdayDescription(_ weekday: Int) -> String {
    return calendar.zipWith(delegate, {
      $1.regular99Calendar($0, weekdayDescriptionFor: weekday)
    }).getOrElse("")
  }
}

// MARK: - NNRegular99CalendarModelDependency
extension NNCalendarLegacy.Regular99.DelegateBridge: NNRegular99CalendarModelDependency {}
